import 'dart:io';
import 'dart:async';

class AppErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network is unreachable')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }

    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return 'Connection timed out. Please try again.';
    }

    if (errorString.contains('connection refused') ||
        errorString.contains('connection reset')) {
      return 'Server is not responding. Please try again later.';
    }

    // HTTP errors
    if (errorString.contains('400')) {
      return 'Invalid request. Please check your input and try again.';
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Access denied. You don\'t have permission to perform this action.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Requested resource not found.';
    }

    if (errorString.contains('500') || errorString.contains('internal server')) {
      return 'Server error. Please try again later.';
    }

    if (errorString.contains('502') || errorString.contains('bad gateway')) {
      return 'Server is temporarily unavailable. Please try again later.';
    }

    if (errorString.contains('503') || errorString.contains('service unavailable')) {
      return 'Service is temporarily unavailable. Please try again later.';
    }

    // GraphQL errors
    if (errorString.contains('graphql')) {
      return 'Unable to process request. Please try again.';
    }

    // Database errors
    if (errorString.contains('database') || errorString.contains('sql')) {
      return 'Data error occurred. Please try again.';
    }

    // Permission errors
    if (errorString.contains('permission')) {
      return 'Permission denied. Please grant necessary permissions.';
    }

    // File errors
    if (errorString.contains('file') && errorString.contains('not found')) {
      return 'File not found. Please try again.';
    }

    // Format errors
    if (errorString.contains('format') || errorString.contains('parse')) {
      return 'Invalid data format. Please try again.';
    }

    // Default message
    return 'Something went wrong. Please try again.';
  }

  static String getErrorType(dynamic error) {
    if (error is SocketException) return 'Network Error';
    if (error is TimeoutException) return 'Timeout Error';
    if (error is FormatException) return 'Format Error';
    if (error is HttpException) return 'Server Error';
    return 'Error';
  }
}
