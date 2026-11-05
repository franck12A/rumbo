import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/month_summary.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';

/// Totals of a month, with the breakdown per source and per category.
///
/// Aggregation happens in memory: the filtered views already carry the names
/// and colors, so no extra query against other features is needed.
final class GetMonthSummary {
  const GetMonthSummary(this._repository);

  final TransactionRepository _repository;

  Future<MonthSummary> call({required int year, required int month}) async {
    final from = CalendarDate.firstOfMonth(year: year, month: month);
    final to = CalendarDate.lastOfMonth(year: year, month: month);
    final views = await _repository
        .watchFiltered(TransactionFilter(from: from, to: to))
        .first;

    var totalIncomeCents = 0;
    var totalExpenseCents = 0;
    final incomeGroups = <int, _Group>{};
    final expenseGroups = <int, _Group>{};

    for (final view in views) {
      final transaction = view.transaction;
      final isIncome = transaction.type == TransactionType.income;
      final reference = isIncome ? view.source : view.category;
      // Foreign keys keep the reference alive; the fallback only protects the
      // summary from corrupted data.
      (isIncome ? incomeGroups : expenseGroups)
              .putIfAbsent(
                reference?.id ?? 0,
                () => _Group(
                  name: reference?.name ?? '',
                  colorValue: reference?.colorValue ?? 0,
                ),
              )
              .totalCents +=
          transaction.amount.cents;

      if (isIncome) {
        totalIncomeCents += transaction.amount.cents;
      } else {
        totalExpenseCents += transaction.amount.cents;
      }
    }

    return MonthSummary(
      totalIncome: Money.fromCents(totalIncomeCents),
      totalExpense: Money.fromCents(totalExpenseCents),
      balance: Money.fromCents(totalIncomeCents - totalExpenseCents),
      incomeBreakdown: _sorted(incomeGroups),
      expenseBreakdown: _sorted(expenseGroups),
      transactionCount: views.length,
    );
  }

  List<AmountBreakdown> _sorted(Map<int, _Group> groups) {
    final sorted = groups.values.toList()
      ..sort((first, second) {
        final byTotal = second.totalCents.compareTo(first.totalCents);
        if (byTotal != 0) {
          return byTotal;
        }
        return first.name.toLowerCase().compareTo(second.name.toLowerCase());
      });

    return [
      for (final group in sorted)
        AmountBreakdown(
          name: group.name,
          colorValue: group.colorValue,
          total: Money.fromCents(group.totalCents),
        ),
    ];
  }
}

class _Group {
  _Group({required this.name, required this.colorValue});

  final String name;
  final int colorValue;
  int totalCents = 0;
}
