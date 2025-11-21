import '../db/db_helper.dart';
import '../model/user.dart';

class UserRepository {
  static const String tableName = 'users';
  final DbHelper _dbHelper = DbHelper.instance; 
  Future<int> insertUser(User user) async {
    final db = await _dbHelper.database;
    return await db.insert(tableName, user.toMapForInsert());
  } 


  
  Future<User?> getUserByCredentials(String username, String password) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Check apakah username sudah ada
  Future<bool> isUsernameExists(String username) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  // Check apakah email sudah ada
  Future<bool> isEmailExists(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  // Get user berdasarkan ID
  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Get semua users (untuk admin)
  Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // Update user
  Future<int> updateUser(User user) async {
    final db = await _dbHelper.database;
    return await db.update(
      tableName,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}