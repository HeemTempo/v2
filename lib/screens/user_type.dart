import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

import '../utils/constants.dart';

class UserTypeScreenContent extends StatelessWidget {
  final Function(String?) onUserTypeSelected;

  const UserTypeScreenContent({super.key, required this.onUserTypeSelected});

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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // 🔹 Attractive Illustration Placeholder (Using Icon for now)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    size: 100,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 40),
                Semantics(
                  label: loc.userTypeTitle,
                  child: Text(
                    loc.userTypeTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppConstants.primaryBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    loc.userTypeDescription,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Column(
                  children: [
                    // 🔹 Registered User Button (Primary Action)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onUserTypeSelected('Registered User');
                        },
                        icon: const Icon(Icons.login_rounded),
                        label: Text(loc.signInRegisteredButton),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 🔹 Anonymous User Button (Secondary Action)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onUserTypeSelected('Anonymous User');
                        },
                        icon: Icon(Icons.person_outline, 
                          color: isDark ? Colors.white70 : Colors.black87),
                        label: Text(
                          loc.continueAnonymousButton,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/terms'),
                      child: Text(
                        loc.termsPrivacyButton,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
