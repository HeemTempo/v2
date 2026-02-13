import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isAnonymous;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAnonymous = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = theme.appBarTheme;
    final isDark = theme.brightness == Brightness.dark;

    final navBarColor = appBarTheme.backgroundColor ?? colorScheme.primary;
    final navForegroundColor =
        appBarTheme.foregroundColor ?? colorScheme.onPrimary;
    final selectedButtonColor =
        isDark
            ? Color.alphaBlend(
              Colors.white.withValues(alpha: 0.10),
              navBarColor,
            )
            : Color.alphaBlend(
              Colors.white.withValues(alpha: 0.20),
              navBarColor,
            );

    return CurvedNavigationBar(
      index: currentIndex,
      height: 60.0,
      backgroundColor: theme.scaffoldBackgroundColor,
      color: navBarColor,
      buttonBackgroundColor: selectedButtonColor,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        Icon(Icons.home, size: 22, color: navForegroundColor),
        Icon(Icons.explore, size: 22, color: navForegroundColor),
        if (!isAnonymous)
          Icon(Icons.person, size: 22, color: navForegroundColor),
      ],
      onTap: (index) => onTap(index),
    );
  }
}
