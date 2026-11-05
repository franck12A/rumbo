import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';

/// Persistence boundary for transactions, implemented in `data/`.
abstract interface class TransactionRepository {
  /// Emits the transactions matching [filter], newest first.
  Stream<List<TransactionView>> watchFiltered(TransactionFilter filter);

  Future<Result<TransactionView>> getById(int id);

  Future<Result<Transaction>> create({
    required TransactionType type,
    required Money amount,
    required CalendarDate date,
    String? note,
    int? incomeSourceId,
    int? categoryId,
  });

  Future<Result<Transaction>> update({
    required int id,
    required TransactionType type,
    required Money amount,
    required CalendarDate date,
    String? note,
    int? incomeSourceId,
    int? categoryId,
  });

  /// Deletes the transaction and returns the row that was removed.
  Future<Result<Transaction>> delete(int id);
}
