import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/lookups/category_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/income_source_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:rumbo/features/transactions/domain/usecases/add_transaction.dart';

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
  String? note = 'Venta',
}) => Transaction(
  id: 1,
  type: type,
  amount: _amount,
  date: _date,
  note: note,
  incomeSourceId: incomeSourceId,
  categoryId: categoryId,
  createdAt: DateTime.utc(2026, 11, 5, 12),
);

void main() {
  late _MockTransactionRepository repository;
  late _MockIncomeSourceLookup incomeSources;
  late _MockCategoryLookup categories;
  late AddTransaction addTransaction;

  setUpAll(() {
    registerFallbackValue(TransactionType.income);
    registerFallbackValue(Money.zero);
    registerFallbackValue(CalendarDate(year: 2026, month: 1, day: 1));
  });

  setUp(() {
    repository = _MockTransactionRepository();
    incomeSources = _MockIncomeSourceLookup();
    categories = _MockCategoryLookup();
    addTransaction = AddTransaction(repository, incomeSources, categories);
  });

  void verifyNeverCreated() {
    verifyNever(
      () => repository.create(
        type: any(named: 'type'),
        amount: any(named: 'amount'),
        date: any(named: 'date'),
        note: any(named: 'note'),
        incomeSourceId: any(named: 'incomeSourceId'),
        categoryId: any(named: 'categoryId'),
      ),
    );
  }

  test('should create the income when the source is active', () async {
    when(() => incomeSources.findById(1)).thenAnswer((_) async => _reference());
    when(
      () => repository.create(
        type: TransactionType.income,
        amount: _amount,
        date: _date,
        note: 'Venta',
        incomeSourceId: 1,
      ),
    ).thenAnswer((_) async => Success(_transaction()));

    final result = await addTransaction(
      type: TransactionType.income,
      amount: _amount,
      date: _date,
      note: '  Venta  ',
      incomeSourceId: 1,
    );

    expect(result.valueOrNull?.type, TransactionType.income);
    verify(
      () => repository.create(
        type: TransactionType.income,
        amount: _amount,
        date: _date,
        note: 'Venta',
        incomeSourceId: 1,
      ),
    ).called(1);
  });

  test('should create the expense when the category is active', () async {
    when(() => categories.findById(4))
        .thenAnswer((_) async => _reference(id: 4, name: 'Comida'));
    when(
      () => repository.create(
        type: TransactionType.expense,
        amount: _amount,
        date: _date,
        categoryId: 4,
      ),
    ).thenAnswer(
      (_) async => Success(
        _transaction(
          type: TransactionType.expense,
          incomeSourceId: null,
          categoryId: 4,
        ),
      ),
    );

    final result = await addTransaction(
      type: TransactionType.expense,
      amount: _amount,
      date: _date,
      note: '   ',
      categoryId: 4,
    );

    expect(result.valueOrNull?.type, TransactionType.expense);
    verify(
      () => repository.create(
        type: TransactionType.expense,
        amount: _amount,
        date: _date,
        categoryId: 4,
      ),
    ).called(1);
  });

  test('should fail when the amount is not positive', () async {
    final result = await addTransaction(
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
    verifyNeverCreated();
  });

  test('should fail when an income has no source', () async {
    final result = await addTransaction(
      type: TransactionType.income,
      amount: _amount,
      date: _date,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'source.required',
      ),
    );
    verifyNeverCreated();
  });

  test('should fail when an income also has a category', () async {
    final result = await addTransaction(
      type: TransactionType.income,
      amount: _amount,
      date: _date,
      incomeSourceId: 1,
      categoryId: 2,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'category.unexpected',
      ),
    );
    verifyNeverCreated();
  });

  test('should fail when an expense has no category', () async {
    final result = await addTransaction(
      type: TransactionType.expense,
      amount: _amount,
      date: _date,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'category.required',
      ),
    );
    verifyNeverCreated();
  });

  test('should fail when an expense also has a source', () async {
    final result = await addTransaction(
      type: TransactionType.expense,
      amount: _amount,
      date: _date,
      incomeSourceId: 1,
      categoryId: 2,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'source.unexpected',
      ),
    );
    verifyNeverCreated();
  });

  test('should fail when the note is longer than 200 characters', () async {
    final result = await addTransaction(
      type: TransactionType.income,
      amount: _amount,
      date: _date,
      note: 'a' * 201,
      incomeSourceId: 1,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'note.tooLong',
      ),
    );
    verifyNeverCreated();
  });

  test('should fail when the source does not exist', () async {
    when(() => incomeSources.findById(9)).thenAnswer((_) async => null);

    final result = await addTransaction(
      type: TransactionType.income,
      amount: _amount,
      date: _date,
      incomeSourceId: 9,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'source.notFound',
      ),
    );
    verifyNeverCreated();
  });

  test('should fail when the source is archived', () async {
    when(() => incomeSources.findById(1))
        .thenAnswer((_) async => _reference(isArchived: true));

    final result = await addTransaction(
      type: TransactionType.income,
      amount: _amount,
      date: _date,
      incomeSourceId: 1,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'source.archived',
      ),
    );
    verifyNeverCreated();
  });

  test('should fail when the category is archived', () async {
    when(() => categories.findById(2))
        .thenAnswer((_) async => _reference(id: 2, isArchived: true));

    final result = await addTransaction(
      type: TransactionType.expense,
      amount: _amount,
      date: _date,
      categoryId: 2,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'category.archived',
      ),
    );
    verifyNeverCreated();
  });

  test('should return the repository failure when the insert fails', () async {
    when(() => incomeSources.findById(1)).thenAnswer((_) async => _reference());
    const failure = DatabaseFailure(message: 'insert failed');
    when(
      () => repository.create(
        type: TransactionType.income,
        amount: _amount,
        date: _date,
        incomeSourceId: 1,
      ),
    ).thenAnswer((_) async => const Err(failure));

    final result = await addTransaction(
      type: TransactionType.income,
      amount: _amount,
      date: _date,
      incomeSourceId: 1,
    );

    expect(result.failureOrNull, same(failure));
  });
}
