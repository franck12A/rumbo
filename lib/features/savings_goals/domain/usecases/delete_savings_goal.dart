import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';

/// Deletes a savings goal and returns the removed entity.
final class DeleteSavingsGoal {
  const DeleteSavingsGoal(this._repository);

  final SavingsGoalRepository _repository;

  Future<Result<SavingsGoal>> call(int id) => _repository.delete(id);
}
