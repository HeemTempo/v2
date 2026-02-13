import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:quickalert/quickalert.dart';

class AppErrorHandler {
  static const String _offlineMessage =
      "Sorry, you can't get any data right now because you're offline.";

  static bool _looksLikeOffline(dynamic error) {
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('clientexception') ||
        message.contains('network is unreachable') ||
        message.contains('connection failed') ||
        message.contains('connection refused') ||
        message.contains('no internet');
  }

  static bool _looksLikeTimeout(dynamic error) {
    final message = error.toString().toLowerCase();
    return message.contains('timeoutexception') ||
        message.contains('timed out') ||
        message.contains('timeout');
  }

  static String getUserFriendlyMessage(dynamic error) {
    // Some callers pass strings like 'SocketException' / 'TimeoutException'
    // (e.g., RestService); normalize those first.
    if (error is String) {
      if (_looksLikeOffline(error)) return _offlineMessage;
      if (_looksLikeTimeout(error)) {
        return "Request timed out. Please try again.";
      }
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "Connection timeout. Please check your internet connection.";
        case DioExceptionType.sendTimeout:
          return "Request timeout. Please try again later.";
        case DioExceptionType.receiveTimeout:
          return "Response timeout. Please try again later.";
        case DioExceptionType.badResponse:
          return "Server error: ${error.response?.statusCode}. Please try again.";
        case DioExceptionType.cancel:
          return "Request cancelled.";
        case DioExceptionType.connectionError:
          return _offlineMessage;
        default:
          return "An unexpected network error occurred.";
      }
    } else if (error is FormatException) {
      return "Data format error. Please try again.";
    } else {
      if (_looksLikeOffline(error)) return _offlineMessage;
      if (_looksLikeTimeout(error)) {
        return "Request timed out. Please try again.";
      }
      return error.toString().isNotEmpty
          ? error.toString()
          : "An unexpected error occurred. Please try again.";
    }
  }

  static void showError(BuildContext context, dynamic error, {String? title}) {
    final message = getUserFriendlyMessage(error);
    final isOffline = message == _offlineMessage || _looksLikeOffline(error);

    // Check if we can use the QuickAlert or custom dialog
    // Assuming showErrorDialog uses QuickAlert or similar internally based on existing imports
    // If showErrorDialog is simple, we might want to use QuickAlert directly here for better UI

    QuickAlert.show(
      context: context,
      type: isOffline ? QuickAlertType.info : QuickAlertType.error,
      title: title ?? (isOffline ? "Offline" : "Error"),
      text: message,
      confirmBtnText: 'Okay',
      confirmBtnColor: Theme.of(context).primaryColor,
    );
  }
}
