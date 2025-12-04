import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:openspace_mobile_app/config/app_config.dart';

class RestService {
  final String baseUrl = "${AppConfig.baseUrl}api/";

  Future<dynamic> getRequest(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
