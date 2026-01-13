
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Report.dart';
import 'auth_service.dart';

import 'package:kinondoni_openspace_app/config/app_config.dart';

class ReportService {
  static String get baseUrl => AppConfig.baseUrl.endsWith('/') ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1) : AppConfig.baseUrl;
  static const String endpoint = '/api/v1/user-reports/';

  Future<List<Report>> fetchUserReports() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Report.fromRestJson(json)).toList();
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load reports');
    }
  }
}
