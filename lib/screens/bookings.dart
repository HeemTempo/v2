import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kinondoni_openspace_app/model/Booking.dart';
import 'package:kinondoni_openspace_app/data/repository/booking_repository.dart';
import 'package:kinondoni_openspace_app/data/local/booking_local.dart';
import 'package:kinondoni_openspace_app/utils/constants.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late Future<List<Booking>> _futureBookings;
  late BookingRepository _bookingRepository;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _bookingRepository = BookingRepository();
    _futureBookings = _fetchBookings();
  }

  Future<List<Booking>> _fetchBookings() async {
    try {
      final bookings = await _bookingRepository.getMyBookings();
      print('Fetched ${bookings.length} bookings');
      return bookings;
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildBookingCard(Booking booking) {
    final status = booking.status.toLowerCase();
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
                            status.replaceAll('_', ' ').toUpperCase(),
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
                    // Booking ID
                    Text(
                      '#${booking.id}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Purpose
                Text(
                  booking.purpose,
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
                _buildDetailRow(Icons.person_outline, booking.username),
                const SizedBox(height: 6),
                _buildDetailRow(Icons.phone_outlined, booking.contact),
                const SizedBox(height: 6),
                _buildDetailRow(Icons.location_on, booking.district),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(Icons.calendar_today, 'Start: ${formatDate(booking.startDate)}'),
                    ),
                  ],
                ),
                if (booking.endDate != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailRow(Icons.event, 'End: ${formatDate(booking.endDate!)}'),
                      ),
                    ],
                  ),
                ],
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
      case 'pending_offline':
        return const Color(0xFFF59E0B);
      case 'approved':
      case 'confirmed':
        return const Color(0xFF10B981);
      case 'rejected':
      case 'cancelled':
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
        borderRadius: BorderRadius.circular(20),
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
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _futureBookings = _fetchBookings();
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
                  _buildFilterChip('Approved', 'approved', Icons.check_circle),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected', 'rejected', Icons.cancel),
                ],
              ),
            ),
          ),
          // Bookings list
          Expanded(
            child: FutureBuilder<List<Booking>>(
              future: _futureBookings,
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
                          'Error loading bookings',
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

                final allBookings = snapshot.data ?? [];
                print('Total bookings loaded: ${allBookings.length}');
                
                // Filter bookings
                final filteredBookings = _selectedFilter == 'all'
                    ? allBookings
                    : allBookings.where((b) {
                        final status = b.status.toLowerCase();
                        return status == _selectedFilter || 
                               (_selectedFilter == 'pending' && status == 'pending_offline');
                      }).toList();

                print('Filtered bookings (${_selectedFilter}): ${filteredBookings.length}');

                if (filteredBookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all' ? 'No bookings yet' : 'No $_selectedFilter bookings',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _futureBookings = _fetchBookings();
                    });
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) => _buildBookingCard(filteredBookings[index]),
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
