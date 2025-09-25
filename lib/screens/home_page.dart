import 'dart:async';
import 'package:flutter/material.dart';
import 'package:openspace_mobile_app/screens/side_bar.dart';
import 'package:openspace_mobile_app/utils/constants.dart';
import 'package:openspace_mobile_app/widget/custom_navigation_bar.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _carouselIndex = 0;
  final PageController _pageController = PageController();
  int _notificationCount = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _autoScrollTimer;

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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _notificationCount = 1);
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _notificationCount = 0);
    });

    _startAutoScroll();
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
      backgroundColor: Colors.white,
      drawer: const Sidebar(),
      appBar: _buildAppBar(locale),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(heroTitles, heroSubtitles),
              const SizedBox(height: 16),
              _buildInfoCard(locale),
              const SizedBox(height: 24),
              _buildSectionTitle(locale.quickStats),
              const SizedBox(height: 12),
              _buildQuickStats(locale),
              const SizedBox(height: 24),
              _buildSectionTitle(locale.quickActions),
              const SizedBox(height: 12),
              _buildActionCards(cards),
              const SizedBox(height: 24),
              _buildSectionTitle(locale.recentActivities),
              const SizedBox(height: 12),
              _buildRecentActivities(locale),
              const SizedBox(height: 100),
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
        onPressed: () => _showEmergencyDialog(locale),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations locale) {
    return AppBar(
      backgroundColor: AppConstants.primaryBlue,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            locale.appName,
            style: const TextStyle(
              color: Colors.white,
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
              icon: const Icon(Icons.notifications, color: Colors.white),
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
                  decoration: const BoxDecoration(
                    color: Colors.red,
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

  Widget _buildHeroSection(List<String> titles, List<String> subtitles) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitles[_carouselIndex],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDots(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      children: List.generate(
        _horizontalImages.length,
        (index) => Container(
          margin: const EdgeInsets.only(right: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _carouselIndex
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(AppLocalizations locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_balance,
            color: AppConstants.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.heroTitle1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locale.splashTagline,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildQuickStats(AppLocalizations locale) {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(locale.openSpaces, '47', Icons.park_outlined)),
        const SizedBox(width: 12),
        Expanded(
            child:
                _buildStatCard(locale.activeReports, '12', Icons.report_outlined)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(locale.bookings, '8', Icons.event_outlined)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppConstants.primaryBlue, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(List<_CardData> cards) {
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(card.icon, color: AppConstants.primaryBlue, size: 28),
                  const SizedBox(height: 12),
                  Text(
                    card.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivities(AppLocalizations locale) {
    return Column(
      children: [
        _buildActivityItem(
          Icons.info,
          locale.newReportSubmitted,
          'Magomeni Open Space',
          '2 hours ago',
          AppConstants.primaryBlue,
        ),
        _buildActivityItem(
          Icons.event_available,
          locale.spaceBooked,
          'Mwenge Park',
          '5 hours ago',
          Colors.green,
        ),
        _buildActivityItem(
          Icons.check_circle,
          locale.issueResolved,
          'Ilala Open Space',
          '1 day ago',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      IconData icon, String title, String subtitle, String time, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('$subtitle • $time'),
    );
  }

  void _showEmergencyDialog(AppLocalizations locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locale.emergencyContacts),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEmergencyContact(locale.police, '112'),
            _buildEmergencyContact(locale.fire, '114'),
            _buildEmergencyContact(locale.ambulance, '115'),
          ],
        ),
        actions: [
          TextButton(
            child: Text(locale.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(String title, String number) {
    return ListTile(
      leading: const Icon(Icons.phone, color: Colors.red),
      title: Text(title),
      subtitle: Text(number),
      onTap: () {
        // Implement dialer integration here if needed
      },
    );
  }
}
