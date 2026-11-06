import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/usecases/get_savings_goal_by_id.dart';

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
  late GetSavingsGoalById getSavingsGoalById;

  setUp(() {
    repository = _MockSavingsGoalRepository();
    getSavingsGoalById = GetSavingsGoalById(repository);
  });

  test('should return the goal when it exists', () async {
    when(() => repository.getById(1)).thenAnswer((_) async => Success(_goal()));

    final result = await getSavingsGoalById(1);

    expect(result.valueOrNull?.name, 'Comprar un auto');
  });

  test('should return the not found failure when it does not exist', () async {
    when(() => repository.getById(9)).thenAnswer(
      (_) async => const Err(NotFoundFailure(resource: 'SavingsGoal')),
    );

    final result = await getSavingsGoalById(9);

    expect(result.failureOrNull, isA<NotFoundFailure>());
  });
}
