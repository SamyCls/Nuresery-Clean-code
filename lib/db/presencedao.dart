import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../models/Presence.dart';
import 'database_helper.dart';

class PresenceDao {
  static const String _tableName = 'presences';
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<int> insertPresence(Presence p) async {
    final db = await dbHelper.database;
    return await db.insert(
      _tableName,
      p.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Presence>> getPresencesByEnfant(String enfantId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      _tableName,
      where: 'enfantId = ?',
      whereArgs: [enfantId],
      orderBy: 'date DESC',
    );

    return maps.map(Presence.fromMap).toList();
  }

  Future<Presence?> getPresenceForDate(String enfantId, DateTime date) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      _tableName,
      where: 'enfantId = ? AND date = ?',
      whereArgs: [enfantId, date.toIso8601String()],
    );

    if (maps.isNotEmpty) {
      return Presence.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Presence>> getPresencesByDate(DateTime date) async {
    final db = await dbHelper.database;
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    final maps = await db.query(
      _tableName,
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
    );

    return maps.map(Presence.fromMap).toList();
  }

  Future<int> updatePresenceStatus(
    String enfantId,
    DateTime date,
    String newStatus,
  ) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      {'statut': newStatus},
      where: 'enfantId = ? AND date = ?',
      whereArgs: [enfantId, date.toIso8601String()],
    );
  }

  Future<int> deletePresence(String enfantId, DateTime date) async {
    final db = await dbHelper.database;
    return await db.delete(
      _tableName,
      where: 'enfantId = ? AND date = ?',
      whereArgs: [enfantId, date.toIso8601String()],
    );
  }
}
