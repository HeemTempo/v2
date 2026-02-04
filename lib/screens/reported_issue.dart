import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';
import 'package:provider/provider.dart';
import '../model/Report.dart';
import '../providers/report_provider.dart';
import '../core/network/connectivity_service.dart';

class ReportedIssuesPage extends StatefulWidget {
  const ReportedIssuesPage({super.key});

  @override
  _ReportedIssuesPageState createState() => _ReportedIssuesPageState();
}

class _ReportedIssuesPageState extends State<ReportedIssuesPage> {
  final int itemsPerPage = 8;
  int currentMax = 8;
  bool _isLoading = true;
  String? _errorMessage;
  List<Report> _allFetchedIssues = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchReports();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final reportProvider = context.read<ReportProvider>();
      final connectivityService = context.read<ConnectivityService>();
      
      if (connectivityService.isOnline) {
        // Online: Fetch from server and save locally
        final reports = await reportProvider.repository.getAllReports(forceRefresh: true);
        if (!mounted) return;
        setState(() {
          _allFetchedIssues = reports;
          _isLoading = false;
        });
      } else {
        // Offline: Load from local database
        final localReports = await reportProvider.repository.localService.getAllReports();
        if (!mounted) return;
        setState(() {
          _allFetchedIssues = localReports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        _isLoading = false;
      });
    }
  }

  void _loadMore() {
    if (currentMax < _allFetchedIssues.length) {
      setState(() {
        currentMax =
            (currentMax + itemsPerPage).clamp(0, _allFetchedIssues.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Report> displayedIssues =
        _allFetchedIssues.take(currentMax).toList();
    final connectivityService = context.watch<ConnectivityService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : AppConstants.primaryBlue,
        elevation: 3,
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: const Text(
          'Reported Issues',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!connectivityService.isOnline)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.cloud_off, color: Colors.white70, size: 20),
            ),
        ],
      ),
      body: _buildBodyContent(displayedIssues),
    );
  }

  Widget _buildBodyContent(List<Report> displayedIssues) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      final connectivityService = context.watch<ConnectivityService>();
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              connectivityService.isOnline ? Icons.error_outline : Icons.cloud_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchReports,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_allFetchedIssues.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 50),
            SizedBox(height: 12),
            Text('No issues reported yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchReports,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: displayedIssues.length + 1,
        itemBuilder: (context, index) {
          if (index < displayedIssues.length) {
            return _buildIssueCard(context, displayedIssues[index]);
          } else if (currentMax < _allFetchedIssues.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, Report issue) {
    final formattedDate =
        DateFormat('yyyy-MM-dd').format(issue.createdAt.toLocal());

    final bool hasCoordinates =
        issue.latitude != null && issue.longitude != null;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400] : Colors.black54;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            Navigator.pushNamed(context, '/report-detail', arguments: issue),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report icon with circular background
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor(issue.status ?? 'submitted').withValues(alpha: 0.2),
                      _getStatusColor(issue.status ?? 'submitted').withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(issue.status ?? 'submitted').withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 38,
                  color: _getStatusColor(issue.status ?? 'submitted'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and status chip in one row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            issue.spaceName ?? 'Unnamed Space',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(issue.status ?? 'submitted'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      issue.description,
                      style: TextStyle(
                          fontSize: 14, color: subtextColor, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (hasCoordinates)
                          InkWell(
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/map',
                              arguments: {
                                "latitude": issue.latitude,
                                "longitude": issue.longitude,
                              },
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: AppConstants.primaryBlue, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  "View Map",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppConstants.primaryBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 15, color: isDark ? Colors.grey[400] : Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                  fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get status color helper
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return AppConstants.primaryBlue;
      case 'submitted':
        return AppConstants.primaryBlue;
      default:
        return Colors.grey;
    }
  }

  /// Status Chip Builder
  Widget _buildStatusChip(String? status) {
    Color bgColor;
    Color textColor = Colors.white;
    String label = status ?? "Unknown";

    switch (status?.toLowerCase()) {
      case "resolved":
        bgColor = Colors.green;
        label = "Resolved";
        break;
      case "pending":
        bgColor = Colors.orange;
        label = "Pending";
        break;
      case "rejected":
        bgColor = Colors.red;
        label = "Rejected";
        break;
      case "in_progress":
        bgColor = AppConstants.primaryBlue;
        label = "In Progress";
        break;
      case "submitted":
        bgColor = AppConstants.primaryBlue;
        label = "Submitted";
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
