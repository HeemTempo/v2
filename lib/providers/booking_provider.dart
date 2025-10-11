import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/core/network/connectivity_service.dart';
import '../data/repository/booking_repository.dart';
import '../model/Booking.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository;
  final ConnectivityService _connectivity;

  List<Booking> _bookings = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  // Get pending offline bookings
  List<Booking> get pendingBookings => 
      _bookings.where((b) => b.status == 'pending_offline').toList();
  
  int get pendingBookingsCount => pendingBookings.length;

  BookingProvider({
    required BookingRepository repository,
    required ConnectivityService connectivity,
  })  : _repository = repository,
        _connectivity = connectivity {
    // Auto-sync when coming back online
    _connectivity.addListener(_onConnectivityChanged);
    // Initial load
    loadBookings();
  }

  void _onConnectivityChanged() {
    if (_connectivity.isOnline) {
      print('Device came online. Syncing pending bookings...');
      syncPendingBookings();
    }
  }

  /// Load all bookings (online + pending)
  Future<void> loadBookings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await _repository.getMyBookings();
      print('Loaded ${_bookings.length} bookings (${pendingBookingsCount} pending)');
    } catch (e) {
      _bookings = [];
      debugPrint('[BookingProvider] Error loading bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new booking (handles online/offline automatically)
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
    _isSubmitting = true;
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
      if (success) {
        await loadBookings();
      }
    } catch (e) {
      debugPrint('[BookingProvider] Error adding booking: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }

    return success;
  }

  /// Sync all pending bookings to backend
  Future<void> syncPendingBookings() async {
    // Double-check connectivity before syncing
    final isActuallyOnline = await _connectivity.checkConnectivity();
    
    if (!isActuallyOnline) {
      print('Cannot sync bookings: device is offline or server unreachable');
      return;
    }

    try {
      print('Starting sync of ${pendingBookingsCount} pending bookings...');
      await _repository.syncPendingBookings();
      await loadBookings(); // Refresh the list after sync
      print('Sync completed. ${pendingBookingsCount} bookings still pending');
      notifyListeners();
    } catch (e) {
      print('Failed to sync pending bookings: $e');
    }
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

  /// Check if booking is pending offline
  bool isBookingPending(Booking booking) {
    return booking.status == 'pending_offline';
  }

  /// Check if device is online
  bool get isOnline => _connectivity.isOnline;

  @override
  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}