import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/services/savings_goal_rules.dart';

/// Adds money to the amount already saved towards a goal.
final class AddSavingsContribution {
  const AddSavingsContribution(this._repository);

  final SavingsGoalRepository _repository;

  Future<Result<SavingsGoal>> call({
    required int goalId,
    required Money amount,
  }) async {
    final amountFailure = SavingsGoalRules.validateAmount(amount);
    if (amountFailure != null) {
      return Err(amountFailure);
    }

    final found = await _repository.getById(goalId);
    final SavingsGoal goal;
    switch (found) {
      case Err(:final failure):
        return Err(failure);
      case Success(:final value):
        goal = value;
    }

    final contributionFailure = SavingsGoalRules.validateContribution(
      goal: goal,
      amount: amount,
    );
    if (contributionFailure != null) {
      return Err(contributionFailure);
    }

    return await _repository.update(
      id: goal.id,
      name: goal.name,
      description: goal.description,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount + amount,
      targetDate: goal.targetDate,
      colorValue: goal.colorValue,
    );
  }
}
