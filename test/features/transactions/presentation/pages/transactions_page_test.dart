import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/app/di.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/domain/lookups/income_source_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:rumbo/features/transactions/presentation/pages/transactions_page.dart';
import 'package:rumbo/features/transactions/presentation/providers/selected_month_provider.dart';

class _MockTransactionRepository extends Mock implements TransactionRepository;

class _MockIncomeSourceLookup extends Mock implements IncomeSourceLookup;

class _FixedSelectedMonth extends SelectedMonthController {
  _FixedSelectedMonth(this.initial);

  final SelectedMonth initial;

  @override
  SelectedMonth build() => initial;
}

final _november = CalendarDate(year: 2026, month: 11, day: 1);

TransactionView _view({
  required int id,
  required TransactionType type,
  required int cents,
  required int day,
  required String name,
  String? note,
  bool archived = false,
}) {
  final isIncome = type == TransactionType.income;
  return TransactionView(
    transaction: Transaction(
      id: id,
      type: type,
      amount: Money.fromCents(cents),
      date: CalendarDate(year: 2026, month: 11, day: day),
      note: note,
      incomeSourceId: isIncome ? 1 : null,
      categoryId: isIncome ? null : 2,
      createdAt: DateTime.utc(2026, 11, day, 12),
    ),
    source: isIncome
        ? ReferenceInfo(
            id: 1,
            name: name,
            colorValue: 0xFF2E7D32,
            isArchived: archived,
          )
        : null,
    category: isIncome
        ? null
        : ReferenceInfo(
            id: 2,
            name: name,
            colorValue: 0xFF6A1B9A,
            isArchived: archived,
          ),
  );
}

Widget _buildApp(
  TransactionRepository repository, {
  IncomeSourceLookup? incomeSourceLookup,
}) => ProviderScope(
  overrides: [
    transactionRepositoryProvider.overrideWithValue(repository),
    selectedMonthControllerProvider.overrideWith(
      () => _FixedSelectedMonth(
        SelectedMonth(year: _november.year, month: _november.month),
      ),
    ),
    if (incomeSourceLookup != null)
      incomeSourceLookupProvider.overrideWithValue(incomeSourceLookup),
  ],
  child: const MaterialApp(home: TransactionsPage()),
);

void main() {
  setUpAll(() {
    registerFallbackValue(const TransactionFilter());
  });

  testWidgets('should show the empty state when the month has no movements', (
    tester,
  ) async {
    final repository = _MockTransactionRepository();
    when(() => repository.watchFiltered(any()))
        .thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.transactionsEmptyTitle), findsOneWidget);
    expect(find.text(AppStrings.transactionsNewIncome), findsOneWidget);
    expect(find.text(AppStrings.transactionsNewExpense), findsOneWidget);
    expect(find.text('Noviembre 2026'), findsOneWidget);
  });

  testWidgets('should group the movements by day with readable headers', (
    tester,
  ) async {
    final repository = _MockTransactionRepository();
    when(() => repository.watchFiltered(any())).thenAnswer(
      (_) => Stream.value([
        _view(
          id: 1,
          type: TransactionType.income,
          cents: 1000000,
          day: 5,
          name: 'Restaurante',
        ),
        _view(
          id: 2,
          type: TransactionType.expense,
          cents: 250000,
          day: 5,
          name: 'Materiales',
          note: 'Insumos',
        ),
        _view(
          id: 3,
          type: TransactionType.expense,
          cents: 50000,
          day: 1,
          name: 'Transporte',
        ),
      ]),
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Jueves 5 de noviembre'), findsOneWidget);
    expect(find.text('Domingo 1 de noviembre'), findsOneWidget);
    expect(find.text('Restaurante'), findsOneWidget);
    expect(find.text('Materiales'), findsOneWidget);
    expect(find.text('Insumos'), findsOneWidget);
    expect(find.text('Transporte'), findsOneWidget);
    expect(find.text(r'+ $ 10.000,00'), findsOneWidget);
    expect(find.text(r'− $ 2.500,00'), findsOneWidget);
  });

  testWidgets('should show a negative balance with its sign and color', (
    tester,
  ) async {
    final repository = _MockTransactionRepository();
    when(() => repository.watchFiltered(any())).thenAnswer(
      (_) => Stream.value([
        _view(
          id: 1,
          type: TransactionType.income,
          cents: 1000000,
          day: 5,
          name: 'Restaurante',
        ),
        _view(
          id: 2,
          type: TransactionType.expense,
          cents: 1250000,
          day: 5,
          name: 'Materiales',
        ),
      ]),
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    final balance = tester.widget<Text>(find.text(r'$ -2.500,00'));
    expect(balance.style?.color, isNotNull);
    expect(find.text(AppStrings.transactionsSummaryBalance), findsOneWidget);
  });

  testWidgets('should show the error state with retry when the stream fails', (
    tester,
  ) async {
    final repository = _MockTransactionRepository();
    when(() => repository.watchFiltered(any()))
        .thenAnswer((_) => Stream.error(StateError('boom')));

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.transactionsErrorTitle), findsOneWidget);
    expect(find.text(AppStrings.retryAction), findsOneWidget);
  });

  testWidgets('should delete and undo by recreating the movement', (
    tester,
  ) async {
    final repository = _MockTransactionRepository();
    final lookup = _MockIncomeSourceLookup();
    final view = _view(
      id: 1,
      type: TransactionType.income,
      cents: 1000000,
      day: 5,
      name: 'Restaurante',
      note: 'Venta',
    );

    when(() => repository.watchFiltered(any()))
        .thenAnswer((_) => Stream.value([view]));
    when(() => repository.delete(1))
        .thenAnswer((_) async => Success(view.transaction));
    when(() => lookup.findById(1)).thenAnswer(
      (_) async => const ReferenceInfo(
        id: 1,
        name: 'Restaurante',
        colorValue: 0xFF2E7D32,
        isArchived: false,
      ),
    );
    when(
      () => repository.create(
        type: TransactionType.income,
        amount: const Money.fromCents(1000000),
        date: CalendarDate(year: 2026, month: 11, day: 5),
        note: 'Venta',
        incomeSourceId: 1,
      ),
    ).thenAnswer((_) async => Success(view.transaction));

    await tester.pumpWidget(_buildApp(repository, incomeSourceLookup: lookup));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(AppStrings.transactionDeleteTooltip));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.transactionDeleteAction));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.transactionDeletedMessage), findsOneWidget);
    verify(() => repository.delete(1)).called(1);

    await tester.tap(find.text(AppStrings.undoAction));
    await tester.pumpAndSettle();

    verify(
      () => repository.create(
        type: TransactionType.income,
        amount: const Money.fromCents(1000000),
        date: CalendarDate(year: 2026, month: 11, day: 5),
        note: 'Venta',
        incomeSourceId: 1,
      ),
    ).called(1);
  });
}
