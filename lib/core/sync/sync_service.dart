import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:openspace_mobile_app/data/repository/booking_repository.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final BookingRepository _bookingRepo = BookingRepository();

  // Use dynamic list if the API returns a list
  late final StreamSubscription<dynamic> _subscription;

  void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((event) {
      // event might be single or list
      if (event is ConnectivityResult) {
        if (event != ConnectivityResult.none) _syncAll();
      // ignore: curly_braces_in_flow_control_structures
      } else      if (event.isNotEmpty && event.first != ConnectivityResult.none) _syncAll();
    
    });
  }

  Future<void> _syncAll() async {
    print('[SyncService] Connectivity restored, syncing offline data...');
    await _bookingRepo.syncPendingBookings();
    print('[SyncService] Offline data sync completed.');
  }

  void dispose() {
    _subscription.cancel();
  }
}
