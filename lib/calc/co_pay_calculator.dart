// Thai Chuay Thai Plus (60/40) co-payment calculation engine.
// Scheme details: https://github.com/arnon-aroon/tct-plus-calc

/// Named constants for the government co-pay scheme.
///
/// Source: Thai Chuay Thai Plus 60/40 programme rules.
const double kGovSharePercent = 0.60;
const double kDailyCapTHB = 200.0;
const double kMonthlyCapTHB = 1000.0;

/// Scheme window (Asia/Bangkok, UTC+7).
/// 2026-06-01 00:00 ICT — 2026-09-30 23:59:59 ICT.
final DateTime kSchemeStart = DateTime(2026, 6, 1, 0, 0, 0);
final DateTime kSchemeEnd = DateTime(2026, 9, 30, 23, 59, 59);

/// Result of a co-pay split calculation.
class CoPaySplit {
  const CoPaySplit({
    required this.govShare,
    required this.userShare,
    required this.schemeActive,
  });

  final double govShare;
  final double userShare;
  final bool schemeActive;
}

/// Calculates the 60/40 government co-pay split for a single bill.
///
/// [nowBangkok] must already be expressed in Asia/Bangkok local time;
/// the caller is responsible for converting from UTC.
CoPaySplit calculateSplit({
  required double billTHB,
  required double remainingDailyTHB,
  required double remainingMonthlyTHB,
  required DateTime nowBangkok,
}) {
  final bool active =
      !nowBangkok.isBefore(kSchemeStart) && !nowBangkok.isAfter(kSchemeEnd);

  if (!active) {
    return CoPaySplit(govShare: 0, userShare: billTHB, schemeActive: false);
  }

  final double gov = [
    kGovSharePercent * billTHB,
    remainingDailyTHB,
    remainingMonthlyTHB,
  ].reduce((a, b) => a < b ? a : b);

  return CoPaySplit(
    govShare: gov,
    userShare: billTHB - gov,
    schemeActive: true,
  );
}
