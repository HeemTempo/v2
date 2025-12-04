import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:openspace_mobile_app/data/repository/booking_repository.dart';
import 'package:openspace_mobile_app/data/repository/report_repository.dart';
import 'package:openspace_mobile_app/data/local/report_local.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final BookingRepository _bookingRepo = BookingRepository();
  final ReportRepository _reportRepo = ReportRepository(localService: ReportLocal());

  // Use dynamic list if the API returns a list
  late final StreamSubscription<dynamic> _subscription;

  bool _isSyncing = false;
  
  // Sync feedback with detailed info
  Function(int successCount, int failCount, int reportCount, int bookingCount, List<String> reportIds)? onSyncComplete;

  void init() {
    print('[SyncService] Initializing sync service...');
    _subscription = Connectivity().onConnectivityChanged.listen((event) async {
      print('[SyncService] Connectivity changed: $event');
      
      // Handle both single result and list
      bool isConnected = false;
      if (event is List<ConnectivityResult>) {
        isConnected = event.isNotEmpty && event.first != ConnectivityResult.none;
      } else if (event is ConnectivityResult) {
        isConnected = event != ConnectivityResult.none;
      }

      if (isConnected && !_isSyncing) {
        print('[SyncService] Connection detected, triggering sync...');
        await _syncAll();
      }
    });

    // Initial sync check
    _checkAndSync();
  }

  Future<void> _checkAndSync() async {
    await Future.delayed(const Duration(seconds: 2));
    final result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none && !_isSyncing) {
      print('[SyncService] Initial connectivity check - syncing...');
      await _syncAll();
    }
  }

  /// Manual sync trigger
  Future<void> syncNow() async {
    print('[SyncService] Manual sync triggered');
    await _syncAll();
  }

  Future<void> _syncAll() async {
    if (_isSyncing) {
      print('[SyncService] Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;
    print('[SyncService] Starting sync of offline data...');
    
    int totalSuccess = 0;
    int totalFail = 0;
    int reportsSynced = 0;
    int bookingsSynced = 0;
    List<String> syncedReportIds = [];
    
    try {
      // Sync reports first
      print('[SyncService] Syncing reports...');
      final reportsPending = await _reportRepo.getPendingReports();
      final reportsCount = reportsPending.length;
      
      if (reportsCount > 0) {
        await _reportRepo.syncPendingReports();
        
        // Check which ones succeeded
        final reportsAfter = await _reportRepo.getPendingReports();
        reportsSynced = reportsCount - reportsAfter.length;
        totalSuccess += reportsSynced;
        totalFail += reportsAfter.length;
        
        // Get synced report IDs from all reports
        if (reportsSynced > 0) {
          final allReports = await _reportRepo.getAllReports();
          // Get the most recent successfully synced reports
          final recentlySynced = allReports
              .where((r) => r.status != 'pending' && r.reportId != 'pending')
              .take(reportsSynced)
              .toList();
          syncedReportIds = recentlySynced
              .map((r) => r.reportId ?? 'N/A')
              .where((id) => id != 'N/A')
              .toList();
        }
      }
      
      // Then sync bookings
      print('[SyncService] Syncing bookings...');
      final bookingsPending = await _bookingRepo.getPendingBookings();
      final bookingsCount = bookingsPending.length;
      
      if (bookingsCount > 0) {
        await _bookingRepo.syncPendingBookings();
        
        final bookingsAfter = await _bookingRepo.getPendingBookings();
        bookingsSynced = bookingsCount - bookingsAfter.length;
        totalSuccess += bookingsSynced;
        totalFail += bookingsAfter.length;
      }
      
      print('[SyncService] ✓ Sync complete: $totalSuccess succeeded, $totalFail failed');
      print('[SyncService] Reports synced: $reportsSynced, Bookings synced: $bookingsSynced');
      
      // Notify listeners of sync completion with details
      if (onSyncComplete != null && totalSuccess > 0) {
        onSyncComplete!(totalSuccess, totalFail, reportsSynced, bookingsSynced, syncedReportIds);
      }
    } catch (e) {
      print('[SyncService] ✗ Error during sync: $e');
      // Retry after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        _isSyncing = false;
        _syncAll();
      });
      return;
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
