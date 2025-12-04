import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/Report.dart';
import '../service/userreports.dart';
import '../data/repository/report_repository.dart';
import '../data/local/report_local.dart';
import '../utils/constants.dart';

class UserReportsPage extends StatefulWidget {
  const UserReportsPage({super.key});

  @override
  State<UserReportsPage> createState() => _UserReportsPageState();
}

class _UserReportsPageState extends State<UserReportsPage> with SingleTickerProviderStateMixin {
  late Future<List<Report>> _futureReports;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _futureReports = _fetchUserReports();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Report>> _fetchUserReports() async {
    final reportRepo = ReportRepository(localService: ReportLocal());
    
    try {
      // Try to fetch from API first
      final onlineReports = await ReportService().fetchUserReports();
      return onlineReports;
    } catch (e) {
      debugPrint('Failed to fetch from API: $e. Using local data.');
      // Fall back to local data if API fails
      final localReports = await reportRepo.getAllReports();
      return localReports;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  // Enhanced Report card UI
  Widget _buildReportCard(Report report) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              _getStatusColor(report.status ?? '').withOpacity(0.03),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status ?? '').withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: _getStatusColor(report.status ?? ''),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.reportId ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status ?? ''),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (report.status ?? 'unknown').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),

              // Details with icons
              if (report.spaceName != null)
                _buildIconRow(
                  Icons.location_on_outlined,
                  "Space",
                  report.spaceName!,
                ),
              _buildIconRow(
                Icons.calendar_today_outlined,
                "Created",
                formatDate(report.createdAt),
              ),
              if (report.user != null)
                _buildIconRow(
                  Icons.person_outline,
                  "Reporter",
                  report.user!.username,
                ),

              // Attachment button
              if (report.file != null && report.file!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: const Text("View Attachment"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => _viewAttachment(report.file!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppConstants.primaryBlue.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppConstants.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewAttachment(String fileUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('View Attachment'),
        content: Text('File URL:\\n\\n$fileUrl'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('File: $fileUrl')),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Reports list per tab
  Widget _buildReportTab(bool Function(Report) filter) {
    return FutureBuilder<List<Report>>(
      future: _futureReports,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final reports = snapshot.data ?? [];
        final filteredReports = reports.where(filter).toList();
        if (filteredReports.isEmpty) {
          return const Center(child: Text('No reports found.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _futureReports = _fetchUserReports();
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: filteredReports.length,
            itemBuilder: (context, index) => _buildReportCard(filteredReports[index]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports', style: TextStyle(color: AppConstants.white)),
        backgroundColor: AppConstants.primaryBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppConstants.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Resolved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportTab((report) => report.status?.toLowerCase() == 'pending'),
          _buildReportTab((report) => report.status?.toLowerCase() == 'resolved'),
          _buildReportTab((report) => report.status?.toLowerCase() == 'rejected'),
        ],
      ),
    );
  }
}
