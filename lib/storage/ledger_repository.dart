// Local transaction ledger backed by shared_preferences.
// Convention inherited from centraldigital/cds-flutter (shared_preferences ^2.5.5).

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../calc/co_pay_calculator.dart';

const String _kLedgerKey = 'tct_ledger_v1';

/// A single recorded transaction.
class LoggedTransaction {
  LoggedTransaction({
    required this.id,
    required this.timestampBangkok,
    required this.govShareTHB,
    required this.userShareTHB,
    required this.billTHB,
  });

  final String id;
  final DateTime timestampBangkok;
  final double govShareTHB;
  final double userShareTHB;
  final double billTHB;

  Map<String, dynamic> toJson() => {
        'id': id,
        // Store as ISO-8601 string; no timezone offset — always Bangkok local.
        'ts': timestampBangkok.toIso8601String(),
        'gov': govShareTHB,
        'user': userShareTHB,
        'bill': billTHB,
      };

  factory LoggedTransaction.fromJson(Map<String, dynamic> j) =>
      LoggedTransaction(
        id: j['id'] as String,
        timestampBangkok: DateTime.parse(j['ts'] as String),
        govShareTHB: (j['gov'] as num).toDouble(),
        userShareTHB: (j['user'] as num).toDouble(),
        billTHB: (j['bill'] as num).toDouble(),
      );

  /// Create a new transaction from a completed co-pay split.
  static LoggedTransaction fromSplit({
    required double billTHB,
    required CoPaySplit split,
    required DateTime timestampBangkok,
  }) =>
      LoggedTransaction(
        id: const Uuid().v4(),
        timestampBangkok: timestampBangkok,
        govShareTHB: split.govShare,
        userShareTHB: split.userShare,
        billTHB: billTHB,
      );
}

/// Persists the transaction log and answers allowance queries.
///
/// All [DateTime] parameters must be pre-converted to Asia/Bangkok local time.
/// Day boundaries are determined by calendar day in that local time.
class LedgerRepository {
  LedgerRepository(this._prefs);

  final SharedPreferences _prefs;

  /// Append [txn] to the persistent ledger.
  Future<void> append(LoggedTransaction txn) async {
    final existing = _load();
    existing.add(txn);
    await _save(existing);
  }

  /// Return all recorded transactions, oldest first.
  Future<List<LoggedTransaction>> all() async => _load();

  /// Sum of government shares recorded on the Bangkok calendar day of [nowBangkok].
  Future<double> govSpentToday(DateTime nowBangkok) async {
    final txns = _load();
    return txns
        .where((t) => _sameDay(t.timestampBangkok, nowBangkok))
        .fold<double>(0.0, (sum, t) => sum + t.govShareTHB);
  }

  /// Sum of government shares recorded in the Bangkok calendar month of [nowBangkok].
  Future<double> govSpentThisMonth(DateTime nowBangkok) async {
    final txns = _load();
    return txns
        .where((t) => _sameMonth(t.timestampBangkok, nowBangkok))
        .fold<double>(0.0, (sum, t) => sum + t.govShareTHB);
  }

  /// Remaining daily gov-share budget (floors at 0).
  Future<double> remainingDaily(DateTime nowBangkok) async {
    final spent = await govSpentToday(nowBangkok);
    final remaining = kDailyCapTHB - spent;
    return remaining < 0 ? 0.0 : remaining;
  }

  /// Remaining monthly gov-share budget (floors at 0).
  Future<double> remainingMonthly(DateTime nowBangkok) async {
    final spent = await govSpentThisMonth(nowBangkok);
    final remaining = kMonthlyCapTHB - spent;
    return remaining < 0 ? 0.0 : remaining;
  }

  // ── private helpers ──────────────────────────────────────────────────────

  List<LoggedTransaction> _load() {
    final raw = _prefs.getString(_kLedgerKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => LoggedTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(List<LoggedTransaction> txns) async {
    await _prefs.setString(_kLedgerKey, jsonEncode(txns.map((t) => t.toJson()).toList()));
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
