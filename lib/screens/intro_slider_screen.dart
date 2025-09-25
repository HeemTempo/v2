import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openspace_mobile_app/screens/splash_screen.dart';
import 'package:openspace_mobile_app/screens/user_type.dart';
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
    _checkOnboardingStatus();
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
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (hasSeenOnboarding) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.user.isAnonymous) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_autoScrollEnabled && _currentPage < 3) {
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
    if (_currentPage < 3) {
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
                OnboardingScreenContent(
                  title: loc.onboardingTitle1,
                  description: loc.onboardingDescription1,
                  icon: Icons.report,
                  imagePath: 'assets/images/report1.jpg',
                ),
                OnboardingScreenContent(
                  title: loc.onboardingTitle2,
                  description: loc.onboardingDescription2,
                  icon: Icons.park,
                  imagePath: 'assets/images/openspace_detail.jpg',
                ),
                UserTypeScreenContent(onUserTypeSelected: _onUserTypeSelected),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _skipOnboarding();
              },
              child: Text(
                loc.skipButton,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConstants.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 4,
                  effect: const WormEffect(
                    dotColor: AppConstants.grey,
                    activeDotColor: AppConstants.white,
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
                              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                backgroundColor: WidgetStateProperty.all(AppConstants.white),
                                foregroundColor: WidgetStateProperty.all(AppConstants.primaryBlue),
                              ),
                              child: Text(
                                loc.backButton,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.primaryBlue,
                                ),
                              ),
                            )
                          : const SizedBox(width: 60),
                      _currentPage < 3
                          ? ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _nextPage();
                              },
                              child: Text(
                                loc.nextButton,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
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
