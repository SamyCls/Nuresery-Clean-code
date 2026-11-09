import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/enfant.dart';

class EvaluationDao {
  static const String _tableName = 'evaluations';
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<int> insertEvaluation(Evaluation eval) async {
    final db = await dbHelper.database;
    return await db.insert(
      _tableName,
      eval.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Evaluation>> getEvaluationsByEnfant(String enfantId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      _tableName,
      where: 'enfantId = ?',
      whereArgs: [enfantId],
      orderBy: 'date DESC',
    );
    return result.map(Evaluation.fromMap).toList();
  }

  Future<List<Evaluation>> getEvaluationsByMonth(
    String enfantId,
    int year,
    int month,
  ) async {
    final db = await dbHelper.database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final result = await db.query(
      _tableName,
      where: 'enfantId = ? AND date >= ? AND date < ?',
      whereArgs: [
        enfantId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
    );

    return result.map(Evaluation.fromMap).toList();
  }

  Future<Map<String, List<Evaluation>>> getAllEvaluationsByMonth(
    int year,
    int month,
  ) async {
    final db = await dbHelper.database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final result = await db.query(
      _tableName,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'enfantId, date',
    );

    final Map<String, List<Evaluation>> evaluationsByChild = {};
    for (var map in result) {
      final evaluation = Evaluation.fromMap(map);
      evaluationsByChild
          .putIfAbsent(evaluation.enfantId, () => [])
          .add(evaluation);
    }

    return evaluationsByChild;
  }

  Future<void> deleteEvaluation(int id) async {
    final db = await dbHelper.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearEvaluations(String enfantId) async {
    final db = await dbHelper.database;
    await db.delete(_tableName, where: 'enfantId = ?', whereArgs: [enfantId]);
  }

  Future<void> clearEvaluationsForMonth(
    String enfantId,
    int year,
    int month,
  ) async {
    final db = await dbHelper.database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    await db.delete(
      _tableName,
      where: 'enfantId = ? AND date >= ? AND date < ?',
      whereArgs: [
        enfantId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
    );
  }
}
