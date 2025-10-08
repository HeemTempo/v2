import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:openspace_mobile_app/model/Notification.dart';

import 'auth_service.dart';

class NotificationService {
  // 🔹 Full URL for your REST notifications endpoint
  static const String _notificationsUrl = 'https://127.0.0.1:8001/api/v1/notifications/';

  /// 🔹 Fetch notifications for the logged-in user
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
}
