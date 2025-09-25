// lib/repository/booking_repository.dart
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:openspace_mobile_app/core/storage/local_db.dart';
import 'package:openspace_mobile_app/data/local/booking_local.dart';
import 'package:openspace_mobile_app/model/Booking.dart';
import 'package:openspace_mobile_app/service/bookingservice.dart';



class BookingRepository {
  final BookingService _service = BookingService();
  final BookingLocal _local = BookingLocal();

  Future<bool> createBooking({
    required int spaceId,
    required String username,
    required String contact,
    required String startDate,
    String? endDate,
    required String purpose,
    required String district,
    File? file,
  }) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (isOnline) {
        // Try online booking
        final success = await _service.createBooking(
          spaceId: spaceId,
          username: username,
          contact: contact,
          startDate: startDate,
          endDate: endDate,
          purpose: purpose,
          district: district,
          file: file,
        );
        if (success) {
          // Save to local history
          final bookings = await _service.fetchMyBookings();
          await _local.saveBookings(bookings);
        }
        return success;
      } else {
        // Save locally as pending booking
        final offlineBooking = Booking(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          spaceId: spaceId,
          userId: null,
          username: username,
          contact: contact,
          startDate: DateTime.parse(startDate),
          endDate: endDate != null ? DateTime.parse(endDate) : null,
          purpose: purpose,
          district: district,
          fileUrl: file?.path,
          createdAt: DateTime.now(),
          status: "pending_offline",
        );
        await _local.addPendingBooking(offlineBooking);
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Booking>> getMyBookings() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (isOnline) {
        final bookings = await _service.fetchMyBookings();
        await _local.saveBookings(bookings);
        return bookings;
      } else {
        return _local.getBookings();
      }
    } catch (e) {
      return _local.getBookings();
    }
  }


  Future<List<Booking>> getPendingBookings() async {
  final db = await LocalDb.getDb();
  final maps = await db.query(
    'bookings',
    where: 'status = ?',
    whereArgs: ['pending_offline'],
  );

  return maps.map((e) => Booking(
    id: e['id'] as String,
    spaceId: e['spaceId'] as int,
    userId: e['userId'] as String?,
    username: e['username'] as String,
    contact: e['contact'] as String,
    startDate: DateTime.parse(e['startDate'] as String),
    endDate: e['endDate'] != null ? DateTime.parse(e['endDate'] as String) : null,
    purpose: e['purpose'] as String,
    district: e['district'] as String,
    fileUrl: e['fileUrl'] as String?,
    createdAt: DateTime.parse(e['createdAt'] as String),
    status: e['status'] as String,
  )).toList();
}

Future<void> syncPendingBookings() async {
  final connectivity = await Connectivity().checkConnectivity();
  final isOnline = connectivity != ConnectivityResult.none;
  if (!isOnline) return;

  final pending = await _local.getPendingBookings();
  for (var booking in pending) {
    try {
      final success = await _service.createBooking(
        spaceId: booking.spaceId,
        username: booking.username,
        contact: booking.contact,
        startDate: booking.startDate.toIso8601String(),
        endDate: booking.endDate?.toIso8601String(),
        purpose: booking.purpose,
        district: booking.district,
        file: booking.fileUrl != null ? File(booking.fileUrl!) : null,
      );

      if (success) {
        // After successful sync, refresh local bookings from server
        final onlineBookings = await _service.fetchMyBookings();
        await _local.saveBookings(onlineBookings);
      }
    } catch (e) {
      // If sync fails, keep it pending
    }
  }
}


}
