class ReportNotification {
  final int id;
  final String reportId;
  final String message;
  final String repliedBy;
  final DateTime createdAt;
  bool isRead;

  ReportNotification({
    required this.id,
    required this.reportId,
    required this.message,
    required this.repliedBy,
    required this.createdAt,
    this.isRead = false,
  });

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reportId': reportId,
      'message': message,
      'repliedBy': repliedBy,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead ? 1 : 0,
    };
  }

  // Create from database map
  factory ReportNotification.fromMap(Map<String, dynamic> map) {
    return ReportNotification(
      id: map['id'],
      reportId: map['reportId'],
      message: map['message'],
      repliedBy: map['repliedBy'] ?? 'System',
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] == 1,
    );
  }

  // Create from JSON (for API)
  factory ReportNotification.fromJson(Map<String, dynamic> json) {
    // Parse created_at - API may return dd/MM/yyyy HH:mm:ss format
    DateTime parsedDate;
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
        print('Error parsing notification date: $parseError');
        parsedDate = DateTime.now();
      }
    }

    return ReportNotification(
      id: json['id'],
      reportId: json['report_id'],
      message: json['message'],
      repliedBy: json['replied_by'] ?? 'System',
      createdAt: parsedDate,
      isRead: json['is_read'] ?? false,
    );
  }
}
