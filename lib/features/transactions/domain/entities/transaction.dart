import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';

part 'transaction.freezed.dart';

/// A movement of money: either an income tied to a source or an expense tied
/// to a category.
@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required int id,
    required TransactionType type,
    required Money amount,
    required CalendarDate date,
    required DateTime createdAt,
    String? note,
    int? incomeSourceId,
    int? categoryId,
  }) = _Transaction;

  const Transaction._();

  bool get isIncome => type == TransactionType.income;
}
