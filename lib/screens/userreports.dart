import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/Report.dart';
import '../service/userreports.dart';
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
    _futureReports = ReportService().fetchUserReports();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  // 🔹 Report card UI (like your screenshots)
  Widget _buildReportCard(Report report) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report ID + Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, color: Colors.blueGrey, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${report.reportId} • ${report.description}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Space
            if (report.spaceName != null)
              Text(
                "Space: ${report.spaceName}",
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),

            // Created date
            Text(
              "Created: ${formatDate(report.createdAt)}",
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),

            // Reporter
            if (report.user != null)
              Text(
                "Reporter: ${report.user!.username ?? "User"}",
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),

            const SizedBox(height: 6),

            // Status badge
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(report.status!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(report.status!)),
                ),
                child: Text(
                  report.status!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(report.status!),
                  ),
                ),
              ),
            ),

            // Attachment
            if (report.file != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.attach_file, size: 16, color: Colors.blue),
                  label: const Text("View attachment", style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('File URL: ${report.file}')),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔹 Status color helper
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

  // 🔹 Reports list per tab
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
              _futureReports = ReportService().fetchUserReports();
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
