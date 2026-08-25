import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kinondoni_openspace_app/service/PasswordService.dart';

void main() {
  group('PasswordService', () {
    test('requests a mobile reset link from the expected endpoint', () async {
      late http.Request capturedRequest;
      final service = PasswordService(
        baseUrl: 'https://api.example.test/api/v1/',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'message': 'Reset email queued.'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final message = await service.requestPasswordReset(' USER@example.com ');
      final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;

      expect(
        capturedRequest.url.toString(),
        'https://api.example.test/api/v1/password-reset/',
      );
      expect(body, {'email': 'USER@example.com', 'client': 'mobile'});
      expect(message, 'Reset email queued.');
    });

    test('confirms the reset using the backend response contract', () async {
      late http.Request capturedRequest;
      final service = PasswordService(
        baseUrl: 'https://api.example.test/api/v1',
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({'message': 'Password reset successful.'}),
            200,
          );
        }),
      );

      final message = await service.confirmPasswordReset(
        uid: 'MQ',
        token: 'token-value',
        newPassword: 'NewStrongPass456!',
      );
      final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;

      expect(
        capturedRequest.url.toString(),
        'https://api.example.test/api/v1/password-reset-confirm/',
      );
      expect(body['uid'], 'MQ');
      expect(body['token'], 'token-value');
      expect(body['password'], 'NewStrongPass456!');
      expect(message, 'Password reset successful.');
    });

    test('preserves useful backend errors', () async {
      final service = PasswordService(
        baseUrl: 'https://api.example.test/api/v1',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'error': 'This reset link has expired.'}),
            400,
          ),
        ),
      );

      expect(
        () => service.confirmPasswordReset(
          uid: 'MQ',
          token: 'expired',
          newPassword: 'NewStrongPass456!',
        ),
        throwsA(
          isA<PasswordServiceException>()
              .having((error) => error.statusCode, 'statusCode', 400)
              .having(
                (error) => error.message,
                'message',
                'This reset link has expired.',
              ),
        ),
      );
    });

    test('enforces the configured request timeout', () async {
      final service = PasswordService(
        baseUrl: 'https://api.example.test/api/v1',
        requestTimeout: const Duration(milliseconds: 5),
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 40));
          return http.Response('{}', 200);
        }),
      );

      expect(
        () => service.requestPasswordReset('user@example.com'),
        throwsA(
          isA<PasswordServiceException>().having(
            (error) => error.message,
            'message',
            contains('timed out'),
          ),
        ),
      );
    });
  });
}
