import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/usecases/delete_savings_goal.dart';

class _MockSavingsGoalRepository extends Mock implements SavingsGoalRepository;

SavingsGoal _goal() => SavingsGoal(
  id: 1,
  name: 'Comprar un auto',
  targetAmount: const Money.fromCents(1500000000),
  currentAmount: Money.zero,
  colorValue: 0xFF1565C0,
  createdAt: DateTime.utc(2026, 11, 6),
  updatedAt: DateTime.utc(2026, 11, 6),
);

void main() {
  late _MockSavingsGoalRepository repository;
  late DeleteSavingsGoal deleteSavingsGoal;

  setUp(() {
    repository = _MockSavingsGoalRepository();
    deleteSavingsGoal = DeleteSavingsGoal(repository);
  });

  test('should return the deleted goal when it exists', () async {
    when(() => repository.delete(1)).thenAnswer((_) async => Success(_goal()));

    final result = await deleteSavingsGoal(1);

    expect(result.valueOrNull?.id, 1);
    verify(() => repository.delete(1)).called(1);
  });

  test('should return the not found failure when it does not exist', () async {
    when(() => repository.delete(9)).thenAnswer(
      (_) async => const Err(NotFoundFailure(resource: 'SavingsGoal')),
    );

    final result = await deleteSavingsGoal(9);

    expect(result.failureOrNull, isA<NotFoundFailure>());
  });
}
