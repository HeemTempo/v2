import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../utils/constants.dart';

class UserTypeScreenContent extends StatelessWidget {
  const UserTypeScreenContent({super.key, required this.onUserTypeSelected});

  final ValueChanged<String?> onUserTypeSelected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppConstants.darkCard : Colors.white;
    final border = isDark ? AppConstants.darkBorder : AppConstants.border;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 54, 20, 148),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 174,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/kinondoni-onboarding-v2.jpg',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, 0.22),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xB307543F)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 14,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.park_rounded,
                          color: AppConstants.primaryGreen,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.userTypeTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: isDark ? Colors.white : AppConstants.navy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              loc.userTypeDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: isDark ? Colors.white70 : AppConstants.muted,
              ),
            ),
            const SizedBox(height: 32),
            _AccessOption(
              icon: Icons.login_rounded,
              title: loc.signInRegisteredButton,
              subtitle: '${loc.reportIssue}  /  ${loc.bookSpace}',
              backgroundColor: AppConstants.primaryGreen,
              foregroundColor: Colors.white,
              borderColor: AppConstants.primaryGreen,
              onTap: () {
                HapticFeedback.lightImpact();
                onUserTypeSelected('Registered User');
              },
            ),
            const SizedBox(height: 12),
            _AccessOption(
              icon: Icons.explore_outlined,
              title: loc.continueAnonymousButton,
              subtitle: loc.openSpaces,
              backgroundColor: surface,
              foregroundColor: isDark ? Colors.white : AppConstants.navy,
              borderColor: border,
              onTap: () {
                HapticFeedback.lightImpact();
                onUserTypeSelected('Anonymous User');
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/terms'),
                child: Text(loc.termsPrivacyButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessOption extends StatelessWidget {
  const _AccessOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: foregroundColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: foregroundColor, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: foregroundColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: foregroundColor.withValues(alpha: 0.72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: foregroundColor),
            ],
          ),
        ),
      ),
    );
  }
}
