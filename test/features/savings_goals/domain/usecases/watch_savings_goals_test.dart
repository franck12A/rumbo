import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/usecases/watch_savings_goals.dart';

class _MockSavingsGoalRepository extends Mock implements SavingsGoalRepository;

SavingsGoal _goal({int id = 1, String name = 'Comprar un auto'}) => SavingsGoal(
  id: id,
  name: name,
  targetAmount: const Money.fromCents(1500000000),
  currentAmount: Money.zero,
  colorValue: 0xFF1565C0,
  createdAt: DateTime.utc(2026, 11, 6),
  updatedAt: DateTime.utc(2026, 11, 6),
);

void main() {
  late _MockSavingsGoalRepository repository;
  late WatchSavingsGoals watchSavingsGoals;

  setUp(() {
    repository = _MockSavingsGoalRepository();
    watchSavingsGoals = WatchSavingsGoals(repository);
  });

  test('should emit the goals streamed by the repository', () async {
    when(
      () => repository.watchAll(),
    ).thenAnswer((_) => Stream.value([_goal(), _goal(id: 2, name: 'Viaje')]));

    final goals = await watchSavingsGoals().first;

    expect(goals.map((goal) => goal.name), ['Comprar un auto', 'Viaje']);
  });
}
