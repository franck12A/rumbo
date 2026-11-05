import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rumbo/core/utils/money.dart';

part 'month_summary.freezed.dart';

/// Total of one source or category inside a month.
@freezed
abstract class AmountBreakdown with _$AmountBreakdown {
  const factory AmountBreakdown({
    required String name,
    required int colorValue,
    required Money total,
  }) = _AmountBreakdown;
}

/// Totals and breakdowns of a single month.
@freezed
abstract class MonthSummary with _$MonthSummary {
  const factory MonthSummary({
    required Money totalIncome,
    required Money totalExpense,
    required Money balance,
    required List<AmountBreakdown> incomeBreakdown,
    required List<AmountBreakdown> expenseBreakdown,
    required int transactionCount,
  }) = _MonthSummary;
}
