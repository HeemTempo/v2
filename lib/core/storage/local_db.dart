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
      version: 4, // Bump version to handle notifications table addition
      onCreate: (db, version) async {
        // CREATE bookings table safely
        await db.execute('''
          CREATE TABLE IF NOT EXISTS bookings(
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

        // CREATE reports table safely
        await db.execute('''
          CREATE TABLE IF NOT EXISTS reports(
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

        // CREATE open_spaces table safely
        await db.execute('''
          CREATE TABLE IF NOT EXISTS open_spaces(
            id TEXT PRIMARY KEY,
            name TEXT,
            district TEXT,
            street TEXT,
            latitude REAL,
            longitude REAL,
            isActive INTEGER,
            status TEXT,
            amenities TEXT,
            images TEXT
          )
        ''');

        // CREATE notifications table safely
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notifications(
            id INTEGER PRIMARY KEY,
            reportId TEXT,
            message TEXT,
            repliedBy TEXT,
            createdAt TEXT,
            isRead INTEGER
          )
        ''');

        // CREATE sync_queue table safely
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sync_queue(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            action TEXT,
            entity TEXT,
            data TEXT,
            createdAt TEXT
          )
        ''');

        // CREATE profile table safely
        await ProfileLocalDataSource.createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Add notifications table if upgrading from older version
          await db.execute('''
            CREATE TABLE IF NOT EXISTS notifications(
              id INTEGER PRIMARY KEY,
              reportId TEXT,
              message TEXT,
              repliedBy TEXT,
              createdAt TEXT,
              isRead INTEGER
            )
          ''');

          // Add sync_queue table if upgrading from older version
          await db.execute('''
            CREATE TABLE IF NOT EXISTS sync_queue(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              action TEXT,
              entity TEXT,
              data TEXT,
              createdAt TEXT
            )
          ''');
        }

        // Ensure 'street' column exists in open_spaces table
        final columns = await db.rawQuery("PRAGMA table_info(open_spaces)");
        final columnNames = columns.map((c) => c['name'] as String).toList();
        if (!columnNames.contains('street')) {
          await db.execute(
            'ALTER TABLE open_spaces ADD COLUMN street TEXT DEFAULT ""',
          );
        }

        // Ensure profile table exists
        await ProfileLocalDataSource.createTable(db);
      },
    );

    return _db!;
  }
}