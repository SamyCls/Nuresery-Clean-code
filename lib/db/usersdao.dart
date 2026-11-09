import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '/models/utilisateurs.dart';

class UserDao {
  static const String _tableName = 'users';
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertUser(AppUser user) async {
    final db = await _dbHelper.database;
    return await db.insert(
      _tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AppUser?> getUserByUsername(String username) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _tableName,
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return AppUser.fromMap(maps.first);
    }
    return null;
  }

  Future<List<AppUser>> getAllUsers() async {
    final db = await _dbHelper.database;
    final maps = await db.query(_tableName);
    return maps.map((map) => AppUser.fromMap(map)).toList();
  }

  Future<int> updateUser(AppUser user) async {
    final db = await _dbHelper.database;
    return await db.update(
      _tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<AppUser?> authenticate(String username, String password) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      _tableName,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return AppUser.fromMap(maps.first);
    }
    return null;
  }
}
