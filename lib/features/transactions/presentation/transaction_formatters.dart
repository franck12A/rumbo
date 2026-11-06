import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/presentation/providers/selected_month_provider.dart';

/// User-facing formatting of transaction values.
abstract final class TransactionFormatters {
  /// e.g. `Noviembre 2026`.
  static String monthLabel(SelectedMonth month) =>
      '${AppStrings.monthNames[month.month - 1]} ${month.year}';

  /// e.g. `Jueves 5 de noviembre`.
  static String dayHeader(CalendarDate date) {
    final weekday = AppStrings.weekdayNames[date.toDateTime().weekday];
    final month = AppStrings.monthNames[date.month - 1].toLowerCase();
    return '$weekday ${date.day} de $month';
  }

  /// Amount with its movement sign, e.g. `+ $ 10.000,00`.
  static String signedAmount(Transaction transaction) => transaction.isIncome
      ? '+ ${transaction.amount.format()}'
      : '− ${transaction.amount.format()}';

  /// Text the amount field starts with when editing.
  static String amountInput(Money amount) =>
      amount.format().replaceFirst(r'$ ', '');
}
