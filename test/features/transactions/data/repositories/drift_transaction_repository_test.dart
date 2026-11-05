import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/app/lookups/category_lookup_adapter.dart';
import 'package:rumbo/app/lookups/income_source_lookup_adapter.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/categories/data/repositories/drift_category_repository.dart';
import 'package:rumbo/features/income_sources/data/repositories/drift_income_source_repository.dart';
import 'package:rumbo/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/usecases/get_month_summary.dart';

void main() {
  late AppDatabase database;
  late DriftTransactionRepository repository;
  late int sourceId;
  late String sourceName;
  late int categoryId;
  late String categoryName;

  setUp(() async {
    database = AppDatabase.memory();
    final incomeSources = DriftIncomeSourceRepository(database.incomeSourceDao);
    final categories = DriftCategoryRepository(database.categoryDao);
    repository = DriftTransactionRepository(
      database.transactionDao,
      IncomeSourceLookupAdapter(incomeSources),
      CategoryLookupAdapter(categories),
    );

    final sources = await database.select(database.incomeSources).get();
    final storedCategories = await database.select(database.categories).get();
    sourceId = sources.first.id;
    sourceName = sources.first.name;
    categoryId = storedCategories.first.id;
    categoryName = storedCategories.first.name;
  });

  tearDown(() => database.close());

  final today = CalendarDate(year: 2026, month: 11, day: 5);

  test('should store an income and read it as a view', () async {
    final result = await repository.create(
      type: TransactionType.income,
      amount: const Money.fromCents(150000),
      date: today,
      note: 'Venta',
      incomeSourceId: sourceId,
    );

    final created = result.valueOrNull;
    expect(created?.incomeSourceId, sourceId);

    final view = (await repository.getById(created!.id)).valueOrNull;
    expect(view?.transaction.amount, const Money.fromCents(150000));
    expect(view?.transaction.note, 'Venta');
    expect(view?.source?.name, sourceName);
    expect(view?.source?.colorValue, isNotNull);
    expect(view?.source?.isArchived, isFalse);
    expect(view?.category, isNull);
  });

  test('should store an expense and read its category', () async {
    final created = (await repository.create(
      type: TransactionType.expense,
      amount: const Money.fromCents(50000),
      date: today,
      categoryId: categoryId,
    )).valueOrNull!;

    final view = (await repository.getById(created.id)).valueOrNull;

    expect(view?.transaction.type, TransactionType.expense);
    expect(view?.category?.name, categoryName);
    expect(view?.source, isNull);
  });

  test('should update the transaction when it exists', () async {
    final created = (await repository.create(
      type: TransactionType.income,
      amount: const Money.fromCents(100000),
      date: today,
      incomeSourceId: sourceId,
    )).valueOrNull!;

    final updated = await repository.update(
      id: created.id,
      type: TransactionType.expense,
      amount: const Money.fromCents(250000),
      date: CalendarDate(year: 2026, month: 11, day: 10),
      note: 'Corregida',
      categoryId: categoryId,
    );

    expect(updated.valueOrNull?.type, TransactionType.expense);
    expect(updated.valueOrNull?.amount, const Money.fromCents(250000));
    expect(
      updated.valueOrNull?.date,
      CalendarDate(year: 2026, month: 11, day: 10),
    );
    expect(updated.valueOrNull?.incomeSourceId, isNull);
  });

  test('should delete the transaction and hide it afterwards', () async {
    final created = (await repository.create(
      type: TransactionType.income,
      amount: const Money.fromCents(100000),
      date: today,
      incomeSourceId: sourceId,
    )).valueOrNull!;

    final deleted = await repository.delete(created.id);

    expect(deleted.valueOrNull?.id, created.id);
    expect(
      (await repository.getById(created.id)).failureOrNull,
      isA<NotFoundFailure>(),
    );
  });

  test('should return a not found failure for a missing transaction', () async {
    expect(
      (await repository.getById(99)).failureOrNull,
      isA<NotFoundFailure>(),
    );
    expect((await repository.delete(99)).failureOrNull, isA<NotFoundFailure>());
  });

  test('should filter the stream by type, date and reference', () async {
    await repository.create(
      type: TransactionType.income,
      amount: const Money.fromCents(100000),
      date: today,
      incomeSourceId: sourceId,
    );
    await repository.create(
      type: TransactionType.expense,
      amount: const Money.fromCents(50000),
      date: CalendarDate(year: 2026, month: 10, day: 31),
      categoryId: categoryId,
    );

    final november = await repository
        .watchFiltered(
          TransactionFilter(
            from: CalendarDate(year: 2026, month: 11, day: 1),
            to: CalendarDate(year: 2026, month: 11, day: 30),
          ),
        )
        .first;
    final expenses = await repository
        .watchFiltered(const TransactionFilter(type: TransactionType.expense))
        .first;
    final bySource = await repository
        .watchFiltered(TransactionFilter(incomeSourceId: sourceId))
        .first;

    expect(november, hasLength(1));
    expect(november.single.transaction.type, TransactionType.income);
    expect(expenses, hasLength(1));
    expect(expenses.single.transaction.type, TransactionType.expense);
    expect(bySource, hasLength(1));
    expect(bySource.single.source?.id, sourceId);
  });

  test('should keep the name of an archived source in the view', () async {
    final created = (await repository.create(
      type: TransactionType.income,
      amount: const Money.fromCents(100000),
      date: today,
      incomeSourceId: sourceId,
    )).valueOrNull!;

    await database.incomeSourceDao.setArchivedAt(
      sourceId,
      DateTime.utc(2026, 11, 6),
    );

    final view = (await repository.getById(created.id)).valueOrNull;

    expect(view?.source?.isArchived, isTrue);
    expect(view?.source?.name, sourceName);
  });

  test('should keep a large amount without losing precision', () async {
    const largeAmount = Money.fromCents(99999999999);
    final created = (await repository.create(
      type: TransactionType.income,
      amount: largeAmount,
      date: today,
      incomeSourceId: sourceId,
    )).valueOrNull!;

    final view = (await repository.getById(created.id)).valueOrNull;

    expect(view?.transaction.amount, largeAmount);
    expect(view?.transaction.amount.cents, 99999999999);
  });

  test('should separate October 31 from November 1 in the summary', () async {
    await repository.create(
      type: TransactionType.income,
      amount: const Money.fromCents(700000),
      date: CalendarDate(year: 2026, month: 10, day: 31),
      incomeSourceId: sourceId,
    );
    await repository.create(
      type: TransactionType.income,
      amount: const Money.fromCents(100000),
      date: CalendarDate(year: 2026, month: 11, day: 1),
      incomeSourceId: sourceId,
    );

    final summary = GetMonthSummary(repository);
    final october = await summary(year: 2026, month: 10);
    final november = await summary(year: 2026, month: 11);

    expect(october.transactionCount, 1);
    expect(october.totalIncome, const Money.fromCents(700000));
    expect(november.transactionCount, 1);
    expect(november.totalIncome, const Money.fromCents(100000));
  });

  test('should separate December 31 from January 1 in the summary', () async {
    await repository.create(
      type: TransactionType.expense,
      amount: const Money.fromCents(40000),
      date: CalendarDate(year: 2026, month: 12, day: 31),
      categoryId: categoryId,
    );
    await repository.create(
      type: TransactionType.expense,
      amount: const Money.fromCents(90000),
      date: CalendarDate(year: 2027, month: 1, day: 1),
      categoryId: categoryId,
    );

    final summary = GetMonthSummary(repository);
    final december = await summary(year: 2026, month: 12);
    final january = await summary(year: 2027, month: 1);

    expect(december.transactionCount, 1);
    expect(december.totalExpense, const Money.fromCents(40000));
    expect(january.transactionCount, 1);
    expect(january.totalExpense, const Money.fromCents(90000));
  });
}
