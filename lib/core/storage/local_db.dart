import 'package:openspace_mobile_app/data/local/rofile_local_data_source.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDb {
  static Database? _db;

  static Future<Database> getDb() async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'offline_data.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bookings(
            id TEXT PRIMARY KEY,
            spaceId INTEGER,
            userId TEXT,
            username TEXT,
            contact TEXT,
            startDate TEXT,
            endDate TEXT,
            purpose TEXT,
            district TEXT,
            fileUrl TEXT,
            createdAt TEXT,
            status TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE reports(
            id TEXT PRIMARY KEY,
            reportId TEXT,
            description TEXT,
            email TEXT,
            file TEXT,
            createdAt TEXT,
            latitude REAL,
            longitude REAL,
            spaceName TEXT,
            userData TEXT,
            status TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE open_spaces(
            id TEXT PRIMARY KEY,
            name TEXT,
            district TEXT,
            latitude REAL,
            longitude REAL,
            isActive INTEGER,
            status TEXT,
            amenities TEXT,
            images TEXT
          )
        ''');


       await ProfileLocalDataSource.createTable(db);
      },

       onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // only create the profile table if upgrading from older version
          await ProfileLocalDataSource.createTable(db);
        }
      },


    );
    return _db!;
  }
}
