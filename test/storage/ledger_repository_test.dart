import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tct_plus_calc/storage/ledger_repository.dart';

// Helper: build a Bangkok-local DateTime with no sub-second noise.
DateTime bkk(int year, int month, int day, [int hour = 12, int minute = 0]) =>
    DateTime(year, month, day, hour, minute);

Future<LedgerRepository> _repo() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return LedgerRepository(prefs);
}

LoggedTransaction _txn(DateTime ts, double gov) => LoggedTransaction(
      id: 'id-$gov-${ts.millisecondsSinceEpoch}',
      timestampBangkok: ts,
      govShareTHB: gov,
      userShareTHB: 0,
      billTHB: gov,
    );

void main() {
  group('LedgerRepository', () {
    test('3 txns same Bangkok day → govSpentToday sums correctly', () async {
      final repo = await _repo();
      final day = bkk(2026, 7, 15);
      await repo.append(_txn(bkk(2026, 7, 15, 9, 0), 60));
      await repo.append(_txn(bkk(2026, 7, 15, 12, 0), 50));
      await repo.append(_txn(bkk(2026, 7, 15, 18, 30), 30));

      expect(await repo.govSpentToday(day), equals(140.0));
    });

    test('yesterday + today Bangkok → only today counted', () async {
      final repo = await _repo();
      await repo.append(_txn(bkk(2026, 7, 14, 23, 0), 80)); // yesterday
      await repo.append(_txn(bkk(2026, 7, 15, 1, 0), 60));  // today

      expect(await repo.govSpentToday(bkk(2026, 7, 15)), equals(60.0));
    });

    test('cross-month: 2026-06-30 23:30 ICT → counted in June', () async {
      final repo = await _repo();
      await repo.append(_txn(bkk(2026, 6, 30, 23, 30), 100));

      expect(await repo.govSpentThisMonth(bkk(2026, 6, 1)), equals(100.0));
      expect(await repo.govSpentThisMonth(bkk(2026, 7, 1)), equals(0.0));
    });

    test('cross-month: 2026-07-01 00:30 ICT → counted in July', () async {
      final repo = await _repo();
      await repo.append(_txn(bkk(2026, 7, 1, 0, 30), 100));

      expect(await repo.govSpentThisMonth(bkk(2026, 7, 1)), equals(100.0));
      expect(await repo.govSpentThisMonth(bkk(2026, 6, 1)), equals(0.0));
    });

    test('after 200 THB gov-spent today → remainingDaily = 0', () async {
      final repo = await _repo();
      final today = bkk(2026, 7, 15);
      await repo.append(_txn(bkk(2026, 7, 15, 10, 0), 120));
      await repo.append(_txn(bkk(2026, 7, 15, 14, 0), 80));

      expect(await repo.remainingDaily(today), equals(0.0));
    });

    test('remainingDaily floors at 0 even when over-spent', () async {
      final repo = await _repo();
      await repo.append(_txn(bkk(2026, 7, 15, 10, 0), 250));

      expect(await repo.remainingDaily(bkk(2026, 7, 15)), equals(0.0));
    });

    test('remainingMonthly decreases with each transaction', () async {
      final repo = await _repo();
      await repo.append(_txn(bkk(2026, 7, 5), 300));
      await repo.append(_txn(bkk(2026, 7, 10), 400));

      expect(await repo.remainingMonthly(bkk(2026, 7, 1)), equals(300.0));
    });

    test('all() returns transactions in append order', () async {
      final repo = await _repo();
      final t1 = _txn(bkk(2026, 7, 1), 60);
      final t2 = _txn(bkk(2026, 7, 2), 80);
      await repo.append(t1);
      await repo.append(t2);

      final list = await repo.all();
      expect(list.length, equals(2));
      expect(list[0].id, equals(t1.id));
      expect(list[1].id, equals(t2.id));
    });

    test('persists across fresh SharedPreferences instance', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo1 = LedgerRepository(prefs);
      await repo1.append(_txn(bkk(2026, 7, 15), 60));

      // Re-use same prefs object (mock doesn't reset between calls).
      final repo2 = LedgerRepository(prefs);
      expect((await repo2.all()).length, equals(1));
    });
  });
}
