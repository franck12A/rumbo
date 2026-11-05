import 'package:intl/intl.dart';

/// Value object for money amounts.
///
/// Amounts are always stored as [cents] so no floating point rounding can
/// happen. Formatting is available through [format] for the presentation layer.
final class Money implements Comparable<Money> {
  const Money.fromCents(this.cents);

  /// Zero pesos.
  static const zero = Money.fromCents(0);

  /// Parses an amount written in the Argentine format, like `10000`,
  /// `10.000,50` or `-1.234,56`.
  ///
  /// Throws a [FormatException] when [input] is not a valid amount.
  factory Money.fromDecimalString(String input) {
    final normalized = input.trim();
    if (!_esArAmountPattern.hasMatch(normalized)) {
      throw FormatException('Invalid es_AR amount', input);
    }

    final isNegative = normalized.startsWith('-');
    final unsigned = normalized.replaceFirst(_signPattern, '');
    final parts = unsigned.split(',');
    final wholeDigits = parts.first.replaceAll('.', '');
    final fractionDigits = parts.length > 1
        ? parts.last.padRight(2, '0')
        : '00';
    final amountInCents =
        int.parse(wholeDigits) * 100 + int.parse(fractionDigits);

    return Money.fromCents(isNegative ? -amountInCents : amountInCents);
  }

  static final _esArAmountPattern = RegExp(
    r'^[+-]?(?:\d{1,3}(?:\.\d{3})+|\d+)(?:,\d{1,2})?$',
  );
  static final _signPattern = RegExp(r'^[+-]');

  /// Signed amount in cents.
  final int cents;

  bool get isPositive => cents > 0;

  bool get isNegative => cents < 0;

  bool get isZero => cents == 0;

  Money abs() => Money.fromCents(cents.abs());

  Money operator +(Money other) => Money.fromCents(cents + other.cents);

  Money operator -(Money other) => Money.fromCents(cents - other.cents);

  Money operator -() => Money.fromCents(-cents);

  bool operator <(Money other) => cents < other.cents;

  bool operator <=(Money other) => cents <= other.cents;

  bool operator >(Money other) => cents > other.cents;

  bool operator >=(Money other) => cents >= other.cents;

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  /// Formats the amount as `$ 10.000,00`, using the `es_AR` locale.
  String format() {
    final absoluteCents = cents.abs();
    final whole = _wholeFormatter.format(absoluteCents ~/ 100);
    final fraction = (absoluteCents % 100).toString().padLeft(2, '0');
    final separator = _wholeFormatter.symbols.DECIMAL_SEP;
    final amount = '$whole$separator$fraction';

    return cents.isNegative ? '\$ -$amount' : '\$ $amount';
  }

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => format();

  static final _wholeFormatter = NumberFormat.decimalPatternDigits(
    locale: 'es_AR',
    decimalDigits: 0,
  );
}
