import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';

class TrialResult {
  final bool isExpired;
  final bool isClockTampered;
  final int remainingDays;
  final int remainingHours;

  const TrialResult({
    required this.isExpired,
    required this.isClockTampered,
    required this.remainingDays,
    required this.remainingHours,
  });

  bool get shouldClose => isExpired || isClockTampered;

  String get warningMessage {
    if (isClockTampered) {
      return "Modification suspecte de la date/heure du système détectée.\nL'application doit se fermer.";
    }
    if (isExpired) {
      return "La période d'essai de 4 jours a expiré.\nL'application va se fermer. Veuillez contacter l'administrateur.";
    }
    return "Période d'essai active: $remainingDays jour(s) et $remainingHours heure(s) restant(s).";
  }
}

class TrialService {
  static const int trialDays = 4;
  static const int trialDurationMs = trialDays * 24 * 60 * 60 * 1000;
  static const String _registryPath = r'HKCU\Software\CrecheSoft';
  static const String _installTimeKey = 'InstallTime';
  static const String _lastSeenTimeKey = 'LastSeenTime';
  static const int _clockDriftToleranceMs = 5 * 60 * 1000; // 5 minutes margin

  /// Verifies trial status using Windows Registry, Hidden AppData file, and SQLite DB.
  static Future<TrialResult> checkTrialStatus() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Fetch install timestamps from all available sources
    final installTime = await _resolveInstallTime(now);

    // Sync install time back to all sources to ensure consistency
    await _syncInstallTime(installTime.toString());

    // 2. Fetch last seen timestamps to check for PC clock rewinding
    final isClockTampered = await _checkClockTampering(now);

    // Update last seen time with current time if clock is valid
    if (!isClockTampered) {
      await _recordLastSeenTime(now);
    }

    // 3. Calculate remaining duration
    final elapsedMs = now - installTime;
    final remainingMs = trialDurationMs - elapsedMs;

    if (isClockTampered || remainingMs <= 0) {
      return TrialResult(
        isExpired: remainingMs <= 0,
        isClockTampered: isClockTampered,
        remainingDays: 0,
        remainingHours: 0,
      );
    }

    final remainingDuration = Duration(milliseconds: remainingMs);
    final days = remainingDuration.inDays;
    final hours = remainingDuration.inHours % 24;

