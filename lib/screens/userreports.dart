import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/Report.dart';
import '../service/userreports.dart';
import '../data/repository/report_repository.dart';
import '../data/local/report_local.dart';
import '../core/network/connectivity_service.dart';
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
    try {
      // Reduce timeout to 8 seconds since API is timing out
      return await _fetchUserReportsInternal().timeout(
        const Duration(seconds: 8),
        onTimeout: () async {
          print('⚠️ Fetch timeout after 8s - returning local data only');
          return _fetchLocalReportsOnly();
        },
      );
    } catch (e) {
      print('❌ Error in _fetchUserReports: $e');
      // Return local data if anything fails
      return _fetchLocalReportsOnly();
    }
  }

  Future<List<Report>> _fetchLocalReportsOnly() async {
    try {
      final reportRepo = ReportRepository(localService: ReportLocal());
      final localReports = await reportRepo.getAllReports();
      localReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print('📦 Loaded ${localReports.length} local reports only');
      return localReports;
    } catch (e) {
      print('❌ Error fetching local reports: $e');
      return [];
    }
  }

  Future<List<Report>> _fetchUserReportsInternal() async {
    final reportRepo = ReportRepository(localService: ReportLocal());
    List<Report> allReports = [];
    
    // 1. Get Pending/Offline Reports - simplified to avoid blocking
    try {
       final pending = await reportRepo.getPendingReports().timeout(
         const Duration(seconds: 2),
         onTimeout: () {
           print('⚠️ Pending reports fetch timeout');
           return <Report>[];
         },
       );
       allReports.addAll(pending);
       print('📝 Loaded ${pending.length} pending reports');
    } catch (e) {
       print('⚠️ Error fetching pending reports: $e');
    }

    // 2. Get Online/Submitted Reports
    
    // Check connectivity first to avoid long timeout if offline
    final isOnline = await context.read<ConnectivityService>().checkConnectivity();
    
    if (isOnline) {
      try {
        // Add timeout since server is returning 408 errors
        final onlineReports = await ReportService().fetchUserReports().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('⚠️ API timeout after 5s - using local data');
            return <Report>[];
          },
        );
        print('✅ Fetched ${onlineReports.length} reports from API');
        allReports.addAll(onlineReports);
      } catch (e) {
        print('⚠️ API error: $e - using local data');
        // Fall back to local data if API fails
        final localReports = await reportRepo.getAllReports();
        _mergeLocalReports(allReports, localReports);
      }
    } else {
       // Device is offline - load local data immediately
       print('📴 Device offline, loading local reports immediately');
       final localReports = await reportRepo.getAllReports();
       _mergeLocalReports(allReports, localReports);
    }

    // Sort by Date DESC
    allReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return allReports;
  }
  
  void _mergeLocalReports(List<Report> allReports, List<Report> localReports) {
      // Avoid duplicates if we already have pending reports
      if (allReports.isEmpty) {
        allReports.addAll(localReports);
      } else {
        final existingIds = allReports.map((r) => r.id).toSet();
        for (var r in localReports) {
           if (!existingIds.contains(r.id)) {
             allReports.add(r);
           }
        }
      }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }

  Widget _buildReportCard(Report report) {
    final status = (report.status ?? 'submitted').toLowerCase();
    final statusColor = _getStatusColor(status);
    final isOffline = status == 'pending';
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
            // Navigate to details if needed, pass report object
             Navigator.pushNamed(
                context,
                '/report-detail',
                arguments: report,
             );
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
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
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
                            isOffline ? 'OFFLINE / PENDING' : status.toUpperCase(),
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
                    if (!isOffline)
                      Text(
                        '#${report.reportId}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  report.description,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
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

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
        return Colors.orange; // Distinct orange for offline pending
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
      backgroundColor: AppConstants.primaryBlue.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppConstants.primaryBlue,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppConstants.primaryBlue : AppConstants.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
            color: theme.cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', Icons.list),
                  const SizedBox(width: 8),
                  _buildFilterChip('Offline', 'pending', Icons.wifi_off),
                  const SizedBox(width: 8),
                  _buildFilterChip('Submitted (Pending)', 'submitted', Icons.upload),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'resolved', Icons.check_circle),
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
                        Icon(Icons.error_outline, size: 60, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading reports',
                          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final allReports = snapshot.data ?? [];
                
                // Filter reports
                final filteredReports = _selectedFilter == 'all'
                    ? allReports
                    : allReports.where((r) {
                        final status = (r.status ?? 'submitted').toLowerCase();
                        if (_selectedFilter == 'resolved') {
                          return status == 'resolved' || status == 'approved';
                        }
                        return status == _selectedFilter;
                      }).toList();

                if (filteredReports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                             _selectedFilter == 'pending' ? Icons.wifi_off : Icons.inbox, 
                             size: 60, color: theme.dividerColor
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all' 
                              ? 'No reports yet' 
                              : _selectedFilter == 'pending' 
                                  ? 'No offline reports waiting to sync' 
                                  : 'No $_selectedFilter reports',
                          style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
