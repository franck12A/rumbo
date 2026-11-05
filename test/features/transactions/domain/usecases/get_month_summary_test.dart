import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:rumbo/features/transactions/domain/usecases/get_month_summary.dart';

class _MockTransactionRepository extends Mock implements TransactionRepository;

int _nextId = 1;

TransactionView _incomeView({
  required int cents,
  required int sourceId,
  required String name,
  int colorValue = 0xFF2E7D32,
}) => TransactionView(
  transaction: Transaction(
    id: _nextId++,
    type: TransactionType.income,
    amount: Money.fromCents(cents),
    date: CalendarDate(year: 2026, month: 11, day: 5),
    incomeSourceId: sourceId,
    createdAt: DateTime.utc(2026, 11, 5, 12),
  ),
  source: ReferenceInfo(
    id: sourceId,
    name: name,
    colorValue: colorValue,
    isArchived: false,
  ),
);

TransactionView _expenseView({
  required int cents,
  required int categoryId,
  required String name,
  int colorValue = 0xFF6A1B9A,
}) => TransactionView(
  transaction: Transaction(
    id: _nextId++,
    type: TransactionType.expense,
    amount: Money.fromCents(cents),
    date: CalendarDate(year: 2026, month: 11, day: 5),
    categoryId: categoryId,
    createdAt: DateTime.utc(2026, 11, 5, 12),
  ),
  category: ReferenceInfo(
    id: categoryId,
    name: name,
    colorValue: colorValue,
    isArchived: false,
  ),
);

void main() {
  late _MockTransactionRepository repository;
  late GetMonthSummary getMonthSummary;

  setUpAll(() {
    registerFallbackValue(const TransactionFilter());
  });

  setUp(() {
    repository = _MockTransactionRepository();
    getMonthSummary = GetMonthSummary(repository);
  });

  void stubViews(List<TransactionView> views) {
    when(() => repository.watchFiltered(any()))
        .thenAnswer((_) => Stream.value(views));
  }

  test('should return zeros when the month has no movements', () async {
    stubViews(const []);

    final summary = await getMonthSummary(year: 2026, month: 11);

    expect(summary.totalIncome, Money.zero);
    expect(summary.totalExpense, Money.zero);
    expect(summary.balance, Money.zero);
    expect(summary.incomeBreakdown, isEmpty);
    expect(summary.expenseBreakdown, isEmpty);
    expect(summary.transactionCount, 0);
  });

  test('should total incomes without expenses', () async {
    stubViews([
      _incomeView(cents: 100000, sourceId: 1, name: 'Restaurante'),
      _incomeView(cents: 50000, sourceId: 1, name: 'Restaurante'),
    ]);

    final summary = await getMonthSummary(year: 2026, month: 11);

    expect(summary.totalIncome, const Money.fromCents(150000));
    expect(summary.totalExpense, Money.zero);
    expect(summary.balance, const Money.fromCents(150000));
    expect(summary.transactionCount, 2);
  });

  test('should total expenses with a negative balance', () async {
    stubViews([_expenseView(cents: 250000, categoryId: 1, name: 'Materiales')]);

    final summary = await getMonthSummary(year: 2026, month: 11);

    expect(summary.totalExpense, const Money.fromCents(250000));
    expect(summary.balance, const Money.fromCents(-250000));
    expect(
      summary.expenseBreakdown.single.total,
      const Money.fromCents(250000),
    );
  });

  test('should compute the balance when both types exist', () async {
    stubViews([
      _incomeView(cents: 100000, sourceId: 1, name: 'Restaurante'),
      _expenseView(cents: 250000, categoryId: 1, name: 'Materiales'),
    ]);

    final summary = await getMonthSummary(year: 2026, month: 11);

    expect(summary.totalIncome, const Money.fromCents(100000));
    expect(summary.totalExpense, const Money.fromCents(250000));
    expect(summary.balance, const Money.fromCents(-150000));
    expect(summary.balance.isNegative, isTrue);
    expect(summary.transactionCount, 2);
  });

  test('should keep a large amount without losing precision', () async {
    const largeAmount = Money.fromCents(99999999999);
    stubViews([
      _incomeView(cents: largeAmount.cents, sourceId: 1, name: 'Ventas'),
    ]);

    final summary = await getMonthSummary(year: 2026, month: 11);

    expect(summary.totalIncome, largeAmount);
    expect(summary.incomeBreakdown.single.total, largeAmount);
  });

  test('should sort the breakdown by total descending', () async {
    stubViews([
      _incomeView(cents: 30000, sourceId: 1, name: 'Restaurante'),
      _incomeView(cents: 120000, sourceId: 2, name: 'Pelotas'),
      _expenseView(cents: 20000, categoryId: 1, name: 'Comida'),
      _expenseView(cents: 5000, categoryId: 2, name: 'Transporte'),
    ]);

    final summary = await getMonthSummary(year: 2026, month: 11);

    expect(summary.incomeBreakdown.map((item) => item.name), [
      'Pelotas',
      'Restaurante',
    ]);
    expect(summary.incomeBreakdown.map((item) => item.total.cents), [
      120000,
      30000,
    ]);
    expect(summary.expenseBreakdown.map((item) => item.name), [
      'Comida',
      'Transporte',
    ]);
  });

  test('should group movements of the same source', () async {
    stubViews([
      _incomeView(cents: 30000, sourceId: 1, name: 'Restaurante'),
      _incomeView(cents: 20000, sourceId: 1, name: 'Restaurante'),
    ]);

    final summary = await getMonthSummary(year: 2026, month: 11);

    expect(summary.incomeBreakdown, hasLength(1));
    expect(summary.incomeBreakdown.single.total, const Money.fromCents(50000));
  });

  test('should query from the first to the last day of the month', () async {
    stubViews(const []);

    await getMonthSummary(year: 2026, month: 10);

    final filter =
        verify(() => repository.watchFiltered(captureAny())).captured.single
            as TransactionFilter;
    expect(filter.from?.value, 20261001);
    expect(filter.to?.value, 20261031);
  });

  test('should query the right range when the year changes', () async {
    stubViews(const []);

    await getMonthSummary(year: 2026, month: 12);
    await getMonthSummary(year: 2027, month: 1);

    final filters = verify(() => repository.watchFiltered(captureAny()))
        .captured
        .cast<TransactionFilter>()
        .toList();
    expect(filters[0].from?.value, 20261201);
    expect(filters[0].to?.value, 20261231);
    expect(filters[1].from?.value, 20270101);
    expect(filters[1].to?.value, 20270131);
  });

  test('should query the leap day in February', () async {
    stubViews(const []);

    await getMonthSummary(year: 2024, month: 2);

    final filter =
        verify(() => repository.watchFiltered(captureAny())).captured.single
            as TransactionFilter;
    expect(filter.from?.value, 20240201);
    expect(filter.to?.value, 20240229);
  });
}
