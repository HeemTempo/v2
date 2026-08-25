import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class PasswordServiceException implements Exception {
  const PasswordServiceException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class PasswordService {
  PasswordService({
    http.Client? client,
    String? baseUrl,
    this.requestTimeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _baseUrl = (baseUrl ?? '${AppConfig.baseUrl}api/v1').replaceFirst(
         RegExp(r'/+$'),
         '',
       );

  final http.Client _client;
  final String _baseUrl;
  final Duration requestTimeout;

  Future<String> requestPasswordReset(String email) async {
    final Uri url = Uri.parse('$_baseUrl/password-reset/');

    try {
      final response = await _client
          .post(
            url,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim(), 'client': 'mobile'}),
          )
          .timeout(requestTimeout);

      return _messageFromResponse(
        response,
        fallback: 'Unable to request a password reset right now.',
      );
    } on PasswordServiceException {
      rethrow;
    } on TimeoutException {
      throw const PasswordServiceException(
        'The request timed out. Please try again.',
      );
    } on http.ClientException {
      throw const PasswordServiceException(
        'Unable to connect to the server. Check your internet connection.',
      );
    } catch (_) {
      throw const PasswordServiceException(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<String> confirmPasswordReset({
    required String uid,
    required String token,
    required String newPassword,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/password-reset-confirm/');

    try {
      final response = await _client
          .post(
            url,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'uid': uid,
              'token': token,
              'password': newPassword,
            }),
          )
          .timeout(requestTimeout);

      return _messageFromResponse(
        response,
        fallback: 'Unable to reset the password right now.',
      );
    } on PasswordServiceException {
      rethrow;
    } on TimeoutException {
      throw const PasswordServiceException(
        'The request timed out. Please try again.',
      );
    } on http.ClientException {
      throw const PasswordServiceException(
        'Unable to connect to the server. Check your internet connection.',
      );
    } catch (_) {
      throw const PasswordServiceException(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  String _messageFromResponse(
    http.Response response, {
    required String fallback,
  }) {
    Map<String, dynamic> body = const {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    } on FormatException {
      // The status-aware fallback below handles proxy or malformed responses.
    }

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    final message = body['message'];
    if (isSuccess && message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    final error = body['error'];
    if (error is String && error.trim().isNotEmpty) {
      throw PasswordServiceException(
        error.trim(),
        statusCode: response.statusCode,
      );
    }

    throw PasswordServiceException(
      '$fallback (Status ${response.statusCode})',
      statusCode: response.statusCode,
    );
  }
}
