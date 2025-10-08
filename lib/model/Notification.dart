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
    return ReportNotification(
      id: json['id'],
      reportId: json['report_id'],
      message: json['message'],
      repliedBy: json['replied_by'] ?? 'System',
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }
}