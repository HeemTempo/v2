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

class _UserReportsPageState extends State<UserReportsPage> {
  late Future<List<Report>> _futureReports;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _futureReports = _fetchUserReports();
  }

  Future<List<Report>> _fetchUserReports() async {
    final reportRepo = ReportRepository(localService: ReportLocal());
    
    try {
      // Try to fetch from API first  
      final onlineReports = await ReportService().fetchUserReports();
      print('Fetched ${onlineReports.length} reports from API');
      return onlineReports;
    } catch (e) {
      debugPrint('Failed to fetch from API: $e. Using local data.');
      // Fall back to local data if API fails
      final localReports = await reportRepo.getAllReports();
      print('Fetched ${localReports.length} local reports');
      return localReports;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }

  Widget _buildReportCard(Report report) {
    final status = (report.status ?? 'submitted').toLowerCase();
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to details if needed
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Report ID
                    Text(
                      '#${report.reportId}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Details
                if (report.spaceName != null) ...[
                  _buildDetailRow(Icons.location_on, report.spaceName!),
                  const SizedBox(height: 6),
                ],
                if (report.district != null && report.street != null) ...[
                  _buildDetailRow(Icons.map_outlined, '${report.district} • ${report.street}'),
                  const SizedBox(height: 6),
                ],
                _buildDetailRow(Icons.access_time, formatDate(report.createdAt)),
                // Attachment indicator
                if (report.file != null && report.file!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(Icons.attachment, size: 16, color: AppConstants.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          'Has attachment',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'submitted':
        return const Color(0xFFF59E0B);
      case 'resolved':
      case 'approved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : AppConstants.primaryBlue),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppConstants.primaryBlue,
      backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppConstants.primaryBlue,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppConstants.primaryBlue : AppConstants.primaryBlue.withOpacity(0.3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Reports', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _futureReports = _fetchUserReports();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', Icons.list),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending', Icons.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('Resolved', 'resolved', Icons.check_circle),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected', 'rejected', Icons.cancel),
                ],
              ),
            ),
          ),
          // Reports list
          Expanded(
            child: FutureBuilder<List<Report>>(
              future: _futureReports,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading reports',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final allReports = snapshot.data ?? [];
                print('Total reports loaded: ${allReports.length}');
                
                // Filter reports
                final filteredReports = _selectedFilter == 'all'
                    ? allReports
                    : allReports.where((r) {
                        final status = (r.status ?? 'submitted').toLowerCase();
                        return status == _selectedFilter || 
                               (_selectedFilter == 'pending' && status == 'submitted');
                      }).toList();

                print('Filtered reports (${_selectedFilter}): ${filteredReports.length}');

                if (filteredReports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all' ? 'No reports yet' : 'No $_selectedFilter reports',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _futureReports = _fetchUserReports();
                    });
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) => _buildReportCard(filteredReports[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
