import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/data/daos/transaction_dao.dart';
import 'package:rumbo/features/transactions/data/mappers/transaction_mapper.dart';
import 'package:rumbo/features/transactions/data/tables/transactions_table.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/domain/lookups/category_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/income_source_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';

/// Drift-backed implementation of [TransactionRepository].
final class DriftTransactionRepository implements TransactionRepository {
  const DriftTransactionRepository(
    this._dao,
    this._incomeSources,
    this._categories,
  );

  final TransactionDao _dao;
  final IncomeSourceLookup _incomeSources;
  final CategoryLookup _categories;

  @override
  Stream<List<TransactionView>> watchFiltered(TransactionFilter filter) =>
      _dao.watchFiltered(filter).asyncMap(_toViews);

  @override
  Future<Result<TransactionView>> getById(int id) async {
    try {
      final row = await _dao.getById(id);
      if (row == null) {
        return const Err(NotFoundFailure(resource: 'Transaction'));
      }
      final views = await _toViews([row]);
      return Success(views.single);
    } on Exception catch (error) {
      return Err(DatabaseFailure(cause: error));
    }
  }

  @override
  Future<Result<Transaction>> create({
    required TransactionType type,
    required Money amount,
    required CalendarDate date,
    String? note,
    int? incomeSourceId,
    int? categoryId,
  }) => _run(
    () => _dao.insertTransaction(
      type: TransactionMapper.typeToStorage(type),
      amountCents: amount.cents,
      date: date.value,
      note: note,
      incomeSourceId: incomeSourceId,
      categoryId: categoryId,
      createdAt: DateTime.now().toUtc(),
    ),
  );

  @override
  Future<Result<Transaction>> update({
    required int id,
    required TransactionType type,
    required Money amount,
    required CalendarDate date,
    String? note,
    int? incomeSourceId,
    int? categoryId,
  }) => _run(
    () => _dao.updateTransaction(
      id: id,
      type: TransactionMapper.typeToStorage(type),
      amountCents: amount.cents,
      date: date.value,
      note: note,
      incomeSourceId: incomeSourceId,
      categoryId: categoryId,
    ),
  );

  @override
  Future<Result<Transaction>> delete(int id) => _run(() => _dao.deleteById(id));

  Future<Result<Transaction>> _run(
    Future<TransactionRow?> Function() action,
  ) async {
    try {
      final row = await action();
      if (row == null) {
        return const Err(NotFoundFailure(resource: 'Transaction'));
      }
      return Success(TransactionMapper.toDomain(row));
    } on Exception catch (error) {
      return Err(DatabaseFailure(cause: error));
    }
  }

  Future<List<TransactionView>> _toViews(List<TransactionRow> rows) async {
    final sourceCache = <int, ReferenceInfo?>{};
    final categoryCache = <int, ReferenceInfo?>{};
    final views = <TransactionView>[];

    for (final row in rows) {
      final sourceId = row.incomeSourceId;
      final categoryId = row.categoryId;
      views.add(
        TransactionView(
          transaction: TransactionMapper.toDomain(row),
          source: sourceId == null
              ? null
              : await _lookup(_incomeSources.findById, sourceCache, sourceId),
          category: categoryId == null
              ? null
              : await _lookup(_categories.findById, categoryCache, categoryId),
        ),
      );
    }

    return List.unmodifiable(views);
  }

  Future<ReferenceInfo?> _lookup(
    Future<ReferenceInfo?> Function(int id) find,
    Map<int, ReferenceInfo?> cache,
    int id,
  ) async {
    if (cache.containsKey(id)) {
      return cache[id];
    }
    final info = await find(id);
    cache[id] = info;
    return info;
  }
}
