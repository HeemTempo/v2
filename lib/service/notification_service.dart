import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:openspace_mobile_app/model/Notification.dart';
import 'package:openspace_mobile_app/service/auth_service.dart';


class NotificationService {
  static const String _baseUrl = 'http://192.168.1.132:8001/api/v1';
  static const String _notificationsUrl = '$_baseUrl/notifications/';
  static const String _markReadUrl = '$_baseUrl/notifications/mark-read/';

  Future<List<ReportNotification>> fetchNotifications() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not logged in.');

      final url = Uri.parse(_notificationsUrl);
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ReportNotification.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to fetch notifications. (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('NotificationService error: $e');
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not logged in.');

      final url = Uri.parse('$_markReadUrl$notificationId/');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'is_read': true}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read. (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('NotificationService mark as read error: $e');
      rethrow;
    }
  }
}