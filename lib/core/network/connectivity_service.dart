import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService with ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityService() {
    _initConnectivity();

    Connectivity().onConnectivityChanged.listen((result) {
      final newStatus = result != ConnectivityResult.none;
      print("DEBUG => Connectivity changed: $result | Online: $newStatus");
      if (newStatus != _isOnline) {
        _isOnline = newStatus;
        notifyListeners();
      }
    });
  }

  Future<void> _initConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    print("DEBUG => Initial connectivity: $result | Online: $_isOnline");
    notifyListeners();
  }
}
