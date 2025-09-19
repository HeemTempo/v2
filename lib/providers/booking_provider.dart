import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/core/sync/sync_service.dart';
import '../data/repository/booking_repository.dart';
import '../model/Booking.dart';


class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository = BookingRepository();

  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  BookingProvider() {
    // Initial load
    loadBookings();

    // Listen for global sync events
    SyncService().init();
  }

  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _repository.getMyBookings();
    } catch (e) {
      _bookings = [];
      debugPrint('[BookingProvider] Error loading bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBooking({
    required int spaceId,
    required String username,
    required String contact,
    required String startDate,
    String? endDate,
    required String purpose,
    required String district,
    File? file,
  }) async {
    _isLoading = true;
    notifyListeners();

    bool success = false;

    try {
      success = await _repository.createBooking(
        spaceId: spaceId,
        username: username,
        contact: contact,
        startDate: startDate,
        endDate: endDate,
        purpose: purpose,
        district: district,
        file: file,
      );

      // Reload bookings after adding
      await loadBookings();
    } catch (e) {
      debugPrint('[BookingProvider] Error adding booking: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return success;
  }

  /// Refresh bookings manually
  Future<void> refreshBookings() async {
    await loadBookings();
  }

  /// Get bookings filtered by status
  List<Booking> getBookingsByStatus(String status) {
    return _bookings
        .where((b) =>
            b.status.toLowerCase() == status.toLowerCase() ||
            (status.toLowerCase() == 'pending' &&
                b.status.toLowerCase() == 'pending_offline'))
        .toList();
  }
}
