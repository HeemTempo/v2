import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openspace_mobile_app/utils/constants.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryBlue,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppConstants.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.white,
          labelColor: AppConstants.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'General Notifications'),
            Tab(text: 'My Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // General Notifications Tab
          _buildNotificationList(
            title: 'General Notifications',
            notifications: _generateGeneralNotifications(),
          ),
          // My Notifications Tab
          _buildNotificationList(
            title: 'My Notifications',
            notifications: _generateMyNotifications(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList({required String title, required List<NotificationItem> notifications}) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No $title available.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationCard(
          title: notification.title,
          message: notification.message,
          timestamp: notification.timestamp,
          icon: notification.icon,
          isRead: notification.isRead,
          onTap: () {
            setState(() {
              notification.isRead = true;
            });
            // Handle notification tap (e.g., navigate to details)
          },
        );
      },
    );
  }
}

// Reusable Notification Card Widget
class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String timestamp;
  final IconData icon;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppConstants.primaryBlue.withOpacity(0.1),
                child: Icon(icon, color: AppConstants.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          timestamp,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Notification Item Model
class NotificationItem {
  final String title;
  final String message;
  final String timestamp;
  final IconData icon;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    this.isRead = false,
  });
}

// Sample Data Generation
List<NotificationItem> _generateGeneralNotifications() {
  final now = DateTime.now();
  return [
    NotificationItem(
      title: 'New Space Available',
      message: 'A new community space has been opened in Kinondoni.',
      timestamp: DateFormat('hh:mm a').format(now.subtract(const Duration(minutes: 30))),
      icon: Icons.public,
      isRead: false,
    ),
    NotificationItem(
      title: 'Maintenance Notice',
      message: 'Scheduled maintenance on August 5, 2025.',
      timestamp: DateFormat('hh:mm a').format(now.subtract(const Duration(hours: 2))),
      icon: Icons.build,
      isRead: true,
    ),
  ];
}

List<NotificationItem> _generateMyNotifications() {
  final now = DateTime.now();
  return [
    NotificationItem(
      title: 'Booking Confirmed',
      message: 'Your booking for Space #123 is confirmed for 08/01/2025.',
      timestamp: DateFormat('hh:mm a').format(now.subtract(const Duration(minutes: 15))),
      icon: Icons.event_available,
      isRead: false,
    ),
    NotificationItem(
      title: 'Reminder',
      message: 'Your booking ends at 5:00 PM today.',
      timestamp: DateFormat('hh:mm a').format(now.subtract(const Duration(hours: 1))),
      icon: Icons.access_time,
      isRead: true,
    ),
  ];
}