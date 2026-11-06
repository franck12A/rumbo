import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/services/savings_goal_rules.dart';

/// Creates a savings goal once its invariants pass.
final class CreateSavingsGoal {
  const CreateSavingsGoal(this._repository);

  final SavingsGoalRepository _repository;

  Future<Result<SavingsGoal>> call({
    required String name,
    required Money targetAmount,
    required int colorValue,
    String? description,
    Money currentAmount = Money.zero,
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

    return await _repository.create(
      name: normalizedName,
      description: SavingsGoalRules.normalizeDescription(description),
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: targetDate,
      colorValue: colorValue,
    );
  }
}
