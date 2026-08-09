import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinondoni_openspace_app/config/app_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final environmentFile in ['.env.development', '.env.production']) {
    test('$environmentFile uses the verified online backend', () async {
      final contents = await File(environmentFile).readAsString();
      dotenv.loadFromString(envString: contents);

      expect(Uri.parse(AppConfig.baseUrl).host, AppConfig.onlineBackendHost);
      expect(Uri.parse(AppConfig.graphqlUrl).host, AppConfig.onlineBackendHost);
      expect(
        Uri.parse(AppConfig.healthCheckUrl).host,
        AppConfig.onlineBackendHost,
      );
      expect(Uri.parse(AppConfig.baseUrl).scheme, 'https');
      expect(AppConfig.graphqlUrl, endsWith('/graphql/'));
      expect(AppConfig.healthCheckUrl, endsWith('/health/'));
    });
  }

  test('rejects emulator and localhost backend URLs', () {
    dotenv.loadFromString(
      envString: '''
BASE_URL=http://10.0.2.2:8000/
GRAPHQL_URL=http://localhost:8000/graphql/
HEALTH_CHECK_URL=http://127.0.0.1:8000/health/
''',
    );

    expect(() => AppConfig.baseUrl, throwsStateError);
    expect(() => AppConfig.graphqlUrl, throwsStateError);
    expect(() => AppConfig.healthCheckUrl, throwsStateError);
  });
}
