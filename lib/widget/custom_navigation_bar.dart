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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CurvedNavigationBar(
      index: currentIndex,
      height: 60.0,
      backgroundColor: isDark ? Colors.grey[900]! : Colors.grey[100]!,
      color: isDark ? Colors.grey[850]! : Colors.white,
      buttonBackgroundColor: isDark ? Colors.grey[800]! : const Color(0xFF2196F3),
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        Icon(Icons.home, size: 22, color: isDark ? Colors.white : Colors.white),
        Icon(Icons.explore, size: 22, color: isDark ? Colors.white : Colors.white),
        if (!isAnonymous) Icon(Icons.person, size: 22, color: isDark ? Colors.white : Colors.white),
      ],
      onTap: (index) => onTap(index),
    );
  }
}
