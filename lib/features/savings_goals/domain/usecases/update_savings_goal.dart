import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/services/savings_goal_rules.dart';

/// Edits an existing savings goal, keeping its invariants.
final class UpdateSavingsGoal {
  const UpdateSavingsGoal(this._repository);

  final SavingsGoalRepository _repository;

  Future<Result<SavingsGoal>> call({
    required int id,
    required String name,
    required Money targetAmount,
    required Money currentAmount,
    required int colorValue,
    String? description,
    CalendarDate? targetDate,
  }) async {
    final normalizedName = SavingsGoalRules.normalizeName(name);
    final validation = SavingsGoalRules.validate(
      name: normalizedName,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
    );
    if (validation != null) {
      return Err(validation);
    }

    final found = await _repository.getById(id);
    switch (found) {
      case Err(:final failure):
        return Err(failure);
      case Success():
        break;
    }

    return await _repository.update(
      id: id,
      name: normalizedName,
      description: SavingsGoalRules.normalizeDescription(description),
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: targetDate,
      colorValue: colorValue,
    );
  }
}
