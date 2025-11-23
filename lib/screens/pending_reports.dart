import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/data/repository/report_repository.dart';
import 'package:openspace_mobile_app/model/Report.dart';
import 'package:openspace_mobile_app/utils/constants.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../l10n/app_localizations.dart';

class PendingReportsPage extends StatefulWidget {
  const PendingReportsPage({super.key});

  @override
  State<PendingReportsPage> createState() => _PendingReportsPageState();
}

class _PendingReportsPageState extends State<PendingReportsPage> {
  bool _isLoading = true;
  List<Report> _pendingReports = [];

  @override
  void initState() {
    super.initState();
    _loadPendingReports();
  }

  Future<void> _loadPendingReports() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<ReportProvider>();
      final reports = await provider.repository.getPendingReports();
      setState(() {
        _pendingReports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Reports'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingReports,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingReports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 80, color: Colors.green),
                      const SizedBox(height: 16),
                      Text('No pending reports', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingReports.length,
                  itemBuilder: (context, index) {
                    final report = _pendingReports[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade100,
                          child: Icon(Icons.pending, color: Colors.orange),
                        ),
                        title: Text(
                          report.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${report.spaceName ?? "Unknown"} • ${_formatDate(report.createdAt)}',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: Chip(
                          label: Text('Offline', style: TextStyle(fontSize: 10)),
                          backgroundColor: Colors.orange.shade100,
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/report-detail',
                          arguments: report,
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
