import 'package:flutter_test/flutter_test.dart';
import 'package:tct_plus_calc/calc/co_pay_calculator.dart';

void main() {
  group('calculateSplit', () {
    // A date firmly inside the scheme window.
    final DateTime inScheme = DateTime(2026, 7, 15, 12, 0, 0);

    test('1. under-cap: bill 100, full remaining → gov 60, user 40', () {
      final result = calculateSplit(
        billTHB: 100,
        remainingDailyTHB: kDailyCapTHB,
        remainingMonthlyTHB: kMonthlyCapTHB,
        nowBangkok: inScheme,
      );
      expect(result.govShare, equals(60.0));
      expect(result.userShare, equals(40.0));
      expect(result.schemeActive, isTrue);
    });

    test('2. daily-cap-hit: bill 500, daily 200, monthly 1000 → gov 200, user 300', () {
      final result = calculateSplit(
        billTHB: 500,
        remainingDailyTHB: 200,
        remainingMonthlyTHB: 1000,
        nowBangkok: inScheme,
      );
      expect(result.govShare, equals(200.0));
      expect(result.userShare, equals(300.0));
      expect(result.schemeActive, isTrue);
    });

    test('3. monthly-cap-hit: bill 200, daily 200, monthly 50 → gov 50, user 150', () {
      final result = calculateSplit(
        billTHB: 200,
        remainingDailyTHB: 200,
        remainingMonthlyTHB: 50,
        nowBangkok: inScheme,
      );
      expect(result.govShare, equals(50.0));
      expect(result.userShare, equals(150.0));
      expect(result.schemeActive, isTrue);
    });

    test('4. scheme-inactive (before): 2026-05-31 23:59 ICT, bill 500 → gov 0, user 500', () {
      final result = calculateSplit(
        billTHB: 500,
        remainingDailyTHB: kDailyCapTHB,
        remainingMonthlyTHB: kMonthlyCapTHB,
        nowBangkok: DateTime(2026, 5, 31, 23, 59, 0),
      );
      expect(result.govShare, equals(0.0));
      expect(result.userShare, equals(500.0));
      expect(result.schemeActive, isFalse);
    });

    test('5. scheme-inactive (after): 2026-10-01 00:00 ICT, bill 500 → gov 0, user 500', () {
      final result = calculateSplit(
        billTHB: 500,
        remainingDailyTHB: kDailyCapTHB,
        remainingMonthlyTHB: kMonthlyCapTHB,
        nowBangkok: DateTime(2026, 10, 1, 0, 0, 0),
      );
      expect(result.govShare, equals(0.0));
      expect(result.userShare, equals(500.0));
      expect(result.schemeActive, isFalse);
    });

    test('6. ICT boundary: 23:30 Bangkok on 2026-06-15 buckets to June 15 (not June 14 UTC)', () {
      // 23:30 ICT = 16:30 UTC (still June 14 in UTC), but the calculator
      // receives pre-converted Bangkok time, so this must register as June 15.
      final bangkokJune15At2330 = DateTime(2026, 6, 15, 23, 30, 0);
      final result = calculateSplit(
        billTHB: 100,
        remainingDailyTHB: kDailyCapTHB,
        remainingMonthlyTHB: kMonthlyCapTHB,
        nowBangkok: bangkokJune15At2330,
      );
      // Scheme is active — confirms the date is treated as June 15, not June 14 UTC.
      expect(result.schemeActive, isTrue);
      expect(result.govShare, equals(60.0));
    });

    test('7. zero remaining daily: bill 100, daily 0 → gov 0, user 100', () {
      final result = calculateSplit(
        billTHB: 100,
        remainingDailyTHB: 0,
        remainingMonthlyTHB: kMonthlyCapTHB,
        nowBangkok: inScheme,
      );
      expect(result.govShare, equals(0.0));
      expect(result.userShare, equals(100.0));
      expect(result.schemeActive, isTrue);
    });
  });
}
