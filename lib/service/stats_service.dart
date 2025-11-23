import '../core/storage/local_db.dart';

class StatsService {
  static Future<Map<String, int>> fetchStats() async {
    try {
      final db = await LocalDb.getDb();

      // Count open spaces
      final spacesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM open_spaces WHERE isActive = 1',
      );
      final openSpaces = spacesResult.first['count'] as int? ?? 0;

      // Count active reports (pending or submitted)
      final reportsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM reports WHERE status IN ("pending", "submitted")',
      );
      final activeReports = reportsResult.first['count'] as int? ?? 0;

      // Count bookings
      final bookingsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM bookings',
      );
      final bookings = bookingsResult.first['count'] as int? ?? 0;

      return {
        'openSpaces': openSpaces,
        'activeReports': activeReports,
        'bookings': bookings,
      };
    } catch (e) {
      print('Error fetching stats from local DB: $e');
      return {
        'openSpaces': 0,
        'activeReports': 0,
        'bookings': 0,
      };
    }
  }
}
