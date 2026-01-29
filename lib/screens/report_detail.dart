import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/model/Report.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getStatusColor(report.status ?? 'submitted'),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(_getStatusIcon(report.status ?? 'submitted'), color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusText(report.status ?? 'submitted'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Report ID: ${report.reportId != "pending" ? report.reportId : "Pending Sync"}',
                         style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           _buildSectionHeader('Description'),
                           const SizedBox(height: 8),
                           Text(
                             report.description,
                             style: const TextStyle(fontSize: 16, height: 1.4),
                           ),
                           const Divider(height: 24),
                           
                           if (report.spaceName != null)
                            _buildInfoRow(Icons.place, 'Location', report.spaceName!),
                           
                           _buildInfoRow(Icons.calendar_today, 'Date Reported', _formatDate(report.createdAt)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location Details
                  if (report.latitude != null && report.longitude != null) ...[
                     const SizedBox(height: 24),
                     Card(
                       elevation: 1,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       child: ListTile(
                         leading: const CircleAvatar(
                           backgroundColor: Colors.blueAccent, 
                           child: Icon(Icons.map, color: Colors.white)
                         ),
                         title: const Text('GPS Coordinates'),
                         subtitle: Text('${report.latitude!.toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}'),
                         trailing: const Icon(Icons.copy, size: 20),
                       )
                     ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'submitted':
        return Colors.purple;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Icons.sync_problem;
      case 'submitted':
        return Icons.send_rounded;
      case 'in_progress':
        return Icons.hourglass_top_rounded;
      case 'resolved':
        return Icons.verified;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Waiting for Connection';
      case 'submitted':
        return 'Submitted';
      case 'in_progress':
        return 'Working on it';
      default:
        return status?.toUpperCase() ?? 'UNKNOWN';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
