import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/domain/lookups/category_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/income_source_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:rumbo/features/transactions/domain/usecases/update_transaction.dart';

class _MockTransactionRepository extends Mock implements TransactionRepository;

class _MockIncomeSourceLookup extends Mock implements IncomeSourceLookup;

class _MockCategoryLookup extends Mock implements CategoryLookup;

final _date = CalendarDate(year: 2026, month: 11, day: 5);
const _amount = Money.fromCents(150000);

ReferenceInfo _reference({
  int id = 1,
  String name = 'Restaurante',
  bool isArchived = false,
}) => ReferenceInfo(
  id: id,
  name: name,
  colorValue: 0xFFEF6C00,
  isArchived: isArchived,
);

Transaction _transaction({
  TransactionType type = TransactionType.income,
  int? incomeSourceId = 1,
  int? categoryId,
}) => Transaction(
  id: 1,
  type: type,
  amount: const Money.fromCents(100000),
  date: _date,
  note: 'Original',
  incomeSourceId: incomeSourceId,
  categoryId: categoryId,
  createdAt: DateTime.utc(2026, 11, 5, 12),
);

TransactionView _view({
  TransactionType type = TransactionType.income,
  int? incomeSourceId = 1,
  int? categoryId,
}) => TransactionView(
  transaction: _transaction(
    type: type,
    incomeSourceId: incomeSourceId,
    categoryId: categoryId,
  ),
);

void main() {
  late _MockTransactionRepository repository;
  late _MockIncomeSourceLookup incomeSources;
  late _MockCategoryLookup categories;
  late UpdateTransaction updateTransaction;

  setUpAll(() {
    registerFallbackValue(TransactionType.income);
    registerFallbackValue(Money.zero);
    registerFallbackValue(CalendarDate(year: 2026, month: 1, day: 1));
  });

  setUp(() {
    repository = _MockTransactionRepository();
    incomeSources = _MockIncomeSourceLookup();
    categories = _MockCategoryLookup();
    updateTransaction = UpdateTransaction(
      repository,
      incomeSources,
      categories,
    );
  });

  void verifyNeverUpdated() {
    verifyNever(
      () => repository.update(
        id: any(named: 'id'),
        type: any(named: 'type'),
        amount: any(named: 'amount'),
        date: any(named: 'date'),
        note: any(named: 'note'),
        incomeSourceId: any(named: 'incomeSourceId'),
        categoryId: any(named: 'categoryId'),
      ),
    );
  }

  test('should update the transaction when the reference is active', () async {
    when(() => repository.getById(1)).thenAnswer((_) async => Success(_view()));
    when(() => incomeSources.findById(1)).thenAnswer((_) async => _reference());
    when(
      () => repository.update(
        id: 1,
        type: TransactionType.income,
        amount: _amount,
        date: _date,
        note: 'Actualizada',
        incomeSourceId: 1,
      ),
    ).thenAnswer((_) async => Success(_transaction()));

    final result = await updateTransaction(
      id: 1,
      type: TransactionType.income,
      amount: _amount,
      date: _date,
      note: ' Actualizada ',
      incomeSourceId: 1,
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => repository.update(
        id: 1,
        type: TransactionType.income,
        amount: _amount,
        date: _date,
        note: 'Actualizada',
        incomeSourceId: 1,
      ),
    ).called(1);
  });

  test(
    'should keep a source that was archived after it was recorded',
    () async {
      when(() => repository.getById(1))
          .thenAnswer((_) async => Success(_view()));
      when(() => incomeSources.findById(1))
          .thenAnswer((_) async => _reference(isArchived: true));
      when(
        () => repository.update(
          id: 1,
          type: TransactionType.income,
          amount: _amount,
          date: _date,
          incomeSourceId: 1,
        ),
      ).thenAnswer((_) async => Success(_transaction()));

      final result = await updateTransaction(
        id: 1,
        type: TransactionType.income,
        amount: _amount,
        date: _date,
        incomeSourceId: 1,
      );

      expect(result.isSuccess, isTrue);
    },
  );

  test('should reject a different archived source', () async {
    when(() => repository.getById(1)).thenAnswer((_) async => Success(_view()));
    when(() => incomeSources.findById(2))
        .thenAnswer((_) async => _reference(id: 2, isArchived: true));

    final result = await updateTransaction(
      id: 1,
      type: TransactionType.income,
      amount: _amount,
      date: _date,
      incomeSourceId: 2,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'source.archived',
      ),
    );
    verifyNeverUpdated();
  });

  test('should reject a newly selected archived category', () async {
    when(() => repository.getById(1)).thenAnswer(
      (_) async => Success(
        _view(
          type: TransactionType.expense,
          incomeSourceId: null,
          categoryId: 2,
        ),
      ),
    );
    when(() => categories.findById(3))
        .thenAnswer((_) async => _reference(id: 3, isArchived: true));

    final result = await updateTransaction(
      id: 1,
      type: TransactionType.expense,
      amount: _amount,
      date: _date,
      categoryId: 3,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'category.archived',
      ),
    );
    verifyNeverUpdated();
  });

  test(
    'should return the not found failure when the id does not exist',
    () async {
      when(() => repository.getById(9))
          .thenAnswer((_) async => const Err(NotFoundFailure()));

      final result = await updateTransaction(
        id: 9,
        type: TransactionType.income,
        amount: _amount,
        date: _date,
        incomeSourceId: 1,
      );

      expect(result.failureOrNull, isA<NotFoundFailure>());
      verifyNeverUpdated();
    },
  );

  test('should fail validation before reading the transaction', () async {
    final result = await updateTransaction(
      id: 1,
      type: TransactionType.income,
      amount: Money.zero,
      date: _date,
      incomeSourceId: 1,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'amount.notPositive',
      ),
    );
    verifyNever(() => repository.getById(any()));
    verifyNeverUpdated();
  });

  test('should reject switching to an archived source', () async {
    when(() => repository.getById(1)).thenAnswer(
      (_) async => Success(
        _view(
          type: TransactionType.expense,
          incomeSourceId: null,
          categoryId: 2,
        ),
      ),
    );
    when(() => categories.findById(3))
        .thenAnswer((_) async => _reference(id: 3));
    when(() => incomeSources.findById(5))
        .thenAnswer((_) async => _reference(id: 5, isArchived: true));

    final result = await updateTransaction(
      id: 1,
      type: TransactionType.income,
      amount: _amount,
      date: _date,
      incomeSourceId: 5,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'source.archived',
      ),
    );
    verifyNeverUpdated();
  });
}
