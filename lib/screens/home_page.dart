import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../widget/custom_navigation_bar.dart';
import 'side_bar.dart';

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
      body: SingleChildScrollView(
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : AppConstants.grey,
                    ),
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
    return Column(
      children: [
        _buildActivityItem(
          Icons.info,
          locale.newReportSubmitted,
          'Magomeni Open Space',
          '2 hours ago',
          AppConstants.primaryBlue,
          theme,
          isDarkMode,
        ),
        _buildActivityItem(
          Icons.event_available,
          locale.spaceBooked,
          'Mwenge Park',
          '5 hours ago',
          AppConstants.lightAccent,
          theme,
          isDarkMode,
        ),
        _buildActivityItem(
          Icons.check_circle,
          locale.issueResolved,
          'Ilala Open Space',
          '1 day ago',
          AppConstants.purple,
          theme,
          isDarkMode,
        ),
      ],
    );
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
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
      subtitle: Text(
        "$subtitle • $time",
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.white70 : AppConstants.grey,
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