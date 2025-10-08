import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    print("🎨 CustomBottomNavBar Theme Info:");
    print("   Brightness: ${theme.brightness}");
    print("   Background: ${theme.scaffoldBackgroundColor}");
    print("   Primary: ${colorScheme.primary}");
    print("   OnPrimary: ${colorScheme.onPrimary}");

    return CurvedNavigationBar(
      index: currentIndex,
      height: 60.0,
      backgroundColor:
          theme.scaffoldBackgroundColor, // Match scaffold background
      color: colorScheme.primary, // Theme-based primary color
      buttonBackgroundColor: colorScheme.primary.withOpacity(
        0.9,
      ), // Slightly transparent
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        Icon(Icons.home, size: 22, color: colorScheme.onPrimary),
        Icon(Icons.explore, size: 22, color: colorScheme.onPrimary),
        Icon(Icons.person, size: 22, color: colorScheme.onPrimary),
      ],
      onTap: (index) => onTap(index),
    );
  }
}
