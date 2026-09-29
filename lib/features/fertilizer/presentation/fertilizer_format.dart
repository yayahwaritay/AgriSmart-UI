/// Display formatting for the fertilizer screens — no `intl` needed.
library;

/// `3.5` → `"3½"`, `0.5` → `"½"`, `4` → `"4"`. The API rounds bags up to
/// the nearest half, so anything else falls back to one decimal.
String formatBags(double bags) {
  final whole = bags.floor();
  final fraction = bags - whole;
  if (fraction.abs() < 0.001) return '$whole';
  if ((fraction - 0.5).abs() < 0.001) return whole == 0 ? '½' : '$whole½';
  return bags.toStringAsFixed(1);
}

/// "bag" / "bags" for a count shown with [formatBags] (½ bag, 1 bag).
String bagNoun(double bags) => bags <= 1 ? 'bag' : 'bags';

/// `171.4` → `"171.4"`, `56.0` → `"56"`.
String formatNumber(double value, {int decimals = 1}) {
  final fixed = value.toStringAsFixed(decimals);
  if (!fixed.contains('.')) return fixed;
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// `4675.0` → `"4,675"`; kept whole unless there are cents.
String formatMoney(double value) {
  final decimals = value == value.roundToDouble() ? 0 : 2;
  final parts = value.abs().toStringAsFixed(decimals).split('.');
  final digits = parts.first;
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
    grouped.write(digits[i]);
  }
  final sign = value < 0 ? '-' : '';
  return parts.length > 1 ? '$sign$grouped.${parts[1]}' : '$sign$grouped';
}

/// Signed kg for a nutrient balance: `+3.2 kg`, `-50 kg`, `0 kg`.
String formatBalance(double value) {
  final text = '${formatNumber(value.abs())} kg';
  if (value > 0.05) return '+$text';
  if (value < -0.05) return '−$text';
  return '0 kg';
}

/// Parses a typed number, accepting a comma decimal separator. `null` for
/// empty or unparsable text.
double? parseNumber(String text) {
  final cleaned = text.trim().replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}
