import 'package:drift/drift.dart';

/// Drift table behind the transactions feature.
///
/// Foreign keys are declared as raw constraints so `data/` does not import the
/// tables of other features; the database still enforces them.
@TableIndex(name: 'transactions_date', columns: {#date})
@TableIndex(name: 'transactions_income_source_id', columns: {#incomeSourceId})
@TableIndex(name: 'transactions_category_id', columns: {#categoryId})
@UseRowClass(TransactionRow)
class Transactions extends Table {
  static const _positiveAmountCheck = 'CHECK (amount_cents > 0)';

  static const _typeInvariantCheck =
      "CHECK ((type = 'income' AND income_source_id IS NOT NULL "
      "AND category_id IS NULL) OR (type = 'expense' AND category_id IS NOT "
      'NULL AND income_source_id IS NULL))';

  IntColumn get id => integer().autoIncrement()();

  /// Stored as `income` or `expense`; see the mapper.
  TextColumn get type => text()();

  IntColumn get amountCents => integer()();

  /// Calendar day as `yyyymmdd`, so month queries are integer ranges.
  IntColumn get date => integer()();

  TextColumn get note => text().withLength(max: 200).nullable()();

  IntColumn get incomeSourceId => integer().nullable().customConstraint(
    'REFERENCES income_sources(id) ON DELETE RESTRICT',
  )();

  IntColumn get categoryId => integer().nullable().customConstraint(
    'REFERENCES categories(id) ON DELETE RESTRICT',
  )();

  DateTimeColumn get createdAt => dateTime()();

  @override
  List<String> get customConstraints => const [
    _positiveAmountCheck,
    _typeInvariantCheck,
  ];
}

/// One stored transaction, exactly as drift reads it.
class TransactionRow {
  const TransactionRow({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.date,
    required this.note,
    required this.incomeSourceId,
    required this.categoryId,
    required this.createdAt,
  });

  final int id;
  final String type;
  final int amountCents;
  final int date;
  final String? note;
  final int? incomeSourceId;
  final int? categoryId;
  final DateTime createdAt;
}
