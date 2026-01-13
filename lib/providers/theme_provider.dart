import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Loads the saved theme preference from SharedPreferences.
  /// Defaults to light mode if no preference is found.
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString('themeMode') ?? 'light';
      setTheme(theme);
    } catch (e) {
      print('Error loading theme: $e');
      // Fallback to light mode if loading fails
      setTheme('light');
    }
  }

  /// Toggles the theme between light and dark mode and saves the preference.
  Future<void> toggleTheme(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      await prefs.setString('themeMode', isDarkMode ? 'dark' : 'light');
      notifyListeners();
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }

  /// Sets the theme based on a string value ('light' or 'dark') and saves it.
  Future<void> setTheme(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;
      await prefs.setString('themeMode', mode);
      notifyListeners();
    } catch (e) {
      print('Error setting theme: $e');
    }
  }
}
