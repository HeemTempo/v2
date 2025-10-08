import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppConstants.primaryBlue,
      scaffoldBackgroundColor: AppConstants.lightGrey,
      cardColor: AppConstants.white,
      shadowColor: AppConstants.black.withOpacity(0.1),
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryBlue,
        onPrimary: AppConstants.white,
        secondary: AppConstants.lightAccent,
        onSecondary: AppConstants.white,
        tertiary: Color(0xFF4CAF50),
        onTertiary: AppConstants.white,
        error: Color(0xFFD32F2F),
        onError: AppConstants.white,
        surface: AppConstants.white,
        onSurface: AppConstants.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: AppConstants.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryBlue,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppConstants.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppConstants.black,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppConstants.black,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppConstants.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: AppConstants.black,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: AppConstants.grey,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.white,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppConstants.primaryBlue),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryBlue,
          foregroundColor: AppConstants.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.white,
          side: const BorderSide(color: AppConstants.white, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppConstants.primaryBlue,
      scaffoldBackgroundColor: Colors.black, // Changed to pure black
      cardColor: AppConstants.darkCard,
      shadowColor: AppConstants.white.withOpacity(0.1),
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryBlue,
        onPrimary: Colors.black,
        secondary: AppConstants.lightAccent,
        onSecondary: Colors.black,
        tertiary: Color(0xFF81C784),
        onTertiary: Colors.black,
        error: Color(0xFFEF5350),
        onError: Colors.black,
        surface: AppConstants.darkCard,
        onSurface: AppConstants.darkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black, // Changed to pure black
        foregroundColor: AppConstants.darkText,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConstants.lightAccent,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppConstants.darkText,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppConstants.darkText,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppConstants.darkText,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppConstants.darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: AppConstants.darkText,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: AppConstants.darkTextSecondary,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.darkCard,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppConstants.primaryBlue),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryBlue,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.darkText,
          side: const BorderSide(color: AppConstants.darkText, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}