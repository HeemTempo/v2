
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Report.dart';
import 'auth_service.dart';

class ReportService {
  static const String baseUrl = 'http://192.168.1.132:8001';
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
