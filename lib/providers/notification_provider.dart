import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/data/repository/notification_repository.dart';
import 'package:kinondoni_openspace_app/model/Notification.dart';
import 'package:kinondoni_openspace_app/core/network/connectivity_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  List<ReportNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider({required ConnectivityService connectivityService})
      : _repository = NotificationRepository(
          connectivityService: connectivityService,
        );

  List<ReportNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Fetch notifications (online from API or offline from local database)
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
      _error = null;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      print('NotificationProvider: Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark notification as read (locally and queue for sync if offline)
  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      print('NotificationProvider: Error marking notification as read: $e');
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      
      // Update local state
      for (var notification in _notifications) {
        notification.isRead = true;
      }
      notifyListeners();
    } catch (e) {
      print('NotificationProvider: Error marking all as read: $e');
      _error = 'Failed to mark all as read: $e';
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
      print('NotificationProvider: Error syncing notifications: $e');
      _error = 'Failed to sync notifications: $e';
      notifyListeners();
    }
  }

  /// Clear all notifications (useful for logout)
  Future<void> clearAllNotifications() async {
    try {
      await _repository.clearAllNotifications();
      _notifications.clear();
      notifyListeners();
    } catch (e) {
      print('NotificationProvider: Error clearing notifications: $e');
    }
  }
}
