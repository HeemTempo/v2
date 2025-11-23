import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import '../widget/custom_navigation_bar.dart';
import 'side_bar.dart';
import '../data/repository/report_repository.dart';
import '../data/repository/booking_repository.dart';
import '../data/local/report_local.dart';
import '../model/Report.dart';
import '../model/Booking.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _CardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  const _CardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

class _ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime date;
  final Color iconColor;

  _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.iconColor,
  });
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _carouselIndex = 0;
  final PageController _pageController = PageController();
  int _notificationCount = 0;
  late AnimationController _animationController;
  Timer? _autoScrollTimer;
  
  List<_ActivityItem> _recentActivities = [];
  bool _isLoadingActivities = true;

  final List<String> _horizontalImages = [
    'assets/images/green_space.jpg',
    'assets/images/green_space2.jpg',
    'assets/images/green_space.jpg',
    'assets/images/green_space2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();

    _fetchRecentActivities();
    _startAutoScroll();
  }

  Future<void> _fetchRecentActivities() async {
    if (!mounted) return;
    setState(() => _isLoadingActivities = true);

    try {
      final reportRepo = ReportRepository(localService: ReportLocal());
      final bookingRepo = BookingRepository();

      // Fetch reports and bookings (local/offline first or synced)
      // Note: In a real app, you might want to fetch from API if online, 
      // but here we use what's available via repositories which handle that logic.
      // For simplicity, we'll fetch pending/local ones or you might want to add a method to fetch 'all' user activities.
      // Assuming repositories have methods to get user's history.
      
      // Since the current repositories focus on 'pending' or 'create', we might need to rely on what's stored locally
      // or add a method to fetch user history. For now, let's use local pending items as "Recent Activity" 
      // to demonstrate the dynamic nature, or mock it if empty.
      
      final pendingReports = await reportRepo.getPendingReports();
      final pendingBookings = await bookingRepo.getPendingBookings();

      List<_ActivityItem> activities = [];

      for (var report in pendingReports) {
        activities.add(_ActivityItem(
          icon: Icons.report_problem,
          title: 'Report: ${report.spaceName ?? "Unknown Space"}',
          subtitle: report.description,
          date: report.createdAt ?? DateTime.now(),
          iconColor: Colors.orange,
        ));
      }

      for (var booking in pendingBookings) {
        activities.add(_ActivityItem(
          icon: Icons.event,
          title: 'Booking: Space #${booking.spaceId}',
          subtitle: 'Status: ${booking.status}',
          date: booking.startDate,
          iconColor: Colors.blue,
        ));
      }

      // Sort by date descending
      activities.sort((a, b) => b.date.compareTo(a.date));

      // Take top 5
      if (activities.length > 5) {
        activities = activities.sublist(0, 5);
      }

      if (mounted) {
        setState(() {
          _recentActivities = activities;
          _isLoadingActivities = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      if (mounted) setState(() => _isLoadingActivities = false);
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && mounted) {
        int next = (_pageController.page?.round() ?? 0) + 1;
        if (next >= _horizontalImages.length) next = 0;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/user-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final heroTitles = [
      locale.heroTitle1,
      locale.heroTitle2,
      locale.heroTitle3,
      locale.heroTitle4,
    ];

    final heroSubtitles = [
      locale.heroSubtitle1,
      locale.heroSubtitle2,
      locale.heroSubtitle3,
      locale.heroSubtitle4,
    ];

    final List<_CardData> cards = [
      _CardData(
        icon: Icons.report_problem_outlined,
        title: locale.reportIssue,
        subtitle: locale.reportIssueSubtitle,
        route: '/map',
      ),
      _CardData(
        icon: Icons.assignment_outlined,
        title: locale.viewReports,
        subtitle: locale.viewReportsSubtitle,
        route: '/reported-issue',
      ),
      _CardData(
        icon: Icons.calendar_today_outlined,
        title: locale.bookSpace,
        subtitle: locale.bookSpaceSubtitle,
        route: '/map',
      ),
      _CardData(
        icon: Icons.analytics_outlined,
        title: locale.trackProgress,
        subtitle: locale.trackProgressSubtitle,
        route: '/track-progress',
      ),
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? AppConstants.darkBackground : AppConstants.white,
      drawer: const Sidebar(),
      appBar: _buildAppBar(locale, theme, isDarkMode),
      body: RefreshIndicator(
        onRefresh: _fetchRecentActivities,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(heroTitles, heroSubtitles, theme, isDarkMode),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(locale, theme, isDarkMode),
                    const SizedBox(height: 24),
                    _buildSectionTitle(locale.quickStats, theme, isDarkMode),
                    const SizedBox(height: 12),
                    _buildQuickStats(locale, theme, isDarkMode),
                    const SizedBox(height: 24),
                    _buildSectionTitle(locale.quickActions, theme, isDarkMode),
                    const SizedBox(height: 12),
                    _buildActionCards(cards, theme, isDarkMode),
                    const SizedBox(height: 24),
                    _buildSectionTitle(locale.recentActivities, theme, isDarkMode),
                    const SizedBox(height: 12),
                    _buildRecentActivities(locale, theme, isDarkMode),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryBlue,
        child: const Icon(Icons.emergency_outlined, color: Colors.white),
        onPressed: () => _showEmergencyDialog(locale, theme, isDarkMode),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations locale, ThemeData theme, bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? AppConstants.darkBackground : AppConstants.primaryBlue,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: isDarkMode ? Colors.white : Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance, color: isDarkMode ? Colors.white : Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            locale.appName,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications, color: isDarkMode ? Colors.white : Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/user-notification');
                if (_notificationCount > 0) {
                  setState(() => _notificationCount = 0);
                }
              },
            ),
            if (_notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$_notificationCount',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSection(List<String> titles, List<String> subtitles, ThemeData theme, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _horizontalImages.length,
              onPageChanged: (index) => setState(() => _carouselIndex = index),
              itemBuilder: (context, index) {
                return Image.asset(
                  _horizontalImages[index],
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  color: isDarkMode ? Colors.black.withOpacity(0.3) : null,
                  colorBlendMode: isDarkMode ? BlendMode.darken : null,
                );
              },
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titles[_carouselIndex],
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitles[_carouselIndex],
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDots(theme, isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots(ThemeData theme, bool isDarkMode) {
    return Row(
      children: List.generate(
        _horizontalImages.length,
        (index) => Container(
          margin: const EdgeInsets.only(right: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _carouselIndex
                ? (isDarkMode ? Colors.white : AppConstants.primaryBlue)
                : (isDarkMode ? Colors.white38 : Colors.grey),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(AppLocalizations locale, ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDarkMode ? AppConstants.primaryBlue.withOpacity(0.1) : AppConstants.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.account_balance, color: AppConstants.primaryBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.heroTitle1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : AppConstants.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locale.splashTagline,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : AppConstants.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: isDarkMode ? Colors.white : AppConstants.black,
      ),
    );
  }

  Widget _buildQuickStats(AppLocalizations locale, ThemeData theme, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            locale.openSpaces,
            '47',
            Icons.park_outlined,
            theme,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            locale.activeReports,
            '12',
            Icons.report_outlined,
            theme,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            locale.bookings,
            '8',
            Icons.event_outlined,
            theme,
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppConstants.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDarkMode ? AppConstants.primaryBlue.withOpacity(0.1) : AppConstants.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppConstants.primaryBlue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDarkMode ? Colors.white : AppConstants.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : AppConstants.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(List<_CardData> cards, ThemeData theme, bool isDarkMode) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final card = cards[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, card.route),
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppConstants.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppConstants.primaryBlue.withOpacity(0.1) : AppConstants.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(card.icon, color: AppConstants.primaryBlue, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    card.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : AppConstants.black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : AppConstants.grey,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivities(AppLocalizations locale, ThemeData theme, bool isDarkMode) {
    if (_isLoadingActivities) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentActivities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No recent activities found.",
            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: _recentActivities.map((activity) {
        return _buildActivityItem(
          activity.icon,
          activity.title,
          activity.subtitle,
          _formatDate(activity.date),
          activity.iconColor,
          theme,
          isDarkMode,
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String subtitle,
    String time,
    Color iconColor,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDarkMode ? AppConstants.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDarkMode ? Colors.white : AppConstants.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : AppConstants.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white38 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog(AppLocalizations locale, ThemeData theme, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppConstants.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          locale.emergencyContacts,
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEmergencyContact(locale.police, '112', theme, isDarkMode),
            _buildEmergencyContact(locale.fire, '114', theme, isDarkMode),
            _buildEmergencyContact(locale.ambulance, '115', theme, isDarkMode),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              locale.close,
              style: TextStyle(color: AppConstants.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(String title, String number, ThemeData theme, bool isDarkMode) {
    return ListTile(
      leading: const Icon(Icons.phone, color: Colors.redAccent),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : AppConstants.black,
        ),
      ),
      subtitle: Text(
        number,
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.white70 : AppConstants.grey,
        ),
      ),
      onTap: () {
        // TODO: Integrate dialer functionality here
      },
    );
  }
}
