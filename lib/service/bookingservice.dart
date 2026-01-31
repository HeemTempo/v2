import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kinondoni_openspace_app/config/app_config.dart';
import 'package:kinondoni_openspace_app/model/Booking.dart';
import 'package:kinondoni_openspace_app/service/auth_service.dart';

class BookingService {
  final String _baseUrl;
  final String _createBookingEndpoint = '/api/v1/book-open-space/';
  final String _myBookingsEndpoint = '/api/v1/my-bookings/';
  String? _lastError;

  BookingService({String? baseUrl})
      : _baseUrl = baseUrl ?? AppConfig.baseUrl;

  String? get lastError => _lastError;

  // Sanitize input to prevent injection attacks
  String _sanitizeInput(String input) {
    return input.replaceAll(RegExp(r'[<>;]'), '');
  }

  Future<String?> _getAuthToken() async {
    _lastError = null;
    final String? token = await AuthService.getToken();
    if (token == null) {
      _lastError = 'Authentication token not found. Please log in.';
      print('BookingService: $_lastError');
    }
    return token;
  }

  Future<bool> createBooking({
  required int spaceId,
  required String username,
  required String contact,
  required String startDate,
  String? endDate,
  required String purpose,
  required String district,
  File? file,
  String? authToken,
}) async {
  _lastError = null;
  final String? token = authToken ?? await _getAuthToken();
  if (token == null) {
    throw Exception(_lastError ?? 'Authentication required.');
  }

  final sanitizedUsername = _sanitizeInput(username);
  final sanitizedContact = _sanitizeInput(contact);
  final sanitizedPurpose = _sanitizeInput(purpose);
  final sanitizedDistrict = _sanitizeInput(district);
  final sanitizedEndDate = endDate != null ? _sanitizeInput(endDate) : null;

  final Uri url = Uri.parse('$_baseUrl$_createBookingEndpoint');
  print('BookingService: Creating booking at $url with startDate=$startDate, endDate=$sanitizedEndDate');

  try {
    http.Response response;
    final Map<String, String> commonHeaders = {
      'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> fields = {
      'space_id': spaceId,
      'username': sanitizedUsername,
      'contact': sanitizedContact,
      'startdate': startDate,
      'purpose': sanitizedPurpose,
      'district': sanitizedDistrict,
    };
    if (sanitizedEndDate != null && sanitizedEndDate.isNotEmpty) {
      fields['enddate'] = sanitizedEndDate;
    }

    if (file != null) {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(commonHeaders);
      request.fields.addAll(
        fields.map((key, value) => MapEntry(key, value.toString())),
      );
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      print(
        'BookingService: Sending multipart request with fields: ${request.fields}, file: ${file.path}',
      );
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      response = await http.Response.fromStream(streamedResponse);
    } else {
      final Map<String, String> headers = {
        ...commonHeaders,
        'Content-Type': 'application/json; charset=UTF-8',
      };
      print(
        'BookingService: Sending JSON request with body: ${jsonEncode(fields)}',
      );
      response = await http
          .post(url, headers: headers, body: jsonEncode(fields))
          .timeout(const Duration(seconds: 20));
    }

    print(
      'BookingService: CreateBooking Response Status: ${response.statusCode}, Body: ${response.body}',
    );

    if (response.statusCode == 201) {
      print('BookingService: Booking created successfully.');
      return true;
    } else {
      String serverMessage = "Failed to create booking.";
      try {
        final decodedBody = jsonDecode(response.body);
        if (decodedBody is Map) {
          if (decodedBody.containsKey('detail')) {
            serverMessage = decodedBody['detail'].toString();
          } else {
            StringBuffer errors = StringBuffer();
            decodedBody.forEach((key, value) {
              errors.writeln(
                '$key: ${value is List ? value.join(', ') : value.toString()}',
              );
            });
            serverMessage = errors.isNotEmpty ? errors.toString().trim() : jsonEncode(decodedBody);
          }
        } else if (decodedBody is List) {
          serverMessage = decodedBody.join(", ");
        } else {
          serverMessage = response.body.isNotEmpty ? response.body : "Status ${response.statusCode}";
        }
      } catch (_) {
        serverMessage = response.body.isNotEmpty ? response.body : "Status ${response.statusCode}";
      }
      _lastError = 'Failed to create booking (Status ${response.statusCode}): $serverMessage';
      print('BookingService: $_lastError');
      throw Exception(_lastError);
    }
  } on http.ClientException {
    _lastError = 'Network error: Could not connect to create booking';
    print('BookingService: ClientException: $_lastError');
    throw Exception(_lastError);
  } catch (e, stackTrace) {
    _lastError = 'Error creating booking: $e';
    print('BookingService: $_lastError\nStackTrace: $stackTrace');
    throw Exception(_lastError);
  }
}

  Future<List<Booking>> fetchMyBookings() async {
    _lastError = null;
    final String? token = await _getAuthToken();
    if (token == null) {
      throw Exception(_lastError ?? 'Authentication required.');
    }

    final Uri url = Uri.parse('$_baseUrl$_myBookingsEndpoint');
    print('BookingService: Fetching user bookings from $url');

    try {
      final response = await http
          .get(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      )
          .timeout(const Duration(seconds: 15));

      print('BookingService: fetchMyBookings Status: ${response.statusCode}');
      print('BookingService: fetchMyBookings Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Booking> bookings =
        jsonData.map((json) => Booking.fromJson(json)).toList();
        return bookings;
      } else {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey('detail')) {
          }
        } catch (_) {}
        _lastError = 'Fetch bookings failed';
        print('BookingService: $_lastError');
        throw Exception(_lastError);
      }
    } on SocketException {
      _lastError = 'No internet connection';
      print('BookingService: $_lastError');
      throw Exception(_lastError);
    } catch (e) {
      _lastError = 'Unexpected error while fetching bookings';
      print('BookingService: $_lastError');
      throw Exception(_lastError);
    }
  }
}
