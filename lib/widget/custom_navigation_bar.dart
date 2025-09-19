import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../utils/constants.dart';
 // Replace with your constants file

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
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: IconThemeData(color: Colors.white)
      ),
      child: CurvedNavigationBar(
        index: currentIndex,
        height: 60.0,
        backgroundColor: Colors.transparent,
        color: AppConstants.primaryBlue,
        buttonBackgroundColor: AppConstants.primaryBlueOpacity,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, size: 22),
          Icon(Icons.explore, size: 22),
          Icon(Icons.person, size: 22),
        ],
        onTap: (index) => onTap(index),
      ),
    );
  }
}
