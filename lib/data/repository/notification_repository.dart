import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/data/local/notification_local.dart';
import 'package:openspace_mobile_app/model/Notification.dart';
import 'package:http/http.dart' as http;
import 'package:openspace_mobile_app/service/auth_service.dart';

class NotificationRepository {
  final NotificationLocalDataSource _localDataSource;
  static const String _baseUrl = 'http://192.168.100.110:8001/api/v1';

  NotificationRepository(this._localDataSource);

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<ReportNotification>> getNotifications() async {
    if (await _isOnline()) {
      try {
        final token = await AuthService.getToken();
        if (token == null) throw Exception('Not authenticated');
        
        final response = await http.get(
          Uri.parse('$_baseUrl/notifications/'),
          headers: {'Authorization': 'Bearer $token'},
        );
        
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final notifications = data.map((e) => ReportNotification.fromJson(e)).toList();
          
          for (var notification in notifications) {
            await _localDataSource.saveNotification(notification);
          }
          return notifications;
        }
        return await _localDataSource.getNotifications();
      } catch (e) {
        return await _localDataSource.getNotifications();
      }
    } else {
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
        final token = await AuthService.getToken();
        if (token != null) {
          await http.post(
            Uri.parse('$_baseUrl/notifications/mark-read/$notificationId/'),
            headers: {'Authorization': 'Bearer $token'},
          );
        }
      } catch (e) {
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
            final token = await AuthService.getToken();
            if (token != null) {
              await http.post(
                Uri.parse('$_baseUrl/notifications/mark-read/${data['id']}/'),
                headers: {'Authorization': 'Bearer $token'},
              );
              await _localDataSource.clearQueuedAction(action['id']);
            }
          } catch (e) {
            debugPrint('Sync error: $e');
          }
        }
      }
    }
  }
}