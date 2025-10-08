import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:openspace_mobile_app/core/network/connectivity_service.dart';
import 'package:openspace_mobile_app/data/repository/report_repository.dart';
import 'package:openspace_mobile_app/model/Report.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _repository;
  final ConnectivityService _connectivity;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  ReportProvider({
    required ReportRepository repository,
    required ConnectivityService connectivity,
  })  : _repository = repository,
        _connectivity = connectivity {
    // Listen to connectivity changes to auto-sync pending reports
    _connectivity.addListener(() {
      if (_connectivity.isOnline) {
        syncPendingReports();
      }
    });
  }

  /// Submit a report (online/offline handled automatically)
  Future<Report> submitReport({
    required String description,
    String? email,
    File? file,
    String? spaceName,
    double? latitude,
    double? longitude,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final report = await _repository.submitReport(
        description: description,
        email: email,
        file: file,
        spaceName: spaceName,
        latitude: latitude,
        longitude: longitude,
      );

      _isSubmitting = false;
      notifyListeners();
      return report;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Fetch locally pending reports
  Future<List<Report>> getPendingReports() async {
    return await _repository.getPendingReports();
  }

  /// Sync all pending reports to backend
  Future<void> syncPendingReports() async {
    try {
      await _repository.syncPendingReports();
      notifyListeners(); // so UI can update if needed
    } catch (e) {
      print('Failed to sync pending reports: $e');
    }
  }

  /// Utility to check online/offline
  bool get isOnline => _connectivity.isOnline;
}
