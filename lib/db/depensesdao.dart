import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/depenses.dart';

class DepenseDao {
  static const String _tableName = 'depenses';
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<void> insertDepense(Depense depense) async {
    final db = await dbHelper.database;
    await db.insert(
      _tableName,
      _depenseToMap(depense),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Depense>> getAllDepenses() async {
    final db = await dbHelper.database;
    final maps = await db.query(_tableName, orderBy: 'date DESC');
    return maps.map(_mapToDepense).toList();
  }

  Future<Depense?> getDepenseById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(_tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return _mapToDepense(maps.first);
    }
    return null;
  }

  Future<int> updateDepense(Depense depense) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      _depenseToMap(depense),
      where: 'id = ?',
      whereArgs: [depense.id],
    );
  }

  Future<int> deleteDepense(String id) async {
    final db = await dbHelper.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllDepenses() async {
    final db = await dbHelper.database;
    return await db.delete(_tableName);
  }

  Map<String, dynamic> _depenseToMap(Depense d) {
    return {
      'id': d.id,
      'categorie': d.categorie,
      'description': d.description,
      'montant': d.montant,
      'date': d.date.toIso8601String(),
      'attestation': d.attestation,
    };
  }

  Depense _mapToDepense(Map<String, dynamic> map) {
    return Depense(
      id: map['id'] as String? ?? '',
      categorie: map['categorie'] as String? ?? '',
      description: map['description'] as String? ?? '',
      montant: (map['montant'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date'] as String),
      attestation: map['attestation'] as String? ?? '',
    );
  }
}
