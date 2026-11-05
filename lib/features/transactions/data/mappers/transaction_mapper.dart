import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/data/tables/transactions_table.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';

/// Translates between drift rows and domain entities.
abstract final class TransactionMapper {
  static const incomeType = 'income';
  static const expenseType = 'expense';

  static String typeToStorage(TransactionType type) => switch (type) {
    TransactionType.income => incomeType,
    TransactionType.expense => expenseType,
  };

  static TransactionType typeFromStorage(String value) => switch (value) {
    incomeType => TransactionType.income,
    expenseType => TransactionType.expense,
    _ => throw StateError('Unknown transaction type in database: $value'),
  };

  static Transaction toDomain(TransactionRow row) => Transaction(
    id: row.id,
    type: typeFromStorage(row.type),
    amount: Money.fromCents(row.amountCents),
    date: CalendarDate.fromInt(row.date),
    note: row.note,
    incomeSourceId: row.incomeSourceId,
    categoryId: row.categoryId,
    // createdAt is an instant: always handed out in UTC.
    createdAt: row.createdAt.toUtc(),
  );
}
