import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/features/transactions/data/daos/transaction_dao.dart';
import 'package:rumbo/features/transactions/data/tables/transactions_table.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';

final _createdAt = DateTime.utc(2026, 11, 5, 12);

Matcher _constraintViolation() => throwsA(
  predicate<Object>(
    (error) => error.toString().toLowerCase().contains('constraint'),
  ),
);

void main() {
  late AppDatabase database;
  late TransactionDao dao;
  late int sourceId;
  late int categoryId;

  setUp(() async {
    database = AppDatabase.memory();
    dao = database.transactionDao;
    final sources = await database.select(database.incomeSources).get();
    final categories = await database.select(database.categories).get();
    sourceId = sources.first.id;
    categoryId = categories.first.id;
  });

  tearDown(() => database.close());

  Future<TransactionRow> insertIncome({
    int amountCents = 150000,
    int date = 20261105,
    String? note,
  }) => dao.insertTransaction(
    type: 'income',
    amountCents: amountCents,
    date: date,
    note: note,
    incomeSourceId: sourceId,
    categoryId: null,
    createdAt: _createdAt,
  );

  Future<TransactionRow> insertExpense({
    int amountCents = 50000,
    int date = 20261105,
    String? note,
  }) => dao.insertTransaction(
    type: 'expense',
    amountCents: amountCents,
    date: date,
    note: note,
    incomeSourceId: null,
    categoryId: categoryId,
    createdAt: _createdAt,
  );

  test('should store and read an income transaction', () async {
    final inserted = await insertIncome(note: 'Venta');

    final found = await dao.getById(inserted.id);

    expect(found?.type, 'income');
    expect(found?.amountCents, 150000);
    expect(found?.date, 20261105);
    expect(found?.note, 'Venta');
    expect(found?.incomeSourceId, sourceId);
    expect(found?.categoryId, isNull);
  });

  test('should list transactions newest first', () async {
    await insertIncome(date: 20261101);
    await insertIncome();
    await insertExpense();

    final rows = await dao.watchFiltered(const TransactionFilter()).first;

    expect(rows.map((row) => row.date), [20261105, 20261105, 20261101]);
  });

  test('should filter by type and inclusive date range', () async {
    await insertIncome(date: 20261031);
    await insertIncome();
    await insertExpense();

    final november = await dao
        .watchFiltered(
          TransactionFilter(
            from: CalendarDate(year: 2026, month: 11, day: 1),
            to: CalendarDate(year: 2026, month: 11, day: 30),
          ),
        )
        .first;
    final expenses = await dao
        .watchFiltered(const TransactionFilter(type: TransactionType.expense))
        .first;

    expect(november, hasLength(2));
    expect(expenses, hasLength(1));
    expect(expenses.single.type, 'expense');
  });

  test('should filter by income source and by category', () async {
    await insertIncome();
    await insertExpense();

    final bySource = await dao
        .watchFiltered(TransactionFilter(incomeSourceId: sourceId))
        .first;
    final byCategory = await dao
        .watchFiltered(TransactionFilter(categoryId: categoryId))
        .first;

    expect(bySource, hasLength(1));
    expect(bySource.single.incomeSourceId, sourceId);
    expect(byCategory, hasLength(1));
    expect(byCategory.single.categoryId, categoryId);
  });

  test('should combine every filter', () async {
    await insertIncome();
    await insertIncome(date: 20261101);

    final rows = await dao
        .watchFiltered(
          TransactionFilter(
            from: CalendarDate(year: 2026, month: 11, day: 5),
            to: CalendarDate(year: 2026, month: 11, day: 5),
            type: TransactionType.income,
            incomeSourceId: sourceId,
          ),
        )
        .first;

    expect(rows, hasLength(1));
    expect(rows.single.date, 20261105);
  });

  test('should update the stored transaction', () async {
    final inserted = await insertIncome(note: 'Original');

    final updated = await dao.updateTransaction(
      id: inserted.id,
      type: 'expense',
      amountCents: 250000,
      date: 20261110,
      note: 'Corregida',
      incomeSourceId: null,
      categoryId: categoryId,
    );

    expect(updated?.type, 'expense');
    expect(updated?.amountCents, 250000);
    expect(updated?.date, 20261110);
    expect(updated?.note, 'Corregida');
    expect(updated?.categoryId, categoryId);
    expect(updated?.incomeSourceId, isNull);
  });

  test('should delete and return the transaction', () async {
    final inserted = await insertIncome();

    final deleted = await dao.deleteById(inserted.id);

    expect(deleted?.id, inserted.id);
    expect(await dao.getById(inserted.id), isNull);
    expect(await dao.deleteById(inserted.id), isNull);
  });

  test('should reject a non positive amount', () async {
    await expectLater(insertIncome(amountCents: 0), _constraintViolation());
    await expectLater(insertIncome(amountCents: -100), _constraintViolation());
  });

  test('should reject an expense that also has a source', () async {
    await expectLater(
      dao.insertTransaction(
        type: 'expense',
        amountCents: 1000,
        date: 20261105,
        note: null,
        incomeSourceId: sourceId,
        categoryId: categoryId,
        createdAt: _createdAt,
      ),
      _constraintViolation(),
    );
  });

  test('should reject an income without a source', () async {
    await expectLater(
      dao.insertTransaction(
        type: 'income',
        amountCents: 1000,
        date: 20261105,
        note: null,
        incomeSourceId: null,
        categoryId: null,
        createdAt: _createdAt,
      ),
      _constraintViolation(),
    );
  });

  test('should reject an unknown foreign key', () async {
    await expectLater(
      dao.insertTransaction(
        type: 'income',
        amountCents: 1000,
        date: 20261105,
        note: null,
        incomeSourceId: 999999,
        categoryId: null,
        createdAt: _createdAt,
      ),
      _constraintViolation(),
    );
  });
}
