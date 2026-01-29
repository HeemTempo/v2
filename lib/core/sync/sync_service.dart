import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kinondoni_openspace_app/data/repository/booking_repository.dart';
import 'package:kinondoni_openspace_app/data/repository/report_repository.dart';
import 'package:kinondoni_openspace_app/data/local/report_local.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final BookingRepository _bookingRepo = BookingRepository();
  final ReportRepository _reportRepo = ReportRepository(localService: ReportLocal());

  late final StreamSubscription<dynamic> _subscription;

  bool _isSyncing = false;
  
  // Sync feedback with detailed info
  Function(int successCount, int failCount, int reportCount, int bookingCount, List<String> reportIds)? onSyncComplete;

  // Stream for sync completion (Broadcast stream for multiple listeners)
  final _syncCompleteController = StreamController<void>.broadcast();
  Stream<void> get onSyncCompletedStream => _syncCompleteController.stream;

  // Debounce timer
  Timer? _debounceTimer;

  void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((event) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 2), () async {
         await _handleConnectivityChange(event);
      });
    });

    _checkAndSync();
  }

  Future<void> _handleConnectivityChange(dynamic event) async {
      bool isConnected = false;
      if (event is List<ConnectivityResult>) {
        isConnected = event.any((element) => element != ConnectivityResult.none);
      } else if (event is ConnectivityResult) {
        isConnected = event != ConnectivityResult.none;
      }

      if (isConnected) {
        await Future.delayed(const Duration(seconds: 2));
        if (!_isSyncing) {
           await _syncAll();
        }
      }
  }

  Future<void> _checkAndSync() async {
    await Future.delayed(const Duration(seconds: 3));
    final result = await Connectivity().checkConnectivity();
    await _handleConnectivityChange(result);
  }

  /// Manual sync trigger
  Future<void> syncNow() async {
    if (!_isSyncing) {
       await _syncAll();
    }
  }

  Future<void> _syncAll() async {
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;
    
    int totalSuccess = 0;
    int totalFail = 0;
    int reportsSynced = 0;
    int bookingsSynced = 0;
    List<String> syncedReportIds = [];
    
    try {
      final reportsPending = await _reportRepo.getPendingReports();
      final reportsCount = reportsPending.length;
      
      if (reportsCount > 0) {
        await _reportRepo.syncPendingReports();
        
        await Future.delayed(const Duration(seconds: 2));
        final reportsAfter = await _reportRepo.getPendingReports();
        reportsSynced = reportsCount - reportsAfter.length;
        totalSuccess += reportsSynced;
        totalFail += reportsAfter.length;
        
        if (reportsSynced > 0) {
          final allReports = await _reportRepo.getAllReports();
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
      
      final bookingsPending = await _bookingRepo.getPendingBookings();
      final bookingsCount = bookingsPending.length;
      
      if (bookingsCount > 0) {
        await _bookingRepo.syncPendingBookings();
        
        await Future.delayed(const Duration(seconds: 2));
        final bookingsAfter = await _bookingRepo.getPendingBookings();
        bookingsSynced = bookingsCount - bookingsAfter.length;
        totalSuccess += bookingsSynced;
        totalFail += bookingsAfter.length;
      }
      
      if (onSyncComplete != null && totalSuccess > 0) {
        onSyncComplete!(totalSuccess, totalFail, reportsSynced, bookingsSynced, syncedReportIds);
      }
      
      _syncCompleteController.add(null);
      
    } catch (e) {
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
    _syncCompleteController.close();
  }
}
