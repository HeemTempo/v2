import 'package:flutter/foundation.dart';
import 'package:openspace_mobile_app/model/Notification.dart';
import '../service/notification_service.dart';


class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<ReportNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<ReportNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 🔹 Fetch notifications from backend
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _service.fetchNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Mark notification as read locally
  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }
}
