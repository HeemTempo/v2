import 'package:openspace_mobile_app/model/user_model.dart';

class Report {
  final String id;
  final String reportId;
  final String description;
  final String? email;
  final String? file; // URL or identifier
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? spaceName;
  final User? user; // Can be nullable if user isn't always present// From your getReportById
  final String? status; // From your getReportById

  Report({
    required this.id,
    required this.reportId,
    required this.description,
    this.email,
    this.file,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.spaceName,
    this.user,
    this.status,
  });


  factory Report.fromRestJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['report_id'] == null ||
        json['description'] == null ||
        json['created_at'] == null) {
      print("Error: Report.fromRestJson missing fields. Data: $json");
      throw FormatException("Missing fields in REST response.");
    }

    User? reportUser;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      try {
        reportUser = User.fromReportJson(json['user']);
      } catch (e, s) {
        print("Error parsing user: $e\n$s");
      }
    }

    return Report(
      id: json['id'].toString(),
      reportId: json['report_id'],
      description: json['description'],
      email: json['email'],
      file: json['file'],
      createdAt: DateTime.parse(json['created_at']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      spaceName: json['space_name'],
      user: reportUser,
      status: json['status'],
    );
  }


  factory Report.fromJson(Map<String, dynamic> json) {
    // Basic validation for essential report fields
    if (json['id'] == null ||
        json['reportId'] == null ||
        json['description'] == null ||
        json['createdAt'] == null) {
      print("Error: Report.fromJson missing essential report fields (id, reportId, description, createdAt). Data: $json");
      throw FormatException("Report JSON is missing required fields (id, reportId, description, createdAt).");
    }

    User? reportUser;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      try {
        // Use the specific factory constructor for parsing user data from a report
        reportUser = User.fromReportJson(json['user'] as Map<String, dynamic>);
      } catch (e,s) {
        print("Report.fromJson: Error parsing nested user object. Raw User Data: ${json['user']}. Error: $e\n$s");
        reportUser = null;
      }
    } else if (json['user'] != null) {
      print("Report.fromJson Warning: 'user' field is present but not a valid map (object). Actual type: ${json['user'].runtimeType}. Data: ${json['user']}");
      reportUser = null;
    }

    DateTime? parsedCreatedAt;
    try {
      parsedCreatedAt = DateTime.parse(json['createdAt'] as String);
    } catch (e,s) {
      print("Error: Report.fromJson couldn't parse 'createdAt'. Value: ${json['createdAt']}. Error: $e\n$s");
      throw FormatException("Invalid date format for 'createdAt': ${json['createdAt']}");
    }

    return Report(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      description: json['description'] as String,
      email: json['email'] as String?,
      file: json['file'] as String?,
      createdAt: parsedCreatedAt,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      spaceName: json['spaceName'] as String?,
      user: reportUser, // Assign the parsed (or null) user object
      status: json['status'] as String?,
    );
  }
}
