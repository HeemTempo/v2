import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:openspace_mobile_app/data/local/booking_local.dart';
import 'package:openspace_mobile_app/model/Booking.dart';
import 'package:openspace_mobile_app/service/bookingservice.dart';

class BookingRepository {
  final BookingService _service = BookingService();
  final BookingLocal _local = BookingLocal();
  
  List<Booking>? _cachedBookings;
  DateTime? _lastFetch;

  /// Check if device is online
  Future<bool> _isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Create booking - handles online/offline automatically
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
    final isOnline = await _isConnected();

    if (!isOnline) {
      // Offline: save locally
      return await _saveOfflineBooking(
        spaceId: spaceId,
        username: username,
        contact: contact,
        startDate: startDate,
        endDate: endDate,
        purpose: purpose,
        district: district,
        file: file,
      );
    }

    // Try online submission
    try {
      print('BookingRepository: Attempting online booking');
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
        print('BookingRepository: Online booking successful');
        // Fetch and cache the latest bookings
        try {
          final bookings = await _service.fetchMyBookings();
          await _local.saveBookings(bookings);
        } catch (e) {
          print('Failed to cache bookings after creation: $e');
        }
      }

      return success;
    } on SocketException catch (e) {
      print('Network error creating booking: $e. Saving offline.');
      // Fallback to offline if network fails
      return await _saveOfflineBooking(
        spaceId: spaceId,
        username: username,
        contact: contact,
        startDate: startDate,
        endDate: endDate,
        purpose: purpose,
        district: district,
        file: file,
      );
    } on TimeoutException catch (e) {
      print('Timeout creating booking: $e. Saving offline.');
      return await _saveOfflineBooking(
        spaceId: spaceId,
        username: username,
        contact: contact,
        startDate: startDate,
        endDate: endDate,
        purpose: purpose,
        district: district,
        file: file,
      );
    } catch (e) {
      print('Error creating booking: $e. Saving offline.');
      return await _saveOfflineBooking(
        spaceId: spaceId,
        username: username,
        contact: contact,
        startDate: startDate,
        endDate: endDate,
        purpose: purpose,
        district: district,
        file: file,
      );
    }
  }

  /// Save booking offline with pending status
  Future<bool> _saveOfflineBooking({
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
      // Validate date strings
      if (startDate.isEmpty ||
          !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(startDate)) {
        throw Exception('Invalid start date format. Expected yyyy-MM-dd.');
      }
      if (endDate != null &&
          endDate.isNotEmpty &&
          !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(endDate)) {
        throw Exception('Invalid end date format. Expected yyyy-MM-dd.');
      }

      final offlineBooking = Booking(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        spaceId: spaceId,
        userId: null,
        username: username,
        contact: contact,
        startDate: DateTime.parse(startDate),
        endDate:
            (endDate != null && endDate.isNotEmpty)
                ? DateTime.parse(endDate)
                : null,
        purpose: purpose,
        district: district,
        fileUrl: file?.path,
        createdAt: DateTime.now(),
        status: 'pending_offline',
      );

      await _local.addPendingBooking(offlineBooking);
      print('BookingRepository: Offline booking saved');
      return true;
    } catch (e, stackTrace) {
      print(
        'BookingRepository: Error saving offline booking - $e\nStackTrace: $stackTrace',
      );
      rethrow;
    }
  }

  /// Get all bookings (online/offline) with caching
  Future<List<Booking>> getMyBookings({bool forceRefresh = false}) async {
    // Return cached data if available and fresh (< 5 minutes old)
    if (!forceRefresh && _cachedBookings != null && _lastFetch != null) {
      final age = DateTime.now().difference(_lastFetch!);
      if (age.inMinutes < 5) {
        return _cachedBookings!;
      }
    }

    final isOnline = await _isConnected();

    if (isOnline) {
      try {
        final bookings = await _service.fetchMyBookings();
        await _local.saveBookings(bookings);

        // Include pending offline bookings
        final pending = await _local.getPendingBookings();
        _cachedBookings = [...bookings, ...pending];
        _lastFetch = DateTime.now();
        return _cachedBookings!;
      } catch (e) {
        print('Failed to fetch online bookings: $e');
        final localData = await _local.getBookings();
        _cachedBookings = localData;
        return localData;
      }
    } else {
      final localData = await _local.getBookings();
      _cachedBookings = localData;
      return localData;
    }
  }

  /// Get pending offline bookings
  Future<List<Booking>> getPendingBookings() async {
    return await _local.getPendingBookings();
  }

  /// Sync all pending bookings to backend
  Future<void> syncPendingBookings() async {
    final isOnline = await _isConnected();
    if (!isOnline) {
      print('Cannot sync bookings: device is offline');
      return;
    }

    final pending = await _local.getPendingBookings();

    if (pending.isEmpty) {
      print('No pending bookings to sync');
      return;
    }

    print('Syncing ${pending.length} pending bookings...');

    int successCount = 0;
    int failCount = 0;

    for (var booking in pending) {
      try {
        final success = await _service.createBooking(
          spaceId: booking.spaceId,
          username: booking.username,
          contact: booking.contact,
          startDate:
              booking.startDate.toIso8601String().split('T')[0], // yyyy-MM-dd
          endDate: booking.endDate?.toIso8601String().split('T')[0],
          purpose: booking.purpose,
          district: booking.district,
          file: booking.fileUrl != null ? File(booking.fileUrl!) : null,
        );

        if (success) {
          // Remove from pending (it's now synced)
          await _local.removeBooking(booking.id);
          successCount++;
          print('✓ Successfully synced booking: ${booking.id}');
        }
      } on SocketException catch (e) {
        failCount++;
        print('✗ Network error syncing booking ${booking.id}: $e');
        break; // Stop trying if we get network errors
      } on TimeoutException catch (e) {
        failCount++;
        print('✗ Timeout syncing booking ${booking.id}: $e');
        break;
      } catch (e) {
        failCount++;
        print('✗ Failed to sync booking ${booking.id}: $e');
      }
    }

    print('Sync complete: $successCount succeeded, $failCount failed');

    // Refresh bookings from server after sync
    if (successCount > 0) {
      try {
        final onlineBookings = await _service.fetchMyBookings();
        await _local.saveBookings(onlineBookings);
      } catch (e) {
        print('Failed to refresh bookings after sync: $e');
      }
    }
  }
}
