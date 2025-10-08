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

  factory ReportNotification.fromJson(Map<String, dynamic> json) {
    return ReportNotification(
      id: json['id'],
      reportId: json['report_id'],
      message: json['message'],
      repliedBy: json['replied_by'] ?? 'System',
      createdAt: DateTime.parse(json['created_at']),
      isRead: false,
    );
  }
}
