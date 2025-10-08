import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openspace_mobile_app/api/graphql/auth_mutation.dart';
import '../api/graphql/graphql_service.dart';
import '../model/user_model.dart';

class AuthService {
  final GraphQLService _graphQLService = GraphQLService();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _lastLoginKey = 'auth_last_login';
  static const _hasLoggedInBeforeKey = 'auth_has_logged_in_before';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// 🔹 Sanitize text fields to avoid injection
  String _sanitize(String input) => input.replaceAll(RegExp(r'[<>;]'), '');

  /// 🔹 Check if user has ever logged in before
  Future<bool> hasLoggedInBefore() async =>
      (await _storage.read(key: _hasLoggedInBeforeKey)) == 'true';

  /// 🔹 Register user online
  Future<User> register({
    required String username,
    required String password,
    required String confirmPassword,
    String? email,
    String? role,
    String? ward, // still allowed but ignored in mutation
    String? street, // still allowed but ignored in mutation
  }) async {
    final variables = {
      "username": _sanitize(username),
      "email": email != null ? _sanitize(email) : null,
      "password": password,
      "passwordConfirm": confirmPassword,
      "sessionId": "", // still part of mutation
    };

    final result = await _graphQLService.mutate(
      REGISTER_USER,
      variables: variables,
    );

    if (result.hasException) {
      throw Exception(_extractErrorMessage(result.exception.toString()));
    }

    final output = result.data?["registerUser"]?["output"];
    if (output == null || output["success"] != true) {
      throw Exception(output?["message"] ?? "Registration failed.");
    }

    return User.fromRegisterJson(output["user"]);
  }

  Future<User> login(
    String username,
    String password, {
    int retryCount = 3,
  }) async {
    final sanitizedUsername = _sanitize(username);
    int attempts = 0;
    Exception? lastError;

    while (attempts < retryCount) {
      attempts++;
      try {
        final result = await _graphQLService.mutate(
          LOGIN_USER_AGAIN,
          variables: {"username": sanitizedUsername, "password": password},
        );

        final data = result.data?['loginUser'];

        // Null-safe checks
        if (data == null ||
            data['success'] == null ||
            data['success'] != true) {
          throw Exception(data?['message'] ?? "Login failed.");
        }

        final userJson = data['user'];
        if (userJson == null)
          throw Exception("Login failed: missing user data.");

        var user = User.fromLoginJson({'user': userJson});

        // Assign safe defaults
        user = user.copyWith(
          role: (user.role?.isNotEmpty ?? false) ? user.role : "user",
          isStaff: user.isStaff ?? false,
          isWardExecutive: user.isWardExecutive ?? false,
          isVillageChairman: user.isVillageChairman ?? false,
          isAnonymous: false,
        );

        // Prevent admin/staff login
        if ((user.isStaff ?? false) ||
            ((user.role?.toLowerCase() ?? '') == "admin")) {
          throw Exception("Admins are not allowed to login here.");
        }

        await cacheUserCredentials(user);
        return user;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());

        if (_isNetworkError(e.toString()) && attempts < retryCount) {
          await Future.delayed(Duration(seconds: attempts * 2));
          continue;
        }
        rethrow;
      }
    }

    throw lastError ?? Exception('Login failed after $retryCount attempts.');
  }

  /// 🔹 Offline login (load cached user)
  Future<User?> getOfflineUser() async {
    final token = await _storage.read(key: _tokenKey);
    final userJson = await _storage.read(key: _userKey);
    final lastLoginStr = await _storage.read(key: _lastLoginKey);

    if (token == null || token.isEmpty || userJson == null) return null;

    // Optional expiration check (e.g., 30 days)
    if (lastLoginStr != null) {
      final lastLoginMillis = int.tryParse(lastLoginStr);
      if (lastLoginMillis != null) {
        final lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginMillis);
        if (DateTime.now().difference(lastLogin).inDays > 30) {
          await clearCache();
          return null;
        }
      }
    }

    try {
      final user = User.fromJsonString(userJson);

      return user.copyWith(
        token: token,
        role: (user.role?.isNotEmpty ?? false) ? user.role : "user",
        isStaff: user.isStaff ?? false,
        isWardExecutive: user.isWardExecutive ?? false,
        isVillageChairman: user.isVillageChairman ?? false,
        isAnonymous: false,
      );
    } catch (e) {
      // If parsing fails, clear corrupted cache
      await clearCache();
      return null;
    }
  }

  /// 🔹 Save credentials securely
  Future<void> cacheUserCredentials(User user) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: user.token ?? ''),
      _storage.write(key: _userKey, value: user.toJsonString()),
      _storage.write(
        key: _lastLoginKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
      _storage.write(key: _hasLoggedInBeforeKey, value: 'true'),
    ]);
  }

  /// 🔹 Logout (keeps login history flag)
  static Future<void> logout() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userKey),
      _storage.delete(key: _lastLoginKey),
    ]);
  }

  /// 🔹 Clear all cache
  static Future<void> clearCache() async => _storage.deleteAll();

  /// 🔹 Get token for authenticated requests
  static Future<String?> getToken() async => _storage.read(key: _tokenKey);

  /// 🔹 Network error check
  bool _isNetworkError(String error) {
    final networkErrors = [
      'timeout',
      'network',
      'connection',
      'socket',
      'failed host lookup',
    ];
    final lower = error.toLowerCase();
    return networkErrors.any((e) => lower.contains(e));
  }

  /// 🔹 Clean error message
  String _extractErrorMessage(String error) =>
      error.replaceFirst('Exception: ', '').replaceFirst('Error: ', '').trim();

  // Your _sanitize method here
}
