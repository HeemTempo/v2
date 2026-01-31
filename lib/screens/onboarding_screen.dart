import 'package:flutter/material.dart';
import '../utils/constants.dart';

class OnboardingScreenContent extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String imagePath;

  const OnboardingScreenContent({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Environment-aware colors
    final backgroundColor = theme.scaffoldBackgroundColor;
    final accentColor = isDark ? Colors.greenAccent : AppConstants.primaryBlue;
    final iconBgColor = isDark 
        ? Colors.greenAccent.withOpacity(0.1) 
        : AppConstants.primaryBlue.withOpacity(0.1);
    final cardColor = theme.cardColor;
    
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 100,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Semantics(
              label: title,
              child: Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Semantics(
                label: description,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
