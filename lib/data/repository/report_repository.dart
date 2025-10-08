import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:openspace_mobile_app/data/local/report_local.dart';
import 'package:openspace_mobile_app/model/Report.dart';
import 'package:openspace_mobile_app/service/report_service.dart';

class ReportRepository {
  final ReportLocal localService;

  ReportRepository({required this.localService});

  Future<Report> submitReport({
    required String description,
    String? email,
    File? file,
    String? spaceName,
    double? latitude,
    double? longitude,
    bool isOnline = true,
  }) async {
    if (!isOnline) {
      // offline → save locally
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
      await localService.saveReport(report); // cache locally
      return report;
    } catch (e) {
      // fallback offline
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
  }

  /// Sync all pending reports to backend
  Future<void> syncPendingReports() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final pendingReports = await localService.getPendingReports();

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

        // Update local report with backend reportId & status
        final syncedReport = Report.fromRestJson(response);
        await localService.updateReportStatus(report.id, 'synced');
        await localService.saveReport(syncedReport);
      } catch (e) {
        // Ignore failures, leave report as pending
        print('Failed to sync report ${report.id}: $e');
      }
    }
  }

  Future<List<Report>> getPendingReports() => localService.getPendingReports();
}
