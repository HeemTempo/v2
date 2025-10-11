import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectivityService with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  
  bool _isOnline = false;
  bool get isOnline => _isOnline;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _recheckTimer;

  // Your server URL for reachability check
  static const String _serverCheckUrl = 'http://192.168.1.132:8001/api/v1/health'; // Add health endpoint
  static const String _fallbackCheckUrl = 'https://www.google.com'; // Fallback check

  ConnectivityService() {
    _initConnectivity();
    _startMonitoring();
  }

  /// Initialize connectivity status
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
    } catch (e) {
      print('Error initializing connectivity: $e');
      _isOnline = false;
      notifyListeners();
    }
  }

  /// Start monitoring connectivity changes
  void _startMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
        await _updateConnectionStatus([result]);
      },
      onError: (error) {
        print('Connectivity error: $error');
        _isOnline = false;
        notifyListeners();
      },
    );
  }

  /// Update connection status with actual reachability check
  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    
    if (result == ConnectivityResult.none) {
      _isOnline = false;
      notifyListeners();
      return;
    }

    // Connected to WiFi/Mobile, but check if we can actually reach the server
    final canReachServer = await _checkServerReachability();
    
    if (_isOnline != canReachServer) {
      _isOnline = canReachServer;
      notifyListeners();
      print('Connectivity status changed: ${_isOnline ? "ONLINE" : "OFFLINE"}');
    }

    // If offline but connected to network, recheck periodically
    if (!_isOnline && result != ConnectivityResult.none) {
      _scheduleRecheck();
    }
  }

  /// Check if server is actually reachable
  Future<bool> _checkServerReachability() async {
    try {
      // Try to reach your actual server first
      final response = await http.get(
        Uri.parse(_serverCheckUrl),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('Timeout', 408),
      );
      
      if (response.statusCode >= 200 && response.statusCode < 500) {
        print('Server reachable: ${response.statusCode}');
        return true;
      }
    } catch (e) {
      print('Server check failed: $e');
    }

    // Fallback: check if internet is available at all
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
      );
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('Internet available but server unreachable');
        return false; // Internet works but server is down
      }
    } catch (e) {
      print('Internet check failed: $e');
    }

    return false;
  }

  /// Schedule periodic recheck when offline
  void _scheduleRecheck() {
    _recheckTimer?.cancel();
    _recheckTimer = Timer(const Duration(seconds: 30), () async {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
    });
  }

  /// Manually check connectivity (useful for retry operations)
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(result);
    return _isOnline;
  }

  /// Force refresh connectivity status
  Future<void> refresh() async {
    await _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _recheckTimer?.cancel();
    super.dispose();
  }
}