    return TrialResult(
      isExpired: false,
      isClockTampered: false,
      remainingDays: days,
      remainingHours: hours,
    );
  }

  static Future<int> _resolveInstallTime(int now) async {
    final regInstallStr = await _readRegistryValue(_installTimeKey);
    final fileInstallStr = await _readHiddenFileValue(_installTimeKey);
    final dbInstallStr = await _readDbValue(_installTimeKey);

    final List<int> timestamps = [];
    final t1 = _parseTimestamp(regInstallStr);
    final t2 = _parseTimestamp(fileInstallStr);
    final t3 = _parseTimestamp(dbInstallStr);

    if (t1 != null) timestamps.add(t1);
    if (t2 != null) timestamps.add(t2);
    if (t3 != null) timestamps.add(t3);

    if (timestamps.isNotEmpty) {
      return timestamps.reduce(min);
    }
    return now;
  }

  static Future<bool> _checkClockTampering(int now) async {
    final regLastSeenStr = await _readRegistryValue(_lastSeenTimeKey);
    final fileLastSeenStr = await _readHiddenFileValue(_lastSeenTimeKey);

    final List<int> lastSeenTimes = [];
    final ls1 = _parseTimestamp(regLastSeenStr);
    final ls2 = _parseTimestamp(fileLastSeenStr);

    if (ls1 != null) lastSeenTimes.add(ls1);
    if (ls2 != null) lastSeenTimes.add(ls2);

    if (lastSeenTimes.isNotEmpty) {
      final maxLastSeen = lastSeenTimes.reduce(max);
      if (now < maxLastSeen - _clockDriftToleranceMs) {
        return true;
      }
    }
    return false;
  }

  static Future<void> _recordLastSeenTime(int now) async {
    await _writeRegistryValue(_lastSeenTimeKey, now.toString());
    await _writeHiddenFileValues({_lastSeenTimeKey: now.toString()});
  }

  static int? _parseTimestamp(String? str) {
    if (str == null || str.trim().isEmpty) return null;
    final parsedInt = int.tryParse(str.trim());
    if (parsedInt != null) return parsedInt;
    try {
      return DateTime.parse(str.trim()).millisecondsSinceEpoch;
    } catch (_) {}
    return null;
  }

  // --- Windows Registry Helpers ---
  static Future<String?> _readRegistryValue(String valueName) async {
    if (!Platform.isWindows) return null;
    try {
      final result = await Process.run('reg', [
        'query',
        _registryPath,
        '/v',
        valueName,
      ]);
      if (result.exitCode == 0) {
        final stdout = result.stdout.toString();
        final match = RegExp(r'REG_SZ\s+(\S+)').firstMatch(stdout);
        if (match != null) {
          return match.group(1);
        }
      }
    } catch (e) {
      debugPrint('Registry read error: $e');
    }
    return null;
  }

  static Future<void> _writeRegistryValue(
    String valueName,
    String value,
  ) async {
    if (!Platform.isWindows) return;
    try {
      await Process.run('reg', [
        'add',
        _registryPath,
        '/v',
        valueName,
        '/t',
        'REG_SZ',
        '/d',
        value,
        '/f',
      ]);
    } catch (e) {
      debugPrint('Registry write error: $e');
    }
  }

  // --- Hidden AppData File Helpers ---
  static Future<String?> _readHiddenFileValue(String key) async {
    try {
      final appData =
          Platform.environment['APPDATA'] ??
          Platform.environment['LOCALAPPDATA'];
      if (appData == null) return null;
      final dir = Directory(
        path.join(appData, 'Microsoft', 'Windows', 'Caches'),
      );
      final file = File(path.join(dir.path, 'sys_creche.dat'));
      if (await file.exists()) {
        final content = await file.readAsString();
        final decoded = utf8.decode(base64.decode(content));
        final json = jsonDecode(decoded);
        return json[key]?.toString();
      }
    } catch (e) {
      debugPrint('Hidden file read error: $e');
    }
    return null;
  }

  static Future<void> _writeHiddenFileValues(Map<String, String> values) async {
    try {
      final appData =
          Platform.environment['APPDATA'] ??
          Platform.environment['LOCALAPPDATA'];
      if (appData == null) return;
      final dir = Directory(
        path.join(appData, 'Microsoft', 'Windows', 'Caches'),
      );
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File(path.join(dir.path, 'sys_creche.dat'));

      Map<String, dynamic> existing = {};
      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          existing = jsonDecode(utf8.decode(base64.decode(content)));
        } catch (_) {}
      }
      existing.addAll(values);

      final encoded = base64.encode(utf8.encode(jsonEncode(existing)));
      await file.writeAsString(encoded);
    } catch (e) {
      debugPrint('Hidden file write error: $e');
    }
  }

  // --- SQLite DB Config Table Helpers ---
  static Future<String?> _readDbValue(String key) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_config (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      final maps = await db.query(
        'app_config',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: [key],
      );
      if (maps.isNotEmpty) {
        return maps.first['value'] as String?;
      }
    } catch (e) {
      debugPrint('Database config read error: $e');
    }
    return null;
  }

  static Future<void> _writeDbValue(String key, String value) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_config (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      await db.insert('app_config', {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Database config write error: $e');
    }
  }

  static Future<void> _syncInstallTime(String installTime) async {
    await _writeRegistryValue(_installTimeKey, installTime);
    await _writeHiddenFileValues({_installTimeKey: installTime});
    await _writeDbValue(_installTimeKey, installTime);
  }
}
