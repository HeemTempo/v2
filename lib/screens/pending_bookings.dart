import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:openspace_mobile_app/providers/booking_provider.dart';
import 'package:openspace_mobile_app/model/Booking.dart';
import 'package:openspace_mobile_app/utils/constants.dart';

class PendingBookingsPage extends StatefulWidget {
  const PendingBookingsPage({super.key});

  @override
  State<PendingBookingsPage> createState() => _PendingBookingsPageState();
}

class _PendingBookingsPageState extends State<PendingBookingsPage> {
  @override
  void initState() {
    super.initState();
    // Auto-sync when page opens
    Future.microtask(() {
      final bookingProvider = context.read<BookingProvider>();
      bookingProvider.syncPendingBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Bookings'),
        centerTitle: true,
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              context.read<BookingProvider>().syncPendingBookings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing pending bookings...')),
              );
            },
            tooltip: 'Sync Now',
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          final pendingBookings = provider.pendingBookings;

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pendingBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Pending Bookings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All bookings have been synced',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.syncPendingBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingBookings.length,
              itemBuilder: (context, index) {
                final booking = pendingBookings[index];
                return _PendingBookingCard(booking: booking);
              },
            ),
          );
        },
      ),
    );
  }
}

class _PendingBookingCard extends StatelessWidget {
  final Booking booking;

  const _PendingBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 16, color: Colors.orange[900]),
                      const SizedBox(width: 6),
                      Text(
                        'PENDING SYNC',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(booking.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Booking Details
            _DetailRow(
              icon: Icons.person,
              label: 'Name',
              value: booking.username,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.phone,
              label: 'Contact',
              value: booking.contact,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.location_on,
              label: 'District',
              value: booking.district,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Start Date',
              value: DateFormat('yyyy-MM-dd').format(booking.startDate),
            ),
            if (booking.endDate != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.event,
                label: 'End Date',
                value: DateFormat('yyyy-MM-dd').format(booking.endDate!),
              ),
            ],
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.description,
              label: 'Purpose',
              value: booking.purpose,
            ),

            // Info message
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This booking will be submitted automatically when you reconnect to the internet.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
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
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppConstants.primaryBlue),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}