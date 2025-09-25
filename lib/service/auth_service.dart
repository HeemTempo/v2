import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openspace_mobile_app/core/network/connectivity_service.dart';
import '../api/graphql/auth_mutation.dart';
import '../api/graphql/graphql_service.dart';
import '../model/user_model.dart';

class AuthService {
  final GraphQLService _graphQLService = GraphQLService();
  static const _tokenKey = 'auth_access_token';
  static const _userKey = 'auth_user_data';
  static const _storage = FlutterSecureStorage();

  // Sanitize input to prevent injection attacks
  String _sanitize(String input) => input.replaceAll(RegExp(r'[<>;]'), '');

  Future<User> register({
    required String username,
    required String password,
    required String confirmPassword,
    String? email,
    String? ward,
  }) async {
    final sanitizedUsername = _sanitize(username);
    final sanitizedEmail = email != null ? _sanitize(email) : null;
    final sanitizedWard = ward != null ? _sanitize(ward) : null;

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
        },
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
        output != null ? output["message"] : "Registration failed.",
      );
    }

    final user = output["user"] ?? data["user"];
    if (user == null) {
      throw Exception("Registration succeeded but no user data returned.");
    }

    return User.fromRegisterJson(user);
  }

  Future<User> login(
    String username,
    String password, {
    int retryCount = 3,
  }) async {
    final sanitizedUsername = _sanitize(username);
    int attempts = 0;

    while (attempts < retryCount) {
      attempts++;
      try {
        final result = await _graphQLService.mutate(
          loginMutation,
          variables: {
            "input": {"username": sanitizedUsername, "password": password},
          },
        );

        if (result.hasException) {
          if (result.exception.toString().contains('TimeoutException') &&
              attempts < retryCount) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          throw Exception(result.exception.toString());
        }

        final output = result.data?['loginUser']?['output'];
        if (output == null || output['success'] != true) {
          throw Exception(output?['message'] ?? "Login failed.");
        }

        final user = User.fromLoginJson(output);

        // Save token & minimal user info for offline login
        await _storage.write(key: _tokenKey, value: user.accessToken ?? '');
        await _storage.write(key: _userKey, value: user.toJsonString());

        return user;
      } catch (e) {
        if (e.toString().contains('TimeoutException') &&
            attempts < retryCount) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        throw Exception('Login failed: $e');
      }
    }

    throw Exception('Login failed after $retryCount attempts.');
  }

  Future<User?> loginOffline() async {
    final token = await _storage.read(key: _tokenKey);
    final userJsonStr = await _storage.read(key: _userKey);

    if (token != null && userJsonStr != null) {
      final user = User.fromJsonString(userJsonStr);
      return User(
        id: user.id,
        username: user.username,
        accessToken: token,
        isStaff: user.isStaff,
        isWardExecutive: user.isWardExecutive,
        isAnonymous: false,
      );
    }
    return null; // No cached data available
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    print('AuthService: Token removed (logged out).');
  }

  static Future<String?> getToken() async {
    print('AuthService: Retrieving token from secure storage');
    final token = await _storage.read(key: _tokenKey);
    print('AuthService: Token: $token');
    return token;
  }
}
