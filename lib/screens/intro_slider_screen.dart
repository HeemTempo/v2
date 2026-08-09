import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../l10n/app_localizations.dart';
import '../model/user_model.dart';
import '../providers/user_provider.dart';
import '../service/auth_service.dart';
import '../utils/constants.dart';
import 'onboarding_screen.dart';
import 'splash_screen.dart';
import 'user_type.dart';

class IntroSliderScreen extends StatefulWidget {
  const IntroSliderScreen({super.key});

  @override
  State<IntroSliderScreen> createState() => _IntroSliderScreenState();
}

class _IntroSliderScreenState extends State<IntroSliderScreen> {
  static const int _pageCount = 4;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSession());
  }

  Future<void> _restoreSession() async {
    try {
      final user = await AuthService().getOfflineUser();
      if (user == null || !mounted) return;

      context.read<UserProvider>().setUser(user);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      debugPrint('Unable to restore session: $error');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _onUserTypeSelected(String? userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;

    context.read<UserProvider>().setUser(User.anonymous());
    Navigator.pushReplacementNamed(
      context,
      userType == 'Registered User' ? '/login' : '/home',
    );
  }

  void _goToPage(int page) {
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isLastPage = _currentPage == _pageCount - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final overlayStyle =
        _currentPage == 0
            ? SystemUiOverlayStyle.light
            : isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor:
            isDark ? AppConstants.darkBackground : AppConstants.pageBackground,
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                const SplashScreenContent(),
                OnboardingScreenContent(
                  title: loc.onboardingTitle1,
                  description: loc.onboardingDescription1,
                  icon: Icons.report_outlined,
                  imagePath: 'assets/images/kinondoni-report-v2.jpg',
                ),
                OnboardingScreenContent(
                  title: loc.onboardingTitle2,
                  description: loc.onboardingDescription2,
                  icon: Icons.calendar_month_outlined,
                  imagePath: 'assets/images/kinondoni-booking-v2.jpg',
                ),
                UserTypeScreenContent(onUserTypeSelected: _onUserTypeSelected),
              ],
            ),
            if (!isLastPage)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                right: 12,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(loc.skipButton),
                ),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 28,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppConstants.darkCard.withValues(alpha: 0.96)
                          : Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        isDark ? AppConstants.darkBorder : AppConstants.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.navy.withValues(
                        alpha: isDark ? 0.28 : 0.13,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentPage > 0 && !isLastPage)
                      IconButton.outlined(
                        onPressed: () => _goToPage(_currentPage - 1),
                        tooltip: loc.backButton,
                        icon: const Icon(Icons.arrow_back_rounded),
                      )
                    else
                      const SizedBox(width: 48),
                    const Spacer(),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pageCount,
                      effect: ExpandingDotsEffect(
                        dotHeight: 7,
                        dotWidth: 7,
                        spacing: 6,
                        expansionFactor: 3,
                        dotColor:
                            isDark
                                ? AppConstants.darkBorder
                                : AppConstants.border,
                        activeDotColor: AppConstants.primaryGreen,
                      ),
                      onDotClicked: _goToPage,
                    ),
                    const Spacer(),
                    if (!isLastPage)
                      IconButton.filled(
                        onPressed: () => _goToPage(_currentPage + 1),
                        tooltip: loc.nextButton,
                        icon: const Icon(Icons.arrow_forward_rounded),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
