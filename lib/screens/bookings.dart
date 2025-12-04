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
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppConstants.white,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      _getStatusColor(booking.status).withOpacity(0.03),
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
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.event_note,
                              color: AppConstants.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              booking.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppConstants.black,
                              ),
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking.status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              booking.status == "pending_offline"
                                  ? "Pending (Offline)"
                                  : booking.status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
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
                      _buildIconDetailRow(
                        Icons.phone_outlined,
                        locale.contact,
                        booking.contact,
                      ),
                      _buildIconDetailRow(
                        Icons.description_outlined,
                        locale.purpose,
                        booking.purpose,
                      ),
                      _buildIconDetailRow(
                        Icons.location_on_outlined,
                        locale.district,
                        booking.district,
                      ),
                      _buildIconDetailRow(
                        Icons.calendar_today_outlined,
                        locale.startDateLabel,
                        formatDate(booking.startDate),
                      ),
                      if (booking.endDate != null)
                        _buildIconDetailRow(
                          Icons.event_available_outlined,
                          locale.endDateLabel,
                          formatDate(booking.endDate!),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppConstants.primaryBlue.withOpacity(0.7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
