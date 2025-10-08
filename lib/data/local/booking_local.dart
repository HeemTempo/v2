import 'package:openspace_mobile_app/model/Booking.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/storage/local_db.dart';

class BookingLocal {
  Future<void> saveBookings(List<Booking> bookings) async {
    final db = await LocalDb.getDb();
    final batch = db.batch();
    for (var b in bookings) {
      batch.insert('bookings', {
        'id': b.id,
        'spaceId': b.spaceId,
        'userId': b.userId,
        'username': b.username,
        'contact': b.contact,
        'startDate': b.startDate.toIso8601String(),
        'endDate': b.endDate?.toIso8601String(),
        'purpose': b.purpose,
        'district': b.district,
        'fileUrl': b.fileUrl,
        'createdAt': b.createdAt.toIso8601String(),
        'status': b.status,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Booking>> getBookings() async {
    final db = await LocalDb.getDb();
    final maps = await db.query('bookings');
    return maps
        .map(
          (e) => Booking(
            id: e['id'] as String,
            spaceId: e['spaceId'] as int,
            userId: e['userId'] as String?,
            username: e['username'] as String,
            contact: e['contact'] as String,
            startDate:
                e['startDate'] != null && (e['startDate'] as String).isNotEmpty
                    ? DateTime.parse(e['startDate'] as String)
                    : DateTime.now(),
            endDate:
                e['endDate'] != null && (e['endDate'] as String).isNotEmpty
                    ? DateTime.parse(e['endDate'] as String)
                    : null,

            purpose: e['purpose'] as String,
            district: e['district'] as String,
            fileUrl: e['fileUrl'] as String?,
            createdAt: DateTime.parse(e['createdAt'] as String),
            status: e['status'] as String,
          ),
        )
        .toList();
  }

  Future<void> addPendingBooking(Booking b) async {
    final db = await LocalDb.getDb();
    await db.insert('bookings', {
      'id': b.id,
      'spaceId': b.spaceId,
      'userId': b.userId,
      'username': b.username,
      'contact': b.contact,
      'startDate': b.startDate.toIso8601String(),
      'endDate': b.endDate?.toIso8601String(),
      'purpose': b.purpose,
      'district': b.district,
      'fileUrl': b.fileUrl,
      'createdAt': b.createdAt.toIso8601String(),
      'status': b.status,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Booking>> getPendingBookings() async {
    final db = await LocalDb.getDb();
    final maps = await db.query(
      'bookings',
      where: 'status = ?',
      whereArgs: ['pending_offline'],
    );

    return maps
        .map(
          (e) => Booking(
            id: e['id'] as String,
            spaceId: e['spaceId'] as int,
            userId: e['userId'] as String?,
            username: e['username'] as String,
            contact: e['contact'] as String,
            startDate:
                e['startDate'] != null && (e['startDate'] as String).isNotEmpty
                    ? DateTime.parse(e['startDate'] as String)
                    : DateTime.now(),
            endDate:
                e['endDate'] != null && (e['endDate'] as String).isNotEmpty
                    ? DateTime.parse(e['endDate'] as String)
                    : null,

            purpose: e['purpose'] as String,
            district: e['district'] as String,
            fileUrl: e['fileUrl'] as String?,
            createdAt: DateTime.parse(e['createdAt'] as String),
            status: e['status'] as String,
          ),
        )
        .toList();
  }
}
