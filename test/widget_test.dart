import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:tct_plus_calc/main.dart';

void main() {
  testWidgets('App smoke test — renders without error', (WidgetTester tester) async {
    tz.initializeTimeZones();
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
