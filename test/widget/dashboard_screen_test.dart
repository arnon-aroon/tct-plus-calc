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
      // Drain async initState (SharedPreferences + ledger init).
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('2. bill input rejects letters and symbols', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      final field = find.byType(TextField);
      await tester.tap(field);
      await tester.pump();

      // Digits go through.
      await tester.enterText(field, '123');
      expect(find.widgetWithText(TextField, '123'), findsOneWidget);

      // Letters are stripped by FilteringTextInputFormatter.
      await tester.enterText(field, 'abc');
      final tf = tester.widget<TextField>(field);
      expect(tf.controller!.text, isEmpty);

      // Symbols are stripped.
      await tester.enterText(field, '!@#');
      expect(tf.controller!.text, isEmpty);
    });

    testWidgets('3. Log button disabled when empty, enabled with valid number',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      // Initially disabled (empty input).
      final button = find.widgetWithText(FilledButton, 'Log Transaction');
      expect(tester.widget<FilledButton>(button).onPressed, isNull);

      // Enter a valid positive number → button becomes enabled.
      await tester.enterText(find.byType(TextField), '100');
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);

      // Clear input → disabled again.
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
    });
  });
}
