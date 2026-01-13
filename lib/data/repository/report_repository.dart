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
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Then verify we can actually reach the internet
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
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
    final isOnline = await _isConnected();

    if (!isOnline) {
      // Offline: save locally with pending status
      return await _saveOfflineReport(
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
    }

    // Try online submission
    try {
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

      final report = Report.fromRestJson(response);
      
      // Save synced report locally
      await localService.saveReport(report.copyWith(status: 'submitted'));
      return report;
    } catch (e) {
      print('Online submission failed: $e. Saving offline.');
      
      // Fallback to offline if network request fails
      return await _saveOfflineReport(
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
    }
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


  /// Sync all pending reports to backend
  Future<void> syncPendingReports() async {
    final isOnline = await _isConnected();
    if (!isOnline) {
      print('Device offline. Skipping sync.');
      return;
    }

    final pendingReports = await localService.getPendingReports();
    
    if (pendingReports.isEmpty) {
      print('No pending reports to sync.');
      return;
    }
    
    print('Syncing ${pendingReports.length} pending reports in background...');

    // Run sync asynchronously without blocking UI
    unawaited(_doSync(pendingReports));
  }

  Future<void> _doSync(List<Report> pendingReports) async {
    int successCount = 0;

    for (final report in pendingReports) {
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
        );

        final syncedReport = Report.fromRestJson(response, localId: report.id);
        await localService.saveReport(syncedReport.copyWith(status: 'submitted'));
        
        successCount++;
        print('✓ Successfully synced report: ${report.id}');
      } on SocketException catch (e) {
        print('✗ Network error syncing report ${report.id}: $e');
        break;
      } on TimeoutException catch (e) {
        print('✗ Timeout syncing report ${report.id}: $e');
        break;
      } catch (e) {
        print('✗ Failed to sync report ${report.id}: $e');
      }
    }
    
    print('Sync complete: $successCount synced.');
  }

  Future<List<Report>> getPendingReports() => localService.getPendingReports();
  
  Future<List<Report>> getAllReports({bool forceRefresh = false}) async {
    // Return cached data if available and fresh (< 5 minutes old)
    if (!forceRefresh && _cachedReports != null && _lastFetch != null) {
      final age = DateTime.now().difference(_lastFetch!);
      if (age.inMinutes < 5) {
        return _cachedReports!;
      }
    }
    
    final reports = await localService.getAllReports();
    _cachedReports = reports;
    _lastFetch = DateTime.now();
    return reports;
  }
}
