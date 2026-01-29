import 'package:kinondoni_openspace_app/model/user_model.dart';

class Report {
  final String id;
  final String reportId;
  final String description;
  final String? email;
  final String? phone;
  final String? file;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? spaceName;
  final String? district;
  final String? street;
  final String? userId; // Store userId as string for payload
  final User? user;
  final String? status;

  Report({
    required this.id,
    required this.reportId,
    required this.description,
    this.email,
    this.phone,
    this.file,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.spaceName,
    this.district,
    this.street,
    this.userId,
    this.user,
    this.status,
  });

  /// Factory for REST API response (from createReport)
  factory Report.fromRestJson(Map<String, dynamic> json, {String? localId}) {
    // Debug: print what we're receiving
    print('DEBUG fromRestJson received: $json');
    
    // Backend returns report_id (snake_case) - handle both formats
    String reportIdValue;
    if (json['report_id'] != null) {
      reportIdValue = json['report_id'].toString();
    } else if (json['reportId'] != null) {
      reportIdValue = json['reportId'].toString();
    } else if (json['id'] != null) {
      reportIdValue = json['id'].toString();
    } else {
      reportIdValue = 'PENDING';
    }
    
    print('DEBUG Extracted reportId: $reportIdValue');
    
    // Parse created_at (backend uses snake_case)
    // Backend may return dates as "05/12/2025 12:24:27" instead of ISO format
    DateTime parsedDate;
    if (json['created_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['created_at']);
      } catch (e) {
        // Try parsing dd/MM/yyyy HH:mm:ss format
        try {
          final dateStr = json['created_at'].toString();
          final parts = dateStr.split(' ');
          if (parts.length == 2) {
            final dateParts = parts[0].split('/');
            final timeParts = parts[1].split(':');
            if (dateParts.length == 3 && timeParts.length == 3) {
              parsedDate = DateTime(
                int.parse(dateParts[2]), // year
                int.parse(dateParts[1]), // month
                int.parse(dateParts[0]), // day
                int.parse(timeParts[0]), // hour
                int.parse(timeParts[1]), // minute
                int.parse(timeParts[2]), // second
              );
            } else {
              parsedDate = DateTime.now();
            }
          } else {
            parsedDate = DateTime.now();
          }
        } catch (parseError) {
          print('Error parsing custom date format: $parseError');
          parsedDate = DateTime.now();
        }
      }
    } else if (json['createdAt'] != null) {
      parsedDate = DateTime.parse(json['createdAt']);
    } else {
      parsedDate = DateTime.now();
    }
    
    return Report(
      id: localId ?? json['id']?.toString() ?? 'local_${DateTime.now().millisecondsSinceEpoch}',
      reportId: reportIdValue,
      description: json['description']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      file: json['file']?.toString(),
      createdAt: parsedDate,
      latitude: json['latitude'] != null 
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null 
          ? (json['longitude'] as num).toDouble()
          : null,
      spaceName: json['space_name']?.toString() ?? json['spaceName']?.toString(),
      district: json['district']?.toString(),
      street: json['street']?.toString(),
      userId: json['user_id']?.toString(),
      status: json['status']?.toString() ?? 'submitted',
      user: null, // REST response typically doesn't include user object
    );
  }

  /// Factory for local database JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['reportId'] == null ||
        json['description'] == null ||
        json['createdAt'] == null) {
      print("Error: Report.fromJson missing essential fields. Data: $json");
      throw FormatException("Report JSON is missing required fields");
    }

    User? reportUser;
    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      try {
        reportUser = User.fromReportJson(json['user'] as Map<String, dynamic>);
      } catch (e, s) {
        print("Report.fromJson: Error parsing user. Error: $e\n$s");
        reportUser = null;
      }
    }

    DateTime? parsedCreatedAt;
    try {
      parsedCreatedAt = DateTime.parse(json['createdAt'] as String);
    } catch (e) {
      print("Error parsing createdAt: ${json['createdAt']}. Error: $e");
      throw FormatException("Invalid date format for 'createdAt'");
    }

    return Report(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      description: json['description'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      file: json['file'] as String?,
      createdAt: parsedCreatedAt,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      spaceName: json['spaceName'] as String?,
      district: json['district'] as String?,
      street: json['street'] as String?,
      userId: json['userId'] as String?,
      user: reportUser,
      status: json['status'] as String?,
    );
  }

  Report copyWith({
    String? id,
    String? reportId,
    String? description,
    String? email,
    String? phone,
    String? file,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    String? spaceName,
    String? district,
    String? street,
    String? userId,
    String? status,
    User? user,
  }) {
    return Report(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      description: description ?? this.description,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      file: file ?? this.file,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      spaceName: spaceName ?? this.spaceName,
      district: district ?? this.district,
      street: street ?? this.street,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportId': reportId,
      'description': description,
      'email': email,
      'phone': phone,
      'file': file,
      'createdAt': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'spaceName': spaceName,
      'district': district,
      'street': street,
      'userId': userId,
      'status': status,
      'user': user?.toJsonString(),
    };
  }
}
