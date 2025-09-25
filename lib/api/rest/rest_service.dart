import 'package:http/http.dart' as http;
import 'dart:convert';

class RestService {
  final String baseUrl = 'http://172.19.7.22:8001/api/';

  Future<dynamic> getRequest(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
