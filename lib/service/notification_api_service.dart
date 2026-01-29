import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kinondoni_openspace_app/config/app_config.dart';
import 'package:kinondoni_openspace_app/model/Notification.dart';
import 'package:kinondoni_openspace_app/service/auth_service.dart';

class NotificationApiService {
  final String _baseUrl;
  final String _notificationsEndpoint = '/api/v1/notifications/';
  final String _markReadEndpoint = '/api/v1/notifications/mark-read';
  String? _lastError;

  NotificationApiService({String? baseUrl})
      : _baseUrl = baseUrl ?? AppConfig.baseUrl;

  String? get lastError => _lastError;

  Future<String?> _getAuthToken() async {
    _lastError = null;
    final String? token = await AuthService.getToken();
    if (token == null) {
      _lastError = 'Authentication token not found. Please log in.';
      print('NotificationApiService: $_lastError');
    }
    return token;
  }

  /// Fetch all notifications for the authenticated user
  Future<List<ReportNotification>> fetchNotifications() async {
    _lastError = null;
    final String? token = await _getAuthToken();
    if (token == null) {
      throw Exception(_lastError ?? 'Authentication required.');
    }

    final Uri url = Uri.parse('$_baseUrl$_notificationsEndpoint');
    print('NotificationApiService: Fetching notifications from $url');

    try {
      final response = await http
          .get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      )
          .timeout(const Duration(seconds: 15));

      print('NotificationApiService: fetchNotifications Status: ${response.statusCode}');
      print('NotificationApiService: fetchNotifications Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<ReportNotification> notifications =
            jsonData.map((json) => ReportNotification.fromJson(json)).toList();
        print('NotificationApiService: Successfully fetched ${notifications.length} notifications');
        return notifications;
      } else {
        String errorMessage = 'Failed to fetch notifications';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('detail')) {
            errorMessage = decoded['detail'];
          } else if (decoded is Map && decoded.containsKey('message')) {
            errorMessage = decoded['message'];
          }
        } catch (_) {
          errorMessage = response.body.isNotEmpty 
              ? response.body 
              : 'Failed to fetch notifications (Status ${response.statusCode})';
        }
        _lastError = errorMessage;
        print('NotificationApiService: $_lastError');
        throw Exception(_lastError);
      }
    } on SocketException {
      _lastError = 'No internet connection. Unable to fetch notifications.';
      print('NotificationApiService: $_lastError');
      throw Exception(_lastError);
    } on http.ClientException {
      _lastError = 'Network error: Could not connect to notifications server';
      print('NotificationApiService: ClientException: $_lastError');
      throw Exception(_lastError);
    } catch (e, stackTrace) {
      if (e is Exception && e.toString().contains('Exception: ')) {
        rethrow; // Already formatted exception
      }
      _lastError = 'Unexpected error while fetching notifications: $e';
      print('NotificationApiService: $_lastError\nStackTrace: $stackTrace');
      throw Exception(_lastError);
    }
  }

  /// Mark a notification as read
  Future<bool> markNotificationAsRead(int notificationId) async {
    _lastError = null;
    final String? token = await _getAuthToken();
    if (token == null) {
      throw Exception(_lastError ?? 'Authentication required.');
    }

    final Uri url = Uri.parse('$_baseUrl$_markReadEndpoint/$notificationId/');
    print('NotificationApiService: Marking notification $notificationId as read at $url');

    try {
      final response = await http
          .post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      )
          .timeout(const Duration(seconds: 10));

      print('NotificationApiService: markAsRead Status: ${response.statusCode}');
      print('NotificationApiService: markAsRead Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('NotificationApiService: Notification marked as read successfully');
        return true;
      } else {
        String errorMessage = 'Failed to mark notification as read';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('detail')) {
            errorMessage = decoded['detail'];
          } else if (decoded is Map && decoded.containsKey('message')) {
            errorMessage = decoded['message'];
          }
        } catch (_) {
          errorMessage = 'Status ${response.statusCode}';
        }
        _lastError = errorMessage;
        print('NotificationApiService: $_lastError');
        throw Exception(_lastError);
      }
    } on SocketException {
      _lastError = 'No internet connection';
      print('NotificationApiService: $_lastError');
      throw Exception(_lastError);
    } on http.ClientException {
      _lastError = 'Network error: Could not connect to server';
      print('NotificationApiService: ClientException: $_lastError');
      throw Exception(_lastError);
    } catch (e, stackTrace) {
      if (e is Exception && e.toString().contains('Exception: ')) {
        rethrow;
      }
      _lastError = 'Unexpected error: $e';
      print('NotificationApiService: $_lastError\nStackTrace: $stackTrace');
      throw Exception(_lastError);
    }
  }

  /// Mark multiple notifications as read in batch
  Future<bool> markMultipleAsRead(List<int> notificationIds) async {
    _lastError = null;
    final String? token = await _getAuthToken();
    if (token == null) {
      throw Exception(_lastError ?? 'Authentication required.');
    }

    bool allSuccess = true;
    for (final id in notificationIds) {
      try {
        await markNotificationAsRead(id);
      } catch (e) {
        print('NotificationApiService: Failed to mark notification $id as read: $e');
        allSuccess = false;
      }
    }

    return allSuccess;
  }
}
