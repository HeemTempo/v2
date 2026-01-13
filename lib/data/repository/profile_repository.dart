import 'package:kinondoni_openspace_app/data/local/rofile_local_data_source.dart';
import 'package:kinondoni_openspace_app/service/auth_service.dart';
import '../../service/ProfileService.dart';


class ProfileRepository {
  /// Fetch profile:
  /// 1. Try online
  /// 2. If success -> cache to SQLite + return
  /// 3. If fail -> return from SQLite if available
  static Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      final profileService = ProfileService();
      final profile = await profileService.fetchProfile(token);
      await ProfileLocalDataSource.cacheProfile(profile);
      return profile;
    } catch (e) {
      print("ProfileRepository: Online fetch failed, trying offline...");
      final cached = await ProfileLocalDataSource.getCachedProfile();
      if (cached != null) {
        print("ProfileRepository: Returning cached profile");
        return cached;
      }
      throw Exception("No profile data available (offline cache empty).");
    }
  }
}
