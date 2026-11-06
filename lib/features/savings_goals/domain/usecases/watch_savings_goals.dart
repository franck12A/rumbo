import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';

/// Streams the savings goals for the list screen.
final class WatchSavingsGoals {
  const WatchSavingsGoals(this._repository);

  final SavingsGoalRepository _repository;

  Stream<List<SavingsGoal>> call() => _repository.watchAll();
}
