import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String onlineBackendHost = 'kinodonibackend.ubunix.co.tz';

  static String get baseUrl {
    return _validatedBackendUrl('BASE_URL');
  }

  static String get graphqlUrl {
    return _validatedBackendUrl('GRAPHQL_URL');
  }

  static String get healthCheckUrl {
    return _validatedBackendUrl('HEALTH_CHECK_URL');
  }

  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  static Future<void> load({String envFile = '.env.development'}) async {
    await dotenv.load(fileName: envFile);

    // Fail during startup instead of silently using an emulator, localhost,
    // insecure HTTP, or a different backend host.
    baseUrl;
    graphqlUrl;
    healthCheckUrl;
  }

  static String _validatedBackendUrl(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('$key is missing from the environment configuration.');
    }

    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https' || uri.host != onlineBackendHost) {
      throw StateError(
        '$key must use https://$onlineBackendHost. Received: $value',
      );
    }

    return value;
  }
}
