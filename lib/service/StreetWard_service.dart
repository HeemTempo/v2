import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  final String baseUrl = "https://127.0.0.1:8001/api/v1"; 

  Future<List<Map<String, dynamic>>> getWards() async {
    final response = await http.get(Uri.parse('$baseUrl/wards'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => {"id": e["id"].toString(), "name": e["name"]}).toList();
    } else {
      throw Exception("Failed to fetch wards");
    }
  }

  Future<List<Map<String, dynamic>>> getStreets() async {
    final response = await http.get(Uri.parse('$baseUrl/streets'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => {"id": e["id"].toString(), "name": e["name"]}).toList();
    } else {
      throw Exception("Failed to fetch streets");
    }
  }
}
