import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) throw Exception('BASE_URL not found in .env file');
    return url;
  }

  static String get graphqlUrl {
    final url = dotenv.env['GRAPHQL_URL'];
    if (url == null || url.isEmpty) throw Exception('GRAPHQL_URL not found in .env file');
    return url;
  }

  static String get healthCheckUrl {
    final url = dotenv.env['HEALTH_CHECK_URL'];
    if (url == null || url.isEmpty) throw Exception('HEALTH_CHECK_URL not found in .env file');
    return url;
  }

  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  static Future<void> load({String envFile = '.env.development'}) async {
    await dotenv.load(fileName: envFile);
  }
}
