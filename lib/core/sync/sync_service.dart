import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kinondoni_openspace_app/data/repository/booking_repository.dart';
import 'package:kinondoni_openspace_app/data/repository/report_repository.dart';
import 'package:kinondoni_openspace_app/data/local/report_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final BookingRepository _bookingRepo = BookingRepository();
  final ReportRepository _reportRepo = ReportRepository(localService: ReportLocal());

  late final StreamSubscription<dynamic> _subscription;

  bool _isSyncing = false;
  final Set<String> _syncedReportIds = {};
  
  Function(int successCount, int failCount, int reportCount, int bookingCount, List<String> reportIds)? onSyncComplete;

  final _syncCompleteController = StreamController<void>.broadcast();
  Stream<void> get onSyncCompletedStream => _syncCompleteController.stream;

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

  Future<void> syncNow() async {
    if (!_isSyncing) {
       await _syncAll();
    }
  }

  Future<void> _syncAll() async {
    if (_isSyncing) return;

    _isSyncing = true;
    
    int totalSuccess = 0;
    int totalFail = 0;
    int reportsSynced = 0;
    int bookingsSynced = 0;
    List<String> syncedReportIds = [];
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final isAnonymous = prefs.getBool('is_anonymous') ?? true;
      
      final reportsPending = await _reportRepo.getPendingReports();
      
      final userReports = reportsPending.where((report) {
        if (isAnonymous) {
          return report.userId == null || report.userId == 'anonymous';
        } else {
          return report.userId == userId;
        }
      }).toList();
      
      final reportsCount = userReports.length;
      
      if (reportsCount > 0) {
        await _reportRepo.syncPendingReports();
        
        await Future.delayed(const Duration(seconds: 2));
        final reportsAfter = await _reportRepo.getPendingReports();
        final userReportsAfter = reportsAfter.where((report) {
          if (isAnonymous) {
            return report.userId == null || report.userId == 'anonymous';
          } else {
            return report.userId == userId;
          }
        }).toList();
        
        reportsSynced = reportsCount - userReportsAfter.length;
        totalSuccess += reportsSynced;
        totalFail += userReportsAfter.length;
        
        if (reportsSynced > 0) {
          final allReports = await _reportRepo.getAllReports();
          final recentlySynced = allReports
              .where((r) => 
                  r.status != 'pending' && 
                  r.reportId != 'pending' &&
                  !_syncedReportIds.contains(r.reportId) &&
                  (isAnonymous 
                      ? (r.userId == null || r.userId == 'anonymous')
                      : r.userId == userId))
              .take(reportsSynced)
              .toList();
          
          syncedReportIds = recentlySynced
              .map((r) => r.reportId ?? 'N/A')
              .where((id) => id != 'N/A')
              .toList();
          
          _syncedReportIds.addAll(syncedReportIds);
        }
      }
      
      final bookingsPending = await _bookingRepo.getPendingBookings();
      final userBookings = bookingsPending.where((booking) {
        if (isAnonymous) {
          return false;
        } else {
          return booking.userId == userId;
        }
      }).toList();
      
      final bookingsCount = userBookings.length;
      
      if (bookingsCount > 0) {
        await _bookingRepo.syncPendingBookings();
        
        await Future.delayed(const Duration(seconds: 2));
        final bookingsAfter = await _bookingRepo.getPendingBookings();
        final userBookingsAfter = bookingsAfter.where((booking) {
          return booking.userId == userId;
        }).toList();
        
        bookingsSynced = bookingsCount - userBookingsAfter.length;
        totalSuccess += bookingsSynced;
        totalFail += userBookingsAfter.length;
      }
      
      if (onSyncComplete != null) {
        if (totalSuccess > 0) {
          onSyncComplete!(totalSuccess, totalFail, reportsSynced, bookingsSynced, syncedReportIds);
        } else if (reportsCount == 0 && bookingsCount == 0) {
          onSyncComplete!(0, 0, 0, 0, []);
        }
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
