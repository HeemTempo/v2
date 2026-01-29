import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kinondoni_openspace_app/model/Notification.dart';
import 'package:kinondoni_openspace_app/service/notification_api_service.dart';
import 'package:kinondoni_openspace_app/core/network/connectivity_service.dart';
import '../local/notification_local.dart';

class NotificationRepository {
  final NotificationApiService _apiService;
  final NotificationLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;

  NotificationRepository({
    NotificationApiService? apiService,
    NotificationLocalDataSource? localDataSource,
    required ConnectivityService connectivityService,
  })  : _apiService = apiService ?? NotificationApiService(),
        _localDataSource = localDataSource ?? NotificationLocalDataSource(),
        _connectivityService = connectivityService;

  /// Fetch notifications from API if online, otherwise from local cache
  Future<List<ReportNotification>> getNotifications() async {
    if (_connectivityService.isOnline) {
      try {
        debugPrint('NotificationRepository: Fetching notifications from API (online)');
        final notifications = await _apiService.fetchNotifications();
        
        // Cache notifications locally for offline access
        for (var notification in notifications) {
          try {
            await _localDataSource.saveNotification(notification);
          } catch (e) {
            debugPrint('NotificationRepository: Error caching notification ${notification.id}: $e');
          }
        }
        
        debugPrint('NotificationRepository: Successfully fetched and cached ${notifications.length} notifications');
        return notifications;
      } catch (e) {
        debugPrint('NotificationRepository: Error fetching from API: $e, falling back to local cache');
        // Fallback to local cache if API fails
        return await _localDataSource.getNotifications();
      }
    } else {
      debugPrint('NotificationRepository: Offline mode, fetching from local cache');
      return await _localDataSource.getNotifications();
    }
  }

  /// Mark notification as read, sync to server if online
  Future<void> markAsRead(int notificationId) async {
    debugPrint('NotificationRepository: Marking notification $notificationId as read');
    
    // Update local database first
    try {
      final notifications = await _localDataSource.getNotifications();
      final notification = notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => throw Exception('Notification not found'),
      );
      notification.isRead = true;
      await _localDataSource.updateNotification(notification);
      debugPrint('NotificationRepository: Updated local notification $notificationId as read');
    } catch (e) {
      debugPrint('NotificationRepository: Error updating local notification: $e');
    }

    // Sync to server if online
    if (_connectivityService.isOnline) {
      try {
        await _apiService.markNotificationAsRead(notificationId);
        debugPrint('NotificationRepository: Successfully synced read status to server');
      } catch (e) {
        debugPrint('NotificationRepository: Error syncing to server: $e, queuing for later sync');
        // Queue for sync when connection is restored
        await _localDataSource.queueForSync(
          'update',
          'notification',
          {'id': notificationId, 'isRead': true},
        );
      }
    } else {
      debugPrint('NotificationRepository: Offline, queuing read status for sync');
      // Queue for sync
      await _localDataSource.queueForSync(
        'update',
        'notification',
        {'id': notificationId, 'isRead': true},
      );
    }
  }

  /// Sync pending updates to server when connection is restored
  Future<void> syncNotifications() async {
    if (!_connectivityService.isOnline) {
      debugPrint('NotificationRepository: Offline, skipping sync');
      return;
    }

    debugPrint('NotificationRepository: Starting notification sync');
    final queuedActions = await _localDataSource.getQueuedActions();
    int successCount = 0;
    int failCount = 0;

    for (var action in queuedActions) {
      try {
        final data = jsonDecode(action['data']);
        if (action['entity'] == 'notification' && action['action'] == 'update') {
          try {
            await _apiService.markNotificationAsRead(data['id']);
            await _localDataSource.clearQueuedAction(action['id']);
            successCount++;
            debugPrint('NotificationRepository: Synced notification ${data['id']}');
          } catch (e) {
            failCount++;
            debugPrint('NotificationRepository: Failed to sync notification ${data['id']}: $e');
          }
        }
      } catch (e) {
        failCount++;
        debugPrint('NotificationRepository: Error processing queued action: $e');
      }
    }

    debugPrint('NotificationRepository: Sync complete - Success: $successCount, Failed: $failCount');
  }

  /// Get count of unread notifications
  Future<int> getUnreadCount() async {
    final notifications = await _localDataSource.getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final notifications = await _localDataSource.getNotifications();
    final unreadIds = notifications.where((n) => !n.isRead).map((n) => n.id).toList();

    for (final id in unreadIds) {
      await markAsRead(id);
    }
  }

  /// Clear all local notifications (useful for logout)
  Future<void> clearAllNotifications() async {
    await _localDataSource.clearAllNotifications();
    debugPrint('NotificationRepository: Cleared all local notifications');
  }
}
