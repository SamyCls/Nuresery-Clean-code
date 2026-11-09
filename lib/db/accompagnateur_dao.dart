import '../models/accompagnateur.dart';
import 'database_helper.dart';

class AccompagnateurDao {
  static const String _tableName = 'accompagnateurs';
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<int> insertAccompagnateur(Accompagnateur acc) async {
    final db = await dbHelper.database;
    return await db.insert(_tableName, acc.toMap());
  }

  Future<List<Accompagnateur>> getAccompagnateursByEnfant(
    String enfantId,
  ) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      _tableName,
      where: 'enfantId = ?',
      whereArgs: [enfantId],
    );

    return maps.map((map) => Accompagnateur.fromMap(map)).toList();
  }

  Future<int> deleteAccompagnateur(int id) async {
    final db = await dbHelper.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateAccompagnateur(Accompagnateur acc) async {
    final db = await dbHelper.database;
    return await db.update(
      _tableName,
      acc.toMap(),
      where: 'id = ?',
      whereArgs: [acc.id],
    );
  }
}
