import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:openspace_mobile_app/data/local/report_local.dart';
import 'package:openspace_mobile_app/model/Report.dart';
import 'package:openspace_mobile_app/service/report_service.dart';

class ReportRepository {
  final ReportLocal localService;
  List<Report>? _cachedReports;
  DateTime? _lastFetch;

  ReportRepository({required this.localService});

  /// Check if device is online
  Future<bool> _isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Submit a report - handles online/offline automatically
  Future<Report> submitReport({
    required String description,
    String? email,
    File? file,
    String? spaceName,
    double? latitude,
    double? longitude,
  }) async {
    final isOnline = await _isConnected();

    if (!isOnline) {
      // Offline: save locally with pending status
      return await _saveOfflineReport(
        description: description,
        email: email,
        file: file,
        spaceName: spaceName,
        latitude: latitude,
        longitude: longitude,
      );
    }

    // Try online submission
    try {
      final response = await ReportingService.createReport(
        description: description,
        email: email,
        file: file,
        spaceName: spaceName,
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
        file: file,
        spaceName: spaceName,
        latitude: latitude,
        longitude: longitude,
      );
    }
  }

  /// Save report offline with pending status
  Future<Report> _saveOfflineReport({
    required String description,
    String? email,
    File? file,
    String? spaceName,
    double? latitude,
    double? longitude,
  }) async {
    final offlineReport = Report(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      reportId: 'pending',
      description: description,
      email: email,
      file: file?.path,
      createdAt: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      spaceName: spaceName,
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
    
    print('Syncing ${pendingReports.length} pending reports...');

    int successCount = 0;
    int failCount = 0;

    for (final report in pendingReports) {
      try {
        final response = await ReportingService.createReport(
          description: report.description,
          email: report.email,
          file: report.file != null ? File(report.file!) : null,
          spaceName: report.spaceName,
          latitude: report.latitude,
          longitude: report.longitude,
        );

        // Update with synced data from backend
        final syncedReport = Report.fromRestJson(response, localId: report.id);
        await localService.saveReport(syncedReport.copyWith(status: 'submitted'));
        
        successCount++;
        print('✓ Successfully synced report: ${report.id}');
      } on SocketException catch (e) {
        failCount++;
        print('✗ Network error syncing report ${report.id}: $e');
        // Stop trying if we get network errors - we're not actually online
        print('Stopping sync due to network errors. Server may be unreachable.');
        break;
      } on TimeoutException catch (e) {
        failCount++;
        print('✗ Timeout syncing report ${report.id}: $e');
        break;
      } catch (e) {
        failCount++;
        print('✗ Failed to sync report ${report.id}: $e');
        // Continue to next report for non-network errors
      }
    }
    
    print('Sync complete: $successCount succeeded, $failCount failed');
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