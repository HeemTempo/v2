import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class SplashScreenContent extends StatefulWidget {
  const SplashScreenContent({super.key});

  @override
  _SplashScreenContentState createState() => _SplashScreenContentState();
}

class _SplashScreenContentState extends State<SplashScreenContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<LocaleProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryBlue,
            // ignore: deprecated_member_use
            AppConstants.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Semantics(
            label: 'OpenSpace App Logo',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.public,
                  size: 120,
                  color: AppConstants.white,
                ),
                const SizedBox(height: 16),

                // ✅ Localized App Name
                Text(
                  AppLocalizations.of(context)!.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 1.2,
                      ),
                ),

                const SizedBox(height: 8),

                // ✅ Localized tagline
                Text(
                  AppLocalizations.of(context)!.splashTagline,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
