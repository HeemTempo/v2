import 'package:flutter/foundation.dart';
import 'package:openspace_mobile_app/data/local/notification_local.dart';
import 'package:openspace_mobile_app/data/repository/notification_repository.dart';
import 'package:openspace_mobile_app/model/Notification.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  List<ReportNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider()
      : _repository = NotificationRepository(
          NotificationLocalDataSource(),
        );

  List<ReportNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch notifications (online from API or offline from local database)
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
    } catch (e) {
      _error = 'Failed to load notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark notification as read (locally and queue for sync if offline)
  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  /// Sync queued actions when online
  Future<void> syncNotifications() async {
    try {
      await _repository.syncNotifications();
      // Refresh notifications after sync
      await fetchNotifications();
    } catch (e) {
      _error = 'Failed to sync notifications: $e';
      notifyListeners();
    }
  }
}