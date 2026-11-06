import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';

/// Reads one savings goal, used by the detail and edit screens.
final class GetSavingsGoalById {
  const GetSavingsGoalById(this._repository);

  final SavingsGoalRepository _repository;

  Future<Result<SavingsGoal>> call(int id) => _repository.getById(id);
}
