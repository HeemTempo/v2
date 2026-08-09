import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
      ),
      primaryColor: AppConstants.primaryGreen,
      scaffoldBackgroundColor: AppConstants.pageBackground,
      cardColor: AppConstants.white,
      shadowColor: AppConstants.navy.withValues(alpha: 0.10),
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryGreen,
        onPrimary: AppConstants.white,
        primaryContainer: AppConstants.primaryGreenSoft,
        onPrimaryContainer: AppConstants.primaryGreenDark,
        secondary: AppConstants.accentMint,
        onSecondary: AppConstants.navy,
        tertiary: AppConstants.info,
        onTertiary: AppConstants.white,
        error: AppConstants.danger,
        onError: AppConstants.white,
        surface: AppConstants.white,
        onSurface: AppConstants.navy,
        outline: AppConstants.border,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: AppConstants.white,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryGreen,
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
        bodyMedium: TextStyle(fontSize: 16, color: AppConstants.black),
        bodySmall: TextStyle(fontSize: 14, color: AppConstants.grey),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.white,
        hintStyle: const TextStyle(color: AppConstants.muted),
        labelStyle: const TextStyle(color: AppConstants.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppConstants.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.danger, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppConstants.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryGreen,
          foregroundColor: AppConstants.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryGreen,
          side: const BorderSide(color: AppConstants.border),
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
      ),
      primaryColor: AppConstants.accentMint,
      scaffoldBackgroundColor: AppConstants.darkBackground,
      cardColor: AppConstants.darkCard,
      shadowColor: Colors.black.withValues(alpha: 0.30),
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.accentMint,
        onPrimary: AppConstants.darkBackground,
        primaryContainer: AppConstants.darkCardAlt,
        onPrimaryContainer: AppConstants.darkText,
        secondary: AppConstants.primaryGreen,
        onSecondary: AppConstants.white,
        tertiary: AppConstants.info,
        onTertiary: AppConstants.white,
        error: AppConstants.danger,
        onError: AppConstants.white,
        surface: AppConstants.darkCard,
        onSurface: AppConstants.darkText,
        outline: AppConstants.darkBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.darkBackground,
        foregroundColor: AppConstants.darkText,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConstants.accentMint,
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
        bodyMedium: TextStyle(fontSize: 16, color: AppConstants.darkText),
        bodySmall: TextStyle(
          fontSize: 14,
          color: AppConstants.darkTextSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.darkCardAlt,
        hintStyle: const TextStyle(color: AppConstants.darkTextSecondary),
        labelStyle: const TextStyle(color: AppConstants.darkTextSecondary),
        prefixIconColor: AppConstants.darkTextSecondary,
        suffixIconColor: AppConstants.darkTextSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppConstants.accentMint,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.danger, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppConstants.darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.accentMint,
          foregroundColor: AppConstants.darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.accentMint,
          side: const BorderSide(color: AppConstants.darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
