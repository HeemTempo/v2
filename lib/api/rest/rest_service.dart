import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:kinondoni_openspace_app/config/app_config.dart';
import 'package:kinondoni_openspace_app/utils/error_handler.dart' as app_error;

class RestService {
  final String baseUrl = "${AppConfig.baseUrl}api/";

  Future<dynamic> getRequest(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException('HTTP ${response.statusCode}');
      }
    } on SocketException {
      throw Exception(app_error.AppErrorHandler.getUserFriendlyMessage('SocketException'));
    } on TimeoutException {
      throw Exception(app_error.AppErrorHandler.getUserFriendlyMessage('TimeoutException'));
    } catch (e) {
      throw Exception(app_error.AppErrorHandler.getUserFriendlyMessage(e));
    }
  }
}
