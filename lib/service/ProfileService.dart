import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../service/auth_service.dart';

class ProfileService {
  final String _baseUrl = AppConfig.baseUrl;
  final String _profileEndpoint = 'api/v1/profile/';

  Future<Map<String, dynamic>> fetchProfile(String token) async {
    if (token.isEmpty) {
      throw Exception('Please log in to access your profile.');
    }

    final Uri profileUri = Uri.parse('$_baseUrl$_profileEndpoint');
    print('ProfileService: Fetching profile from $profileUri');

    try {
      final response = await http.get(
        profileUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('ProfileService: Response Status Code: ${response.statusCode}');
      print('ProfileService: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthService.logout();
        throw Exception('Authentication error: Please log in again.');
      } else {
        throw Exception('Failed to load profile');
      }
    } on http.ClientException catch (e) {
      print('ProfileService: ClientException - $e');
      throw Exception('Network error or server unreachable');
    } catch (e) {
      print('ProfileService: Error fetching profile');
      throw Exception('An unexpected error occurred');
    }
  }
}
