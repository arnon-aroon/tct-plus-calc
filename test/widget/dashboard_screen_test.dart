import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:tct_plus_calc/main.dart';

Widget _app() {
  tz.initializeTimeZones();
  SharedPreferences.setMockInitialValues({});
  return const MyApp();
}

void main() {
  group('DashboardScreen render-correctness', () {
    testWidgets('1. renders without overflow at 360×640', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('2. bill input rejects letters and symbols', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final field = find.byType(TextField);
      await tester.tap(field);
      await tester.pump();

      await tester.enterText(field, '123');
      expect(find.widgetWithText(TextField, '123'), findsOneWidget);

      await tester.enterText(field, 'abc');
      final tf = tester.widget<TextField>(field);
      expect(tf.controller!.text, isEmpty);

      await tester.enterText(field, '!@#');
      expect(tf.controller!.text, isEmpty);
    });

    testWidgets('3. Log button disabled when empty, enabled with valid number',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final button = find.widgetWithText(FilledButton, 'Log Transaction');
      expect(tester.widget<FilledButton>(button).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '100');
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
    });
  });
}
