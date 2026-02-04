import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

import 'package:kinondoni_openspace_app/config/app_config.dart';
import '../model/Report.dart';

class ReportingService {
  static String get _baseUrl => AppConfig.baseUrl;
  static const String _reportEndpoint = 'api/v1/reports/';
  static const String _userReportsEndpoint = 'api/v1/user-reports/';

  /// Get all user reports
  static Future<List<Report>> getUserReports() async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('$_baseUrl$_userReportsEndpoint');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Report.fromRestJson(json)).toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthService.logout();
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception('Failed to fetch reports: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching reports: $e');
    }
  }

  /// Create a new report (supports optional file)
  static Future<Map<String, dynamic>> createReport({
    required String description,
    String? email,
    String? phone,
    File? file, // optional file
    String? spaceName,
    String? district,
    String? street,
    String? userId,
    double? latitude,
    double? longitude,
    String? authToken,
  }) async {
    final token = authToken ?? await AuthService.getToken();
    final uri = Uri.parse('$_baseUrl$_reportEndpoint');

    final request = http.MultipartRequest('POST', uri);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add text fields
    request.fields['description'] = description;
    if (email != null && email.isNotEmpty) request.fields['email'] = email;
    if (phone != null && phone.isNotEmpty) request.fields['phone'] = phone;
    if (spaceName != null && spaceName.isNotEmpty) request.fields['space_name'] = spaceName;
    if (district != null && district.isNotEmpty) request.fields['district'] = district;
    if (street != null && street.isNotEmpty) request.fields['street'] = street;
    if (userId != null && userId.isNotEmpty) request.fields['user_id'] = userId;
    if (latitude != null) request.fields['latitude'] = latitude.toString();
    if (longitude != null) request.fields['longitude'] = longitude.toString();

    // Add file if provided
    if (file != null && await file.exists()) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthService.logout();
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception('Failed to submit report: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating report: $e');
    }
  }
}
