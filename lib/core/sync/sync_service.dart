import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:openspace_mobile_app/data/repository/booking_repository.dart';


class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final BookingRepository _bookingRepo = BookingRepository();
  StreamSubscription<ConnectivityResult>? _subscription;

  void init() {
    // Listen for connectivity changes
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncAll();
      }
    }) as StreamSubscription<ConnectivityResult>?;
  }

  Future<void> _syncAll() async {
    print('[SyncService] Connectivity restored, syncing offline data...');
    await _bookingRepo.syncPendingBookings();
    // TODO: add other repositories like reports if needed
    print('[SyncService] Offline data sync completed.');
  }

  void dispose() {
    _subscription?.cancel();
  }
}
