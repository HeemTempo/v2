import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kinondoni_openspace_app/model/Notification.dart';
import '../utils/constants.dart';

class NotificationDetailScreen extends StatelessWidget {
  final ReportNotification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
        backgroundColor: AppConstants.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report ID: ${notification.reportId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Text('From: ${notification.repliedBy}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                Text(notification.message,
                    style: const TextStyle(fontSize: 16, height: 1.5)),
                const SizedBox(height: 20),
                Text(
                  'Received: ${DateFormat('yyyy-MM-dd hh:mm a').format(notification.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
