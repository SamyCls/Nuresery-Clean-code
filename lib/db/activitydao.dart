import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/activity.dart';
import 'database_helper.dart';

class ActivityDao {
  static const String _tableName = 'activities';
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<void> insertActivity(Activity activity) async {
    final db = await dbHelper.database;
    await db.insert(
      _tableName,
      _activityToMap(activity),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      _activityToMap(activity),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(String id) async {
    final db = await dbHelper.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Activity>> getAllActivities() async {
    final db = await dbHelper.database;
    final maps = await db.query(_tableName);
    return maps.map(_mapToActivity).toList();
  }

  Future<List<Activity>> getActivitiesByClassAndDate(
    String className,
    DateTime day,
  ) async {
    final db = await dbHelper.database;

    final dateString = DateTime(
      day.year,
      day.month,
      day.day,
    ).toIso8601String().split('T')[0];

    final maps = await db.query(
      _tableName,
      where: 'className = ? AND date LIKE ?',
      whereArgs: [className, '$dateString%'],
    );

    final list = maps.map(_mapToActivity).toList();

    list.sort(
      (a, b) =>
          (a.start.hour * 60 + a.start.minute) -
          (b.start.hour * 60 + b.start.minute),
    );
    return list;
  }

  Future<Activity?> getActivityById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return _mapToActivity(maps.first);
    }
    return null;
  }

  Map<String, dynamic> _activityToMap(Activity a) {
    return {
      'id': a.id,
      'className': a.className,
      'title': a.title,
      'date': a.date.toIso8601String(),
      'start': '${a.start.hour}:${a.start.minute}',
      'end': '${a.end.hour}:${a.end.minute}',
      'notes': a.notes,
    };
  }

  Activity _mapToActivity(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String? ?? '',
      className: map['className'] as String? ?? '',
      title: map['title'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      start: _parseTime(map['start'] as String),
      end: _parseTime(map['end'] as String),
      notes: map['notes'] as String? ?? '',
    );
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }
}
