import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../utils/constants.dart';
import 'side_bar.dart';
import '../data/repository/report_repository.dart';
import '../data/repository/booking_repository.dart';
import '../data/local/report_local.dart';
import '../service/openspace_service.dart';
import '../providers/user_provider.dart';

class HomeTab extends StatefulWidget {
  final Function(int) onTabChange;
  
  const HomeTab({super.key, required this.onTabChange});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _CardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final int? tabIndex; // Optional: if this card should switch tab instead of route
  
  const _CardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    this.tabIndex,
  });
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _carouselIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  Timer? _autoScrollTimer;
  bool _isAppInForeground = true;
  
  // Quick Stats counts
  int _openSpacesCount = 0;
  int _activeReportsCount = 0;
  int _bookingsCount = 0;
  bool _isLoadingStats = true;

  final List<String> _horizontalImages = [
    'assets/images/green_space.jpg',
    'assets/images/green_space2.jpg',
    'assets/images/green_space.jpg',
    'assets/images/green_space2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _startAutoScroll();
    
    // Defer data loading to prevent blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchQuickStats();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        _startAutoScroll();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _isAppInForeground = false;
        _autoScrollTimer?.cancel();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _fetchQuickStats() async {
    if (!mounted) return;
    setState(() => _isLoadingStats = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isAnonymous = userProvider.user.isAnonymous;

    int openSpaces = 0;
    int reports = 0;
    int bookings = 0;

    try {
      // 1. Fetch Open Spaces (For Everyone)
      try {
        final openSpaceService = OpenSpaceService();
        openSpaces = await openSpaceService.getOpenSpaceCount().timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('Error fetching open spaces: $e');
      }

      // 2. Fetch Personal Stats (Authenticated Only)
      if (!isAnonymous) {
        // Fetch Reports
        try {
          final reportRepo = ReportRepository(localService: ReportLocal());
          // Repo handles caching/offline logic
          final allReports = await reportRepo.getAllReports(); 
          
          final activeReports = allReports.where((r) => 
            r.status?.toLowerCase() == 'pending' || 
            r.status?.toLowerCase() == 'in_progress'
          ).toList();
          reports = activeReports.length;
        } catch (e) {
          debugPrint('Error fetching reports stats: $e');
        }

        // Fetch Bookings
        try {
          final bookingRepo = BookingRepository();
          final allBookings = await bookingRepo.getMyBookings();
          bookings = allBookings.length;
        } catch (e) {
          debugPrint('Error fetching bookings stats: $e');
        }
      }

      if (mounted) {
        setState(() {
          _openSpacesCount = openSpaces;
          _activeReportsCount = reports;
          _bookingsCount = bookings;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
       debugPrint('Unexpected error in _fetchQuickStats: $e');
       if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (!_isAppInForeground) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && mounted && _isAppInForeground) {
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
    WidgetsBinding.instance.removeObserver(this);
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isAnonymous = Provider.of<UserProvider>(context, listen: false).user.isAnonymous;

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
        route: '/map', // This might need to be handled differently if it's a tab
        tabIndex: 1, // Map tab
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
        tabIndex: 1, // Map tab
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
      appBar: _buildAppBar(locale, theme, isDarkMode, isAnonymous),
      body: RefreshIndicator(
        onRefresh: _fetchQuickStats,
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
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryBlue,
        child: const Icon(Icons.emergency_outlined, color: Colors.white),
        onPressed: () => _showEmergencyDialog(locale, theme, isDarkMode),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations locale, ThemeData theme, bool isDarkMode, bool isAnonymous) {
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
            color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
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
                  color: isDarkMode ? Colors.black.withValues(alpha: 0.3) : null,
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
            color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
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
              color: isDarkMode ? AppConstants.primaryBlue.withValues(alpha: 0.1) : AppConstants.primaryBlue.withValues(alpha: 0.1),
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
    if (_isLoadingStats) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            locale.openSpaces,
            '$_openSpacesCount',
            Icons.park_outlined,
            theme,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            locale.activeReports,
            '$_activeReportsCount',
            Icons.report_outlined,
            theme,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            locale.bookings,
            '$_bookingsCount',
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
            color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
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
              color: isDarkMode ? AppConstants.primaryBlue.withValues(alpha: 0.1) : AppConstants.primaryBlue.withValues(alpha: 0.1),
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
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final card = cards[index];
          return GestureDetector(
            onTap: () {
              if (card.tabIndex != null) {
                widget.onTabChange(card.tabIndex!);
              } else {
                Navigator.pushNamed(context, card.route);
              }
            },
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppConstants.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
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
                      color: isDarkMode ? AppConstants.primaryBlue.withValues(alpha: 0.1) : AppConstants.primaryBlue.withValues(alpha: 0.1),
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
              style: TextStyle(color: isDarkMode ? Colors.white : AppConstants.primaryBlue),
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
      onTap: () async {
        final uri = Uri(scheme: 'tel', path: number);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
    );
  }
}
