// lib/services/preference_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _languageKey = 'language';
  static const String _lastLatKey = 'last_lat';
  static const String _lastLonKey = 'last_lon';

  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> saveLastMapPosition(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastLatKey, lat);
    await prefs.setDouble(_lastLonKey, lon);
  }

  Future<Map<String, double>?> getLastMapPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_lastLatKey);
    final lon = prefs.getDouble(_lastLonKey);
    if (lat != null && lon != null) {
      return {'lat': lat, 'lon': lon};
    }
    return null;
  }
}