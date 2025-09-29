import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openspace_mobile_app/core/network/connectivity_service.dart';
import '../api/graphql/auth_mutation.dart';
import '../api/graphql/graphql_service.dart';
import '../model/user_model.dart';

class AuthService {
  final GraphQLService _graphQLService = GraphQLService();
  static const _tokenKey = 'auth_access_token';
  static const _userKey = 'auth_user_data';
  static const _lastLoginKey = 'auth_last_login_timestamp';
  static const _hasLoggedInBeforeKey = 'auth_has_logged_in_before';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Sanitize input to prevent injection attacks
  String _sanitize(String input) => input.replaceAll(RegExp(r'[<>;]'), '');

  // Check if user has logged in before
  Future<bool> hasLoggedInBefore() async {
    final value = await _storage.read(key: _hasLoggedInBeforeKey);
    return value == 'true';
  }

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
          "password": password,
          "passwordConfirm": confirmPassword,
          "role": "user",
          "sessionId": "",
          "ward": sanitizedWard ?? "",
        },
      },
    );

    if (result.hasException) {
      throw Exception(_extractErrorMessage(result.exception.toString()));
    }

    final data = result.data!["registerUser"];
    final output = data["output"];

    if (output == null || output["success"] == false) {
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

  // ONLINE LOGIN - Must provide username and password
  Future<User> login(
    String username,
    String password, {
    int retryCount = 3,
  }) async {
    final sanitizedUsername = _sanitize(username);
    int attempts = 0;
    Exception? lastException;

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
          final exceptionStr = result.exception.toString();
          if (_isNetworkError(exceptionStr) && attempts < retryCount) {
            await Future.delayed(Duration(seconds: attempts * 2));
            continue;
          }
          throw Exception(_extractErrorMessage(exceptionStr));
        }

        final output = result.data?['loginUser']?['output'];
        if (output == null || output['success'] != true) {
          throw Exception(output?['message'] ?? "Login failed.");
        }

        final user = User.fromLoginJson(output);

        // Cache credentials for future offline access
        await _cacheUserCredentials(user);

        return user;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        if (_isNetworkError(e.toString()) && attempts < retryCount) {
          await Future.delayed(Duration(seconds: attempts * 2));
          continue;
        }
        rethrow;
      }
    }

    throw lastException ?? Exception('Login failed after $retryCount attempts.');
  }

  // Cache user credentials for offline access
  Future<void> _cacheUserCredentials(User user) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: user.accessToken ?? ''),
      _storage.write(key: _userKey, value: user.toJsonString()),
      _storage.write(
        key: _lastLoginKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
      _storage.write(key: _hasLoggedInBeforeKey, value: 'true'),
    ]);
    print('AuthService: User credentials cached for offline access');
  }

  // OFFLINE LOGIN - Uses cached credentials, no username/password needed
  Future<User?> getOfflineUser() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _tokenKey),
        _storage.read(key: _userKey),
        _storage.read(key: _lastLoginKey),
      ]);

      final token = results[0];
      final userJsonStr = results[1];
      final lastLoginStr = results[2];

      if (token == null || userJsonStr == null || token.isEmpty) {
        print('AuthService: No cached credentials found');
        return null;
      }

      // Optional: Check if cached credentials are too old (e.g., 30 days)
      if (lastLoginStr != null) {
        final lastLogin = DateTime.fromMillisecondsSinceEpoch(
          int.parse(lastLoginStr),
        );
        final daysSinceLogin = DateTime.now().difference(lastLogin).inDays;
        
        if (daysSinceLogin > 30) {
          print('AuthService: Cached credentials expired (>30 days)');
          await clearCache();
          return null;
        }
      }

      final user = User.fromJsonString(userJsonStr);
      print('AuthService: Offline user loaded successfully');
      
      return User(
        id: user.id,
        username: user.username,
        accessToken: token,
        isStaff: user.isStaff,
        isWardExecutive: user.isWardExecutive,
        isAnonymous: false,
      );
    } catch (e) {
      print('AuthService: Error loading offline user: $e');
      return null;
    }
  }

  // Check if valid cached credentials exist
  Future<bool> hasCachedCredentials() async {
    final token = await _storage.read(key: _tokenKey);
    final userData = await _storage.read(key: _userKey);
    return token != null && userData != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userKey),
      _storage.delete(key: _lastLoginKey),
      // Keep _hasLoggedInBeforeKey so app knows user has logged in before
    ]);
    print('AuthService: User logged out successfully');
  }

  static Future<void> clearCache() async {
    await _storage.deleteAll();
    print('AuthService: All cache cleared');
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Helper method to check if error is network-related
  bool _isNetworkError(String error) {
    final networkErrors = [
      'timeout',
      'network',
      'connection',
      'socket',
      'failed host lookup',
    ];
    final lowerError = error.toLowerCase();
    return networkErrors.any((e) => lowerError.contains(e));
  }

  // Extract clean error message
  String _extractErrorMessage(String error) {
    return error
        .replaceFirst('Exception: ', '')
        .replaceFirst('Error: ', '')
        .trim();
  }
}