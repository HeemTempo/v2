import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/graphql/auth_mutation.dart';
import '../api/graphql/graphql_service.dart';
import '../model/user_model.dart';

class AuthService {
  final GraphQLService _graphQLService = GraphQLService();
  static const String _tokenKey = 'auth_access_token';
  static const _storage = FlutterSecureStorage();

  // Sanitize input to prevent injection attacks
  String _sanitizeInput(String input) {
    return input.replaceAll(RegExp(r'[<>;]'), '');
  }

  Future<User> register({
    required String username,
    required String password,
    required String confirmPassword,
    String? email,
    String? ward,
  }) async {
    final sanitizedUsername = _sanitizeInput(username);
    final sanitizedEmail = email != null ? _sanitizeInput(email) : null;
    final sanitizedWard = ward != null ? _sanitizeInput(ward) : null;

    final result = await _graphQLService.mutate(
      registerMutation,
      variables: {
        "input": {
          "username": sanitizedUsername,
          "email": sanitizedEmail ?? "",
          "password": password, // Password handled securely by backend
          "passwordConfirm": confirmPassword,
          "role": "user",
          "sessionId": "",
          "ward": sanitizedWard ?? "",
        }
      },
    );

    if (result.hasException) {
      throw Exception("Registration failed");
    }

    final data = result.data!["registerUser"];
    final output = data["output"];

    if (output == null || output["success"] == false) {
      print(output);
      throw Exception(
          output != null ? output["message"] : "Registration failed.");
    }

    final user = output["user"] ?? data["user"];
    if (user == null) {
      throw Exception("Registration succeeded but no user data returned.");
    }

    return User.fromRegisterJson(user);
  }

  Future<Map<String, dynamic>?> login(String username, String password, {int retryCount = 3}) async {
    final sanitizedUsername = _sanitizeInput(username);
    int attempts = 0;
    while (attempts < retryCount) {
      attempts++;
      try {
        print('AuthService: Login attempt $attempts/$retryCount for username: $sanitizedUsername');
        final result = await _graphQLService.mutate(
          loginMutation,
          variables: {
            "input": {
              "username": sanitizedUsername,
              "password": password,
            },
          },
        );

        if (result.hasException) {
          print('AuthService Login Exception: ${result.exception}');
          if (result.exception.toString().contains('TimeoutException') && attempts < retryCount) {
            print('AuthService: Timeout detected, retrying after 2s...');
            await Future.delayed(Duration(seconds: 2));
            continue;
          }
          throw Exception("Login failed");
        }

        final output = result.data?['loginUser']?['output'];
        print('AuthService Login response output: $output');

        if (output == null || output['success'] != true) {
          throw Exception(output?['message'] ?? "Login failed, no success response.");
        }

        final accessToken = output['user']?['accessToken'] as String?;
        final refreshToken = output['user']?['refreshToken'] as String?;
        if (accessToken != null) {
          await _storage.write(key: _tokenKey, value: accessToken);
          print('AuthService: AccessToken stored securely');
        } else {
          print('AuthService Warning: No accessToken found in login response');
          throw Exception('Login successful, no accessToken found.');
        }

        return output;
      } catch (e) {
        print('AuthService Login Error (Attempt $attempts/$retryCount): $e');
        if (e.toString().contains('TimeoutException') && attempts < retryCount) {
          await Future.delayed(Duration(seconds: 2));
          continue;
        }
        if (e.toString().contains('SocketException')) {
          throw Exception('Network error: Please check your internet connection.');
        }
        throw Exception('Login failed');
      }
    }
    throw Exception('Login failed after attempts due to timeout.');
  }

  static Future<String?> getToken() async {
    print('AuthService: Retrieving token from secure storage');
    final token = await _storage.read(key: _tokenKey);
    print('AuthService: Token: $token');
    return token;
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    print('AuthService: Token removed (logged out).');
  }
}