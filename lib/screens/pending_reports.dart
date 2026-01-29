import 'package:flutter/material.dart';
import 'package:kinondoni_openspace_app/model/Report.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';

class PendingReportsPage extends StatefulWidget {
  const PendingReportsPage({super.key});

  @override
  State<PendingReportsPage> createState() => _PendingReportsPageState();
}

class _PendingReportsPageState extends State<PendingReportsPage> {
  @override
  void initState() {
    super.initState();
    // Refresh list on entry to be safe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().refreshPendingReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Unused but kept for access if needed
    // final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Reports'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          Consumer<ReportProvider>(
            builder: (context, provider, _) {
              if (provider.isSubmitting) { // or add an isSyncing flag if exposed
                return const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                ));
              }
              return IconButton(
                icon: const Icon(Icons.sync),
                onPressed: () {
                   provider.syncPendingReports();
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Syncing pending reports...'), duration: Duration(seconds: 1)),
                   );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, provider, child) {
          final reports = provider.pendingReports;
          
          if (reports.isEmpty) {
             return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 100, color: Colors.green.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'All Caught Up!', 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                      )
                    ),
                    const SizedBox(height: 8),
                    Text('No pending offline reports', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportCard(context, report);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Report report) {
    final hasImage = report.file != null && report.file!.isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/report-detail',
          arguments: report,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Header status strip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Text(
                    'Offline / Pending Sync',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, size: 16, color: Colors.orange.shade300),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.article_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), size: 30),
                    ),
                   const SizedBox(width: 16),
                   
                   // Content
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           report.description,
                           maxLines: 2,
                           overflow: TextOverflow.ellipsis,
                           style: const TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 16,
                           ),
                         ),
                         const SizedBox(height: 4),
                         Row(
                           children: [
                              Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                             const SizedBox(width: 4),
                             Expanded(
                                child: Text(
                                  report.spaceName ?? "Unknown Location",
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
                                  maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 4),
                          Text(
                            _formatDate(report.createdAt),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                          ),
                       ],
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
