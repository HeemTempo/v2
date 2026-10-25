import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kinondoni_openspace_app/data/local/report_local.dart';
import 'package:kinondoni_openspace_app/model/Report.dart';
import 'package:kinondoni_openspace_app/service/report_service.dart';

class ReportRepository {
  final ReportLocal localService;
  List<Report>? _cachedReports;
  DateTime? _lastFetch;

  ReportRepository({required this.localService});

  /// Check if device has internet and can reach server
  Future<bool> _isConnected() async {
    try {
      // First check basic connectivity
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.isEmpty ||
          connectivityResults.every(
            (result) => result == ConnectivityResult.none,
          )) {
        return false;
      }

      // We rely on the actual request to fail if there's no real internet.
      // The google.com check was causing false negatives.
      return true;
    } catch (e) {
      print('Connectivity check failed: $e');
      return false;
    }
  }

  /// Submit a report - handles online/offline automatically
  Future<Report> submitReport({
    required String description,
    String? email,
    String? phone,
    File? file,
    String? spaceName,
    String? district,
    String? street,
    String? userId,
    double? latitude,
    double? longitude,
  }) async {
    // Reports are submitted directly to the online API. Do not initialize or
    // fall back to SQLite when the app is configured for online-only use.
    final response = await ReportingService.createReport(
      description: description,
      email: email,
      phone: phone,
      file: file,
      spaceName: spaceName,
      district: district,
      street: street,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
    );

    return Report.fromRestJson(response);
  }

  /// Save report offline with pending status
  Future<Report> _saveOfflineReport({
    required String description,
    String? email,
    String? phone,
    File? file,
    String? spaceName,
    String? district,
    String? street,
    String? userId,
    double? latitude,
    double? longitude,
  }) async {
    final offlineReport = Report(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      reportId: 'pending',
      description: description,
      email: email,
      phone: phone,
      file: file?.path,
      createdAt: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      spaceName: spaceName,
      district: district,
      street: street,
      userId: userId,
      user: null,
      status: 'pending',
    );

    await localService.saveReport(offlineReport);
    return offlineReport;
  }

  // Static lock to prevent concurrent syncs across multiple repository instances
  static bool _isSyncing = false;

  /// Sync all pending reports to backend
  Future<void> syncPendingReports() async {
    // Online-only mode has no pending local reports to synchronize.
    return;
  }

  Future<void> _doSync(List<Report> pendingReports) async {
    int successCount = 0;

    final reportsToSync = pendingReports.reversed.toList();

    for (final report in reportsToSync) {
      try {
        final response = await ReportingService.createReport(
          description: report.description,
          email: report.email,
          phone: report.phone,
          file: report.file != null ? File(report.file!) : null,
          spaceName: report.spaceName,
          district: report.district,
          street: report.street,
          userId: report.userId,
          latitude: report.latitude,
          longitude: report.longitude,
        ).timeout(const Duration(seconds: 10));

        await localService.removeReport(report.id);

        successCount++;
      } on SocketException {
        break;
      } on TimeoutException {
        break;
      } catch (e) {
        continue;
      }
    }
  }

  Future<List<Report>> getPendingReports() async => <Report>[];

  Future<List<Report>> getAllReports({bool forceRefresh = false}) async {
    // Return cached data if available and fresh (< 5 minutes old)
    if (!forceRefresh && _cachedReports != null && _lastFetch != null) {
      final age = DateTime.now().difference(_lastFetch!);
      if (age.inMinutes < 5) {
        return _cachedReports!;
      }
    }

    // Reports are fetched directly from the online API. There is no local DB
    // fallback in the online-only application.
    final reports = await ReportingService.getUserReports();
    _cachedReports = reports;
    _lastFetch = DateTime.now();
    return reports;
  }
}
