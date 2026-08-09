import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const generatedAssets = <String>[
    'assets/images/kinondoni-onboarding-v2.jpg',
    'assets/images/kinondoni-home-hero-v2.jpg',
    'assets/images/kinondoni-report-v2.jpg',
    'assets/images/kinondoni-booking-v2.jpg',
  ];

  for (final assetPath in generatedAssets) {
    test('bundles and loads $assetPath', () async {
      final data = await rootBundle.load(assetPath);
      expect(data.lengthInBytes, greaterThan(100000));

      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(500));
      expect(frame.image.height, greaterThan(500));
      codec.dispose();
    });
  }
}
