import 'package:kinondoni_openspace_app/data/local/rofile_local_data_source.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDb {
  static Database? _db;

  static Future<Database> getDb() async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'offline_data.db');

    _db = await openDatabase(
      path,
      version: 5, // Bump version to handle reports table updates
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
            phone TEXT,
            file TEXT,
            createdAt TEXT,
            latitude REAL,
            longitude REAL,
            spaceName TEXT,
            district TEXT,
            street TEXT,
            userId TEXT,
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

        // Add indexes for better query performance
        await db.execute('CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_bookings_createdAt ON bookings(createdAt)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_reports_createdAt ON reports(createdAt)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_notifications_isRead ON notifications(isRead)');
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
        
        if (oldVersion < 5) {
          // Add missing columns to reports table
          final reportColumns = await db.rawQuery("PRAGMA table_info(reports)");
          final reportColumnNames = reportColumns.map((c) => c['name'] as String).toList();
          
          if (!reportColumnNames.contains('phone')) {
            await db.execute('ALTER TABLE reports ADD COLUMN phone TEXT');
          }
          if (!reportColumnNames.contains('district')) {
            await db.execute('ALTER TABLE reports ADD COLUMN district TEXT');
          }
          if (!reportColumnNames.contains('street')) {
            await db.execute('ALTER TABLE reports ADD COLUMN street TEXT');
          }
          if (!reportColumnNames.contains('userId')) {
            await db.execute('ALTER TABLE reports ADD COLUMN userId TEXT');
          }
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

        // Add indexes if upgrading
        await db.execute('CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_bookings_createdAt ON bookings(createdAt)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_reports_createdAt ON reports(createdAt)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_notifications_isRead ON notifications(isRead)');
      },
    );

    return _db!;
  }
}
