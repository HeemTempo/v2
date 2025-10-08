import 'package:sqflite/sqflite.dart';
import '../../core/storage/local_db.dart';

class ProfileLocalDataSource {
  static const String _tableName = 'profile';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        profilePicture TEXT
      )
    ''');
  }

  static Future<void> cacheProfile(Map<String, dynamic> profile) async {
    final db = await LocalDb.getDb();
    await db.insert(_tableName, {
      'id': profile['id'].toString(),
      'name': profile['name'] ?? profile['username'] ?? '',
      'email': profile['email'] ?? '',
      'profilePicture':
          profile['photoUrl'] ??
          profile['profile_picture'] ??
          profile['user']?['profile_picture'] ??
          '',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<Map<String, dynamic>?> getCachedProfile() async {
    final db = await LocalDb.getDb();
    final result = await db.query(_tableName, limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
