import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../calc/co_pay_calculator.dart';
import '../storage/ledger_repository.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

DateTime _nowBangkok() {
  final bangkok = tz.getLocation('Asia/Bangkok');
  final now = tz.TZDateTime.now(bangkok);
  return DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _billController = TextEditingController();

  LedgerRepository? _ledger;
  double _remainingDaily = kDailyCapTHB;
  double _remainingMonthly = kMonthlyCapTHB;
  double _govShare = 0;
  double _userShare = 0;
  bool _schemeActive = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLedger();
    _billController.addListener(_onBillChanged);
  }

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  Future<void> _initLedger() async {
    final prefs = await SharedPreferences.getInstance();
    final ledger = LedgerRepository(prefs);
    final now = _nowBangkok();
    final daily = await ledger.remainingDaily(now);
    final monthly = await ledger.remainingMonthly(now);
    final split = calculateSplit(
      billTHB: 0,
      remainingDailyTHB: daily,
      remainingMonthlyTHB: monthly,
      nowBangkok: now,
    );
    if (mounted) {
      setState(() {
        _ledger = ledger;
        _remainingDaily = daily;
        _remainingMonthly = monthly;
        _schemeActive = split.schemeActive;
        _loading = false;
      });
    }
  }

  void _onBillChanged() {
    final bill = double.tryParse(_billController.text) ?? 0;
    final split = calculateSplit(
      billTHB: bill,
      remainingDailyTHB: _remainingDaily,
      remainingMonthlyTHB: _remainingMonthly,
      nowBangkok: _nowBangkok(),
    );
    setState(() {
      _govShare = split.govShare;
      _userShare = split.userShare;
      _schemeActive = split.schemeActive;
    });
  }

  Future<void> _logTransaction() async {
    final ledger = _ledger;
    if (ledger == null) return;
    final bill = double.tryParse(_billController.text) ?? 0;
    if (bill <= 0) return;

    final now = _nowBangkok();
    final split = calculateSplit(
      billTHB: bill,
      remainingDailyTHB: _remainingDaily,
      remainingMonthlyTHB: _remainingMonthly,
      nowBangkok: now,
    );
    await ledger.append(LoggedTransaction.fromSplit(
      billTHB: bill,
      split: split,
      timestampBangkok: now,
    ));

    final newDaily = await ledger.remainingDaily(now);
    final newMonthly = await ledger.remainingMonthly(now);
    final newSplit = calculateSplit(
      billTHB: 0,
      remainingDailyTHB: newDaily,
      remainingMonthlyTHB: newMonthly,
      nowBangkok: now,
    );

    if (!mounted) return;
    _billController.clear();
    setState(() {
      _remainingDaily = newDaily;
      _remainingMonthly = newMonthly;
      _govShare = 0;
      _userShare = 0;
      _schemeActive = newSplit.schemeActive;
    });
  }

  String _fmt(double v) =>
      v == v.truncate() ? v.toInt().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bill = double.tryParse(_billController.text) ?? 0;
    final canLog = !_loading && bill > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('TCT Plus Calc', style: theme.textTheme.titleLarge),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(CdsSpacing.lg),
              children: [
                if (!_schemeActive) _SchemeBanner(theme: theme),
                _AllowanceCard(
                  label: 'Remaining daily',
                  value: _remainingDaily,
                  cap: kDailyCapTHB,
                  theme: theme,
                ),
                _AllowanceCard(
                  label: 'Remaining monthly',
                  value: _remainingMonthly,
                  cap: kMonthlyCapTHB,
                  theme: theme,
                ),
                const SizedBox(height: CdsSpacing.lg),
                _BillInput(controller: _billController, theme: theme),
                const SizedBox(height: CdsSpacing.lg),
                _SplitReadout(
                  userShare: _userShare,
                  govShare: _govShare,
                  fmt: _fmt,
                  theme: theme,
                ),
                const SizedBox(height: CdsSpacing.xl),
                FilledButton(
                  onPressed: canLog ? _logTransaction : null,
                  child: const Text('Log Transaction'),
                ),
              ],
            ),
    );
  }
}

class _SchemeBanner extends StatelessWidget {
  const _SchemeBanner({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: CdsSpacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: CdsSpacing.lg,
        vertical: CdsSpacing.md,
      ),
      decoration: BoxDecoration(
        color: CdsColors.warning.withAlpha(30),
        border: Border.all(color: CdsColors.warning),
        borderRadius: BorderRadius.circular(CdsRadius.button),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: CdsColors.warning, size: 20),
          const SizedBox(width: CdsSpacing.sm),
          Expanded(
            child: Text(
              'Scheme inactive — government share = 0',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllowanceCard extends StatelessWidget {
  const _AllowanceCard({
    required this.label,
    required this.value,
    required this.cap,
    required this.theme,
  });

  final String label;
  final double value;
  final double cap;
  final ThemeData theme;

  String _fmt(double v) =>
      v == v.truncate() ? v.toInt().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CdsSpacing.lg,
          vertical: CdsSpacing.md,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(
              '${_fmt(value)} / ${_fmt(cap)} THB',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _BillInput extends StatelessWidget {
  const _BillInput({required this.controller, required this.theme});
  final TextEditingController controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Bill amount',
        suffixText: 'THB',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CdsRadius.input),
        ),
        labelStyle: theme.textTheme.bodyMedium,
      ),
      style: theme.textTheme.bodyLarge,
    );
  }
}

class _SplitReadout extends StatelessWidget {
  const _SplitReadout({
    required this.userShare,
    required this.govShare,
    required this.fmt,
    required this.theme,
  });

  final double userShare;
  final double govShare;
  final String Function(double) fmt;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CdsSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Split', style: theme.textTheme.titleMedium),
            const SizedBox(height: CdsSpacing.sm),
            _Row(
              label: 'User Share',
              value: '${fmt(userShare)} THB',
              theme: theme,
            ),
            const SizedBox(height: CdsSpacing.xs),
            _Row(
              label: 'Government Share',
              value: '${fmt(govShare)} THB',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.theme});
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}
