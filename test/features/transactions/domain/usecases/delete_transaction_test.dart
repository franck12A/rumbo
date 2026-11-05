import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:rumbo/features/transactions/domain/usecases/delete_transaction.dart';

class _MockTransactionRepository extends Mock implements TransactionRepository;

void main() {
  late _MockTransactionRepository repository;
  late DeleteTransaction deleteTransaction;

  setUp(() {
    repository = _MockTransactionRepository();
    deleteTransaction = DeleteTransaction(repository);
  });

  test('should return the deleted transaction when it exists', () async {
    final deleted = Transaction(
      id: 1,
      type: TransactionType.income,
      amount: const Money.fromCents(150000),
      date: CalendarDate(year: 2026, month: 11, day: 5),
      incomeSourceId: 1,
      createdAt: DateTime.utc(2026, 11, 5, 12),
    );
    when(() => repository.delete(1)).thenAnswer((_) async => Success(deleted));

    final result = await deleteTransaction(1);

    expect(result.valueOrNull?.id, 1);
    verify(() => repository.delete(1)).called(1);
  });

  test('should return the not found failure when it does not exist', () async {
    when(() => repository.delete(9))
        .thenAnswer((_) async => const Err(NotFoundFailure()));

    final result = await deleteTransaction(9);

    expect(result.failureOrNull, isA<NotFoundFailure>());
  });
}
