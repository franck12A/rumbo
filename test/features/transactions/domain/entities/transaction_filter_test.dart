import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';

void main() {
  final from = CalendarDate(year: 2026, month: 11, day: 1);
  final to = CalendarDate(year: 2026, month: 11, day: 30);

  test('should be equal when every field matches', () {
    final first = TransactionFilter(
      from: from,
      to: to,
      type: TransactionType.expense,
      incomeSourceId: 1,
      categoryId: 2,
    );
    final second = TransactionFilter(
      from: CalendarDate(year: 2026, month: 11, day: 1),
      to: CalendarDate(year: 2026, month: 11, day: 30),
      type: TransactionType.expense,
      incomeSourceId: 1,
      categoryId: 2,
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  test('should be equal when both are empty', () {
    expect(const TransactionFilter(), const TransactionFilter());
  });

  test('should differ when any field differs', () {
    expect(TransactionFilter(from: from), isNot(TransactionFilter(from: to)));
    expect(TransactionFilter(to: to), isNot(TransactionFilter(to: from)));
    expect(
      const TransactionFilter(type: TransactionType.income),
      isNot(const TransactionFilter(type: TransactionType.expense)),
    );
    expect(
      const TransactionFilter(incomeSourceId: 1),
      isNot(const TransactionFilter(incomeSourceId: 2)),
    );
    expect(
      const TransactionFilter(categoryId: 1),
      isNot(const TransactionFilter(categoryId: 2)),
    );
  });

  test('should deduplicate equal filters in a set', () {
    final filters = {
      TransactionFilter(from: from, type: TransactionType.income),
      TransactionFilter(from: from, type: TransactionType.income),
    };

    expect(filters, hasLength(1));
  });
}
