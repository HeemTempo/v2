import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:openspace_mobile_app/core/network/connectivity_service.dart';
import 'package:openspace_mobile_app/data/repository/report_repository.dart';
import 'package:openspace_mobile_app/model/Report.dart';

class ReportProvider with ChangeNotifier {
  final ReportRepository _repository;
  final ConnectivityService _connectivity;
  
  ReportRepository get repository => _repository;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // Track pending reports for UI display
  List<Report> _pendingReports = [];
  List<Report> get pendingReports => _pendingReports;

  int get pendingReportsCount => _pendingReports.length;

  ReportProvider({
    required ReportRepository repository,
    required ConnectivityService connectivity,
  })  : _repository = repository,
        _connectivity = connectivity {
    // Auto-sync when coming back online
    _connectivity.addListener(_onConnectivityChanged);
    // Load pending reports on initialization
    _loadPendingReports();
  }

  void _onConnectivityChanged() {
    if (_connectivity.isOnline) {
      print('Device came online. Syncing pending reports...');
      syncPendingReports();
    }
  }

  /// Submit a report (handles online/offline automatically)
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
    _isSubmitting = true;
    notifyListeners();

    try {
      final report = await _repository.submitReport(
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

      // Reload pending reports after submission
      await _loadPendingReports();

      return report;
    } catch (e) {
      print('Error in submitReport: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Load pending reports from local storage
  Future<void> _loadPendingReports() async {
    try {
      _pendingReports = await _repository.getPendingReports();
      print('Loaded ${_pendingReports.length} pending reports');
      notifyListeners();
    } catch (e) {
      print('Error loading pending reports: $e');
    }
  }

  /// Fetch locally pending reports (public method)
  Future<List<Report>> getPendingReports() async {
    await _loadPendingReports();
    return _pendingReports;
  }

  /// Sync all pending reports to backend
  Future<void> syncPendingReports() async {
    // Double-check connectivity before syncing
    final isActuallyOnline = await _connectivity.checkConnectivity();
    
    if (!isActuallyOnline) {
      print('Cannot sync: device is offline or server unreachable');
      return;
    }

    try {
      print('Starting sync of ${_pendingReports.length} pending reports...');
      await _repository.syncPendingReports();
      await _loadPendingReports(); // Refresh the list after sync
      print('Sync completed. ${_pendingReports.length} reports still pending');
      notifyListeners();
    } catch (e) {
      print('Failed to sync pending reports: $e');
    }
  }

  /// Save a report locally (for offline or caching)
  Future<void> saveLocalReport(Report report, {String? status}) async {
    try {
      final reportToSave = status != null 
          ? report.copyWith(status: status)
          : report;
      
      await _repository.localService.saveReport(reportToSave);
      await _loadPendingReports();
    } catch (e) {
      print('Error saving local report: $e');
      rethrow;
    }
  }

  /// Check if device is online
  bool get isOnline => _connectivity.isOnline;

  /// Manually refresh pending reports list
  Future<void> refreshPendingReports() async {
    await _loadPendingReports();
  }

  @override
  void dispose() {
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}