// models/booking_model.dart (or booking_request.dart if you prefer)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date parsing and formatting, if needed for display

class Booking {
  // Fields based on your OpenSpaceBooking Django model
  final String
  id; // Assuming your API sends an 'id' for each booking when fetched
  final int spaceId; // From space ForeignKey (ID)
  final String? userId; // From user ForeignKey (ID), nullable
  final String username;
  final String contact;
  final DateTime startDate; // Parsed from 'startdate' string
  final DateTime? endDate; // Parsed from 'enddate' string, nullable
  final String purpose;
  final String district;
  final String? fileUrl; // URL of the uploaded file, nullable
  final DateTime createdAt; // Parsed from 'created_at' string
  final String status; // e.g., 'pending', 'accepted', 'rejected'

  Booking({
    required this.id,
    required this.spaceId,
    this.userId,
    required this.username,
    required this.contact,
    required this.startDate,
    this.endDate,
    required this.purpose,
    required this.district,
    this.fileUrl,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'space': spaceId,
      'username': username,
      'contact': contact,
      'startdate': DateFormat('yyyy-MM-dd').format(startDate),
      'purpose': purpose,
      'district': district,
    };
    if (endDate != null) {
      data['enddate'] = DateFormat('yyyy-MM-dd').format(endDate!);
    }
    return data;
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        debugPrint("Error parsing date string '$dateStr': $e");
        return null;
      }
    }

    final DateTime parsedStartDate =
        parseDate(json['startdate']) ?? DateTime.now();
    final DateTime? parsedEndDate = parseDate(json['enddate']);
    final DateTime parsedCreatedAt =
        parseDate(json['created_at']) ?? DateTime.now();

    // Handle space_id or space, ensuring it's an integer
    final int spaceIdFromJson =
        (json['space'] is int)
            ? json['space']
            : (json['space'] is String
                ? int.tryParse(json['space'] ?? '') ?? 0
                : (json['space_id'] ?? 0));

    final String? userIdFromJson = json['user']?.toString();

    // Require startdate to be present and valid
    if (json['startdate'] == null || json['startdate'].toString().isEmpty) {
      print("Error: Booking JSON missing or invalid 'startdate'. JSON: $json");
      throw Exception("Invalid booking data: startdate is required.");
    }

    if (json['id'] == null) {
      print(
        "Warning: Booking JSON missing 'id'. Using temporary ID. JSON: $json",
      );
    }

    return Booking(
      id:
          json['id']?.toString() ??
          'temp_id_${DateTime.now().millisecondsSinceEpoch}',
      spaceId: spaceIdFromJson,
      userId: userIdFromJson,
      username: json['username']?.toString() ?? 'N/A',
      contact: json['contact']?.toString() ?? 'N/A',
      startDate: parsedStartDate,
      endDate: parsedEndDate,
      purpose: json['purpose']?.toString() ?? 'No purpose specified',
      district: json['district']?.toString() ?? 'Kinondoni',
      fileUrl: json['file']?.toString(),
      createdAt: parsedCreatedAt,
      status: json['status']?.toString().toLowerCase() ?? 'pending',
    );
  }

  int get calculatedDurationInDays {
    if (endDate == null) {
      return 1;
    }
    if (endDate!.isBefore(startDate)) {
      return 1;
    }
    return endDate!.difference(startDate).inDays + 1;
  }
}
