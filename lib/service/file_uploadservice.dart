import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FileUploadService {
  final String _uploadUrl = "http://192.168.1.132:8001/api/v1/upload/";


  Future<String?> uploadFile({required String fileName, required Uint8List fileBytes, String? reportId}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

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