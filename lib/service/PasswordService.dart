import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class PasswordService {
  final String _baseUrl = '${AppConfig.baseUrl}api/v1';

  Future<String> requestPasswordReset(String email) async {
    final Uri url = Uri.parse('$_baseUrl/password-reset/');

    try {
      print('AuthService: Requesting password reset for email: $email');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('AuthService: Password reset request response status: ${response.statusCode}');
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['message'] != null) {
        return responseBody['message'];
      } else if (responseBody['error'] != null) {
        throw Exception(responseBody['error']);
      } else {
        throw Exception('Failed to request password reset. Status: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      print('AuthService: Request password reset timed out.');
      throw Exception('The request timed out. Please try again.');
    } catch (e) {
      print('AuthService: Error requesting password reset - $e');
      if (e is Exception && e.toString().contains("timed out")) {
        rethrow;
      }
      throw Exception('An error occurred');
    }
  }

  Future<String> confirmPasswordReset({
    required String uid,
    required String token,
    required String newPassword,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/password-reset-confirm/');

    try {
      print('AuthService: Confirming password reset with uid: $uid');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'token': token,
          'password': newPassword,
        }),
      );

      print('AuthService: Confirm password reset response status: ${response.statusCode}');
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['message'] != null) {
        return responseBody['message'];
      } else if (responseBody['error'] != null) {
        throw Exception(responseBody['error']);
      } else {
        throw Exception('Failed to confirm password reset');
      }
    } on TimeoutException catch (_) {
      print('AuthService: Confirm password reset timed out.');
      throw Exception('The request timed out. Please try again.');
    } catch (e) {
      print('AuthService: Error confirming password reset - $e');
      if (e is Exception && e.toString().contains("timed out")) {
        rethrow;
      }
      throw Exception('An error occurred');
    }
  }
}