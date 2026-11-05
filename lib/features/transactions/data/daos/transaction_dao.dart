import 'package:drift/drift.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/features/transactions/data/mappers/transaction_mapper.dart';
import 'package:rumbo/features/transactions/data/tables/transactions_table.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';

part 'transaction_dao.g.dart';

/// SQL access for the transactions table. Only `data/` may use it.
@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.attachedDatabase);

  Stream<List<TransactionRow>> watchFiltered(TransactionFilter filter) =>
      _filteredQuery(filter).watch();

  Future<List<TransactionRow>> getFiltered(TransactionFilter filter) =>
      _filteredQuery(filter).get();

  Future<TransactionRow?> getById(int id) {
    final query = select(transactions)
      ..where((transaction) => transaction.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<TransactionRow> insertTransaction({
    required String type,
    required int amountCents,
    required int date,
    required String? note,
    required int? incomeSourceId,
    required int? categoryId,
    required DateTime createdAt,
  }) async {
    final id = await into(transactions).insert(
      TransactionsCompanion.insert(
        type: type,
        amountCents: amountCents,
        date: date,
        note: Value(note),
        incomeSourceId: Value(incomeSourceId),
        categoryId: Value(categoryId),
        createdAt: createdAt,
      ),
    );
    final row = await getById(id);
    // The id was just inserted, so the row must be there.
    return row!;
  }

  Future<TransactionRow?> updateTransaction({
    required int id,
    required String type,
    required int amountCents,
    required int date,
    required String? note,
    required int? incomeSourceId,
    required int? categoryId,
  }) async {
    final updated =
        await (update(
          transactions,
        )..where((transaction) => transaction.id.equals(id))).write(
          TransactionsCompanion(
            type: Value(type),
            amountCents: Value(amountCents),
            date: Value(date),
            note: Value(note),
            incomeSourceId: Value(incomeSourceId),
            categoryId: Value(categoryId),
          ),
        );
    if (updated == 0) {
      return null;
    }
    return await getById(id);
  }

  /// Deletes the row and returns it, or `null` when it did not exist.
  Future<TransactionRow?> deleteById(int id) async {
    final row = await getById(id);
    if (row == null) {
      return null;
    }
    await (delete(
      transactions,
    )..where((transaction) => transaction.id.equals(id))).go();
    return row;
  }

  SimpleSelectStatement<$TransactionsTable, TransactionRow> _filteredQuery(
    TransactionFilter filter,
  ) {
    final query = select(transactions);

    final from = filter.from;
    if (from != null) {
      query.where(
        (transaction) => transaction.date.isBiggerOrEqualValue(from.value),
      );
    }
    final to = filter.to;
    if (to != null) {
      query.where(
        (transaction) => transaction.date.isSmallerOrEqualValue(to.value),
      );
    }
    final type = filter.type;
    if (type != null) {
      final storedType = TransactionMapper.typeToStorage(type);
      query.where((transaction) => transaction.type.equals(storedType));
    }
    final incomeSourceId = filter.incomeSourceId;
    if (incomeSourceId != null) {
      query.where(
        (transaction) => transaction.incomeSourceId.equals(incomeSourceId),
      );
    }
    final categoryId = filter.categoryId;
    if (categoryId != null) {
      query.where((transaction) => transaction.categoryId.equals(categoryId));
    }

    query.orderBy([
      (transaction) => OrderingTerm.desc(transaction.date),
      (transaction) => OrderingTerm.desc(transaction.createdAt),
      (transaction) => OrderingTerm.desc(transaction.id),
    ]);
    return query;
  }
}
