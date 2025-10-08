import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/data/local/notification_local.dart';
import 'package:openspace_mobile_app/model/Notification.dart';
import 'package:openspace_mobile_app/service/notification_service.dart';

class NotificationRepository {
  final NotificationLocalDataSource _localDataSource;
  final NotificationService _notificationService;

  NotificationRepository(this._localDataSource, this._notificationService);

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<ReportNotification>> getNotifications() async {
    if (await _isOnline()) {
      try {
        final notifications = await _notificationService.fetchNotifications();
        // Save to local database
        for (var notification in notifications) {
          await _localDataSource.saveNotification(notification);
        }
        return notifications;
      } catch (e) {
        // Fallback to local data on error
        return await _localDataSource.getNotifications();
      }
    } else {
      // Offline: return local data
      return await _localDataSource.getNotifications();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    // Update local database
    final notifications = await _localDataSource.getNotifications();
    final notification = notifications.firstWhere((n) => n.id == notificationId, orElse: () => throw Exception('Notification not found'));
    notification.isRead = true;
    await _localDataSource.updateNotification(notification);

    if (await _isOnline()) {
      try {
        await _notificationService.markNotificationAsRead(notificationId);
      } catch (e) {
        // Queue for sync
        await _localDataSource.queueForSync(
          'update',
          'notification',
          {'id': notificationId, 'isRead': true},
        );
      }
    } else {
      // Queue for sync
      await _localDataSource.queueForSync(
        'update',
        'notification',
        {'id': notificationId, 'isRead': true},
      );
    }
  }

  Future<void> syncNotifications() async {
    if (await _isOnline()) {
      final queuedActions = await _localDataSource.getQueuedActions();
      for (var action in queuedActions) {
        final data = jsonDecode(action['data']);
        if (action['entity'] == 'notification' && action['action'] == 'update') {
          try {
            await _notificationService.markNotificationAsRead(data['id']);
            await _localDataSource.clearQueuedAction(action['id']);
          } catch (e) {
            debugPrint('Sync error: $e');
          }
        }
      }
    }
  }
}