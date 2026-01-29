import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:quickalert/quickalert.dart';

class AppErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
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
          return "No internet connection. Please check your network.";
        default:
          return "An unexpected network error occurred.";
      }
    } else if (error is FormatException) {
      return "Data format error. Please try again.";
    } else {
      return error.toString().isNotEmpty 
          ? error.toString() 
          : "An unexpected error occurred. Please try again.";
    }
  }

  static void showError(BuildContext context, dynamic error, {String? title}) {
    final message = getUserFriendlyMessage(error);
    
    // Check if we can use the QuickAlert or custom dialog
    // Assuming showErrorDialog uses QuickAlert or similar internally based on existing imports
    // If showErrorDialog is simple, we might want to use QuickAlert directly here for better UI
    
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: title ?? "Error",
      text: message,
      confirmBtnText: 'Okay',
      confirmBtnColor: Theme.of(context).primaryColor,
    );
  }
}
