import 'package:openspace_mobile_app/model/Booking.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/storage/local_db.dart';

class BookingLocal {
  /// Save multiple bookings (from server)
  Future<void> saveBookings(List<Booking> bookings) async {
    final db = await LocalDb.getDb();
    final batch = db.batch();
    
    for (var b in bookings) {
      batch.insert(
        'bookings',
        {
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
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  /// Get all bookings from local storage with optional limit
  Future<List<Booking>> getBookings({int? limit}) async {
    final db = await LocalDb.getDb();
    final maps = await db.query(
      'bookings',
      orderBy: 'createdAt DESC',
      limit: limit ?? 50, // Default limit to 50 most recent
    );
    
    return maps.map((e) => _bookingFromMap(e)).toList();
  }

  /// Add a single pending booking
  Future<void> addPendingBooking(Booking b) async {
    final db = await LocalDb.getDb();
    
    await db.insert(
      'bookings',
      {
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
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get only pending offline bookings
  Future<List<Booking>> getPendingBookings() async {
    final db = await LocalDb.getDb();
    final maps = await db.query(
      'bookings',
      where: 'status = ?',
      whereArgs: ['pending_offline'],
      orderBy: 'createdAt DESC',
    );

    return maps.map((e) => _bookingFromMap(e)).toList();
  }

  /// Remove a booking by ID (after successful sync)
  Future<void> removeBooking(String id) async {
    final db = await LocalDb.getDb();
    await db.delete(
      'bookings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update booking status
  Future<void> updateBookingStatus(String id, String status) async {
    final db = await LocalDb.getDb();
    await db.update(
      'bookings',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Helper method to create Booking from database map
  Booking _bookingFromMap(Map<String, dynamic> e) {
    return Booking(
      id: e['id'] as String,
      spaceId: e['spaceId'] as int,
      userId: e['userId'] as String?,
      username: e['username'] as String,
      contact: e['contact'] as String,
      startDate: e['startDate'] != null && (e['startDate'] as String).isNotEmpty
          ? DateTime.parse(e['startDate'] as String)
          : DateTime.now(),
      endDate: e['endDate'] != null && (e['endDate'] as String).isNotEmpty
          ? DateTime.parse(e['endDate'] as String)
          : null,
      purpose: e['purpose'] as String,
      district: e['district'] as String,
      fileUrl: e['fileUrl'] as String?,
      createdAt: e['createdAt'] != null && (e['createdAt'] as String).isNotEmpty
          ? DateTime.parse(e['createdAt'] as String)
          : DateTime.now(),
      status: e['status'] as String,
    );
  }

  /// Clear all bookings (useful for logout)
  Future<void> clearAllBookings() async {
    final db = await LocalDb.getDb();
    await db.delete('bookings');
  }
}