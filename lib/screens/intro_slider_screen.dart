import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinondoni_openspace_app/screens/splash_screen.dart';
import 'package:kinondoni_openspace_app/service/auth_service.dart';
import 'package:kinondoni_openspace_app/screens/user_type.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../model/user_model.dart';
import 'onboarding_screen.dart';
import '../l10n/app_localizations.dart';

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({super.key});

  @override
  State<IntroSliderScreen> createState() => _IntroSliderScreenState();
}

class _IntroSliderScreenState extends State<IntroSliderScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _autoScrollTimer;
  final bool _autoScrollEnabled = true;

  @override
  void initState() {
    super.initState();
    
    // Check onboarding AFTER the frame is built to avoid white screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboardingStatus();
    });
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _startAutoScroll();
  }

  void _checkOnboardingStatus() async {
    try {
      // Check for saved registered user session
      final authService = AuthService();
      final user = await authService.getOfflineUser();

      if (user != null && mounted) {
        // Found registered user - Restore session and go to Home
        print("✅ Session restored for: ${user.username}");
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }
      
      // If no registered user found, stay on Intro Screen (Fresh start for Anonymous)
      print("ℹ️ No registered session found. Starting fresh.");
      
    } catch (e) {
      print('❌ Error checking session status: $e');
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_autoScrollEnabled && _currentPage < 4) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted || !_pageController.hasClients) return;
        _nextPage();
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _startAutoScroll();
  }

  void _nextPage() {
    if (!mounted || !_pageController.hasClients) return;
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (!mounted || !_pageController.hasClients) return;
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Navigator.pushReplacementNamed(context, !userProvider.user.isAnonymous ? '/home' : '/login');
  }

  void _onUserTypeSelected(String? userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userType == 'Registered User') {
      userProvider.setUser(User.anonymous());
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      userProvider.setUser(User.anonymous());
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: [
                const SplashScreenContent(),
                _HowToUseOnboardingContent(),
                OnboardingScreenContent(
                  title: loc.onboardingTitle1,
                  description: loc.onboardingDescription1,
                  icon: Icons.report_problem_rounded,
                  imagePath: 'assets/images/report1.jpg',
                ),
                OnboardingScreenContent(
                  title: loc.onboardingTitle2,
                  description: loc.onboardingDescription2,
                  icon: Icons.event_available_rounded,
                  imagePath: 'assets/images/openspace_detail.jpg',
                ),
                UserTypeScreenContent(onUserTypeSelected: _onUserTypeSelected),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: _currentPage < 4
                ? TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _skipOnboarding();
                    },
                    child: Text(
                      loc.skipButton,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : AppConstants.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 5,
                  effect: WormEffect(
                    dotColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[700]! 
                        : Colors.grey[300]!,
                    activeDotColor: Theme.of(context).brightness == Brightness.dark 
                        ? AppConstants.primaryBlue 
                        : AppConstants.primaryBlue,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 16,
                    type: WormType.thin,
                  ),
                  onDotClicked: (index) {
                    HapticFeedback.lightImpact();
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentPage > 0
                          ? ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _previousPage();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.grey[800] 
                                    : Colors.grey[200],
                                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              child: Text(
                                loc.backButton,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            )
                          : const SizedBox(width: 60),
                      _currentPage < 4
                          ? ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _nextPage();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryBlue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                loc.nextButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const SizedBox(width: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowToUseOnboardingContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? Colors.greenAccent : AppConstants.primaryBlue;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info_outline, size: 80, color: accentColor),
              ),
              const SizedBox(height: 32),
              Text(
                loc.howToUseTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildInfoCard(
                context,
                Icons.wifi,
                loc.firstTimeUseTitle,
                loc.firstTimeUseDescription,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                Icons.offline_bolt,
                loc.offlineAccessTitle,
                loc.offlineAccessDescription,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                Icons.sync,
                loc.autoSyncTitle,
                loc.autoSyncDescription,
                Colors.purple,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, height: 1.4, color: textColor),
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
