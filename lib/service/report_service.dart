import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ReportingService {
  static const String _baseUrl = 'http://192.168.0.56:8001/';
  static const String _reportEndpoint = 'api/v1/reports/';

  /// Create a new report (supports optional file)
  static Future<Map<String, dynamic>> createReport({
    required String description,
    String? email,
    File? file, // optional file
    String? spaceName,
    double? latitude,
    double? longitude,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Authentication token missing');

    final uri = Uri.parse('$_baseUrl$_reportEndpoint');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['description'] = description;
    if (email != null) request.fields['email'] = email;
    if (spaceName != null) request.fields['space_name'] = spaceName;
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
