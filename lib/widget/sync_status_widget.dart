import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../providers/booking_provider.dart';
import '../utils/constants.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReportProvider, BookingProvider>(
      builder: (context, reportProvider, bookingProvider, _) {
        final pendingReports = reportProvider.pendingReportsCount;
        final pendingBookings = bookingProvider.pendingBookingsCount;
        final totalPending = pendingReports + pendingBookings;

        if (totalPending == 0) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => _showSyncDialog(context, reportProvider, bookingProvider),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalPending items pending sync',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      Text(
                        '$pendingReports reports • $pendingBookings bookings',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.sync, color: Colors.orange.shade700),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSyncDialog(
    BuildContext context,
    ReportProvider reportProvider,
    BookingProvider bookingProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Pending Items'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${reportProvider.pendingReportsCount} pending reports'),
            Text('${bookingProvider.pendingBookingsCount} pending bookings'),
            const SizedBox(height: 16),
            const Text(
              'These items will be synced automatically when you\'re online. Tap Sync Now to try immediately.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Future.wait([
                reportProvider.syncPendingReports(),
                bookingProvider.syncPendingBookings(),
              ]);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync completed')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
            ),
            child: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }
}
