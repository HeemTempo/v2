import 'package:flutter/material.dart';

class AppConstants {
  // Shared palette with the Angular user portal.
  static const primaryGreen = Color(0xFF08795C);
  static const primaryGreenDark = Color(0xFF07543F);
  static const primaryGreenSoft = Color(0xFFE9F6F1);
  static const accentMint = Color(0xFF63D1AA);
  static const navy = Color(0xFF173F4A);
  static const muted = Color(0xFF6D827D);
  static const border = Color(0xFFDCE8E5);
  static const pageBackground = Color(0xFFF5F9F8);
  static const danger = Color(0xFFC75043);
  static const dangerDark = Color(0xFF91372E);
  static const warning = Color(0xFFD58B24);
  static const info = Color(0xFF2B7C9F);

  // Backward-compatible aliases while older screens are migrated.
  static const primaryBlue = primaryGreen;
  static const primaryBlueOpacity = Color(0xE608795C);
  static const lightAccent = accentMint;
  static const white = Color(0xFFFFFFFF);
  static const black = navy;
  static const grey = muted;
  static const lightGrey = pageBackground;
  static const purple = Color(0xFFD529DC);
  static const String appName = 'Kinondoni Open Space';

  // Dark theme
  static const darkBackground = Color(0xFF071F27);
  static const darkCard = Color(0xFF10343D);
  static const darkCardAlt = Color(0xFF153E46);
  static const darkBorder = Color(0xFF2B5357);
  static const darkText = Color(0xFFEDF7F4);
  static const darkTextSecondary = Color(0xFFA7BEBC);
}
