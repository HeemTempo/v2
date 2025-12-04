import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../service/auth_service.dart';

class FileUploadService {
  final String _baseUrl = AppConfig.baseUrl;
  final String _uploadEndpoint = 'api/v1/uploads/';

  Future<String?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    String? reportId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please log in to upload files.');
      }

      var uri = Uri.parse('$_baseUrl$_uploadEndpoint');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );
      if (reportId != null) {
        request.fields['reportId'] = reportId;
      }

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString(); // Also timeout reading the stream
        var decodedResponse = jsonDecode(responseData);
        print("File upload successful (raw decoded): $decodedResponse");
        if (decodedResponse is Map && decodedResponse.containsKey('file_path')) {
          print("Extracted file_path: ${decodedResponse['file_path']}");
          return decodedResponse['file_path'] as String?;
        } else {
          print("ERROR: 'file_path' key not found in response or response is not a Map.");
          throw Exception("Invalid response format from file server."); // Throw a specific error
        }
      } else {
        print("File upload failed with status: ${response.statusCode}");
        var errorBody = await response.stream.bytesToString();
        print("Error response body");
        // Throw a specific error based on status code for better handling later
        throw Exception("File upload failed");
      }
    } on TimeoutException catch (_) {
      print("Error uploading file: Request timed out.");
      throw Exception("The file upload timed out. Please try again.");
    } catch (e) {
      print("Error uploading file: $e");
      if (e is Exception && e.toString().contains("timed out")) { // Check if it's already a timeout message
        throw Exception("The file upload timed out. Please try again.");
      }
      throw Exception("An error occurred during file upload.");
    }
  }
}