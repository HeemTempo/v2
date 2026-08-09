import 'package:flutter_test/flutter_test.dart';
import 'package:kinondoni_openspace_app/utils/theme.dart';

void main() {
  test('app themes can be constructed', () {
    expect(AppTheme.lightTheme, isNotNull);
    expect(AppTheme.darkTheme, isNotNull);
  });
}
