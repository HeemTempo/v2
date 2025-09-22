import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openspace_mobile_app/data/repository/booking_repository.dart';
import 'package:openspace_mobile_app/model/Booking.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Booking>> _allBookingsFuture;
  final BookingRepository _bookingRepository = BookingRepository();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize with empty list so FutureBuilder doesn't break
    _allBookingsFuture = Future.value([]);

    // Load bookings after syncing
    _syncAndLoadBookings();
  }

  // Sync offline bookings first, then load all bookings
  Future<void> _syncAndLoadBookings() async {
    await _bookingRepository.syncPendingBookings();
    // Assign the real Future after syncing
    setState(() {
      _allBookingsFuture = _bookingRepository.getMyBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_offline':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.myBookings,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppConstants.primaryBlue,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: locale.activeBookings),
            Tab(text: locale.pastBookings),
            Tab(text: locale.pendingBookings),
          ],
        ),
      ),
      body: Container(
        color: AppConstants.white,
        child: RefreshIndicator(
          onRefresh: _syncAndLoadBookings, // Pull to refresh triggers sync
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBookingTab(locale,
                  (booking) => booking.status.toLowerCase() == 'accepted'),
              _buildBookingTab(locale, (booking) =>
                  booking.status.toLowerCase() == 'rejected' ||
                  DateTime.now().isAfter(booking.endDate ?? DateTime.now())),
              _buildBookingTab(locale,
                  (booking) =>
                      booking.status.toLowerCase() == 'pending' ||
                      booking.status.toLowerCase() == 'pending_offline'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingTab(AppLocalizations locale, bool Function(Booking) filter) {
    return FutureBuilder<List<Booking>>(
      future: _allBookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              '${locale.error}: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(locale.noBookingsMessage),
          );
        }

        final bookings = snapshot.data!.where(filter).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: AppConstants.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppConstants.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(locale.contact, booking.contact),
                    _buildDetailRow(locale.purpose, booking.purpose),
                    _buildDetailRow(locale.district, booking.district),
                    _buildDetailRow(
                        locale.startDateLabel, formatDate(booking.startDate)),
                    if (booking.endDate != null)
                      _buildDetailRow(
                          locale.endDateLabel, formatDate(booking.endDate!)),
                    Text(
                      '${locale.status}: ${booking.status == "pending_offline" ? "Pending (Offline)" : booking.status}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _getStatusColor(booking.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
