import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';

/// Persistence boundary for savings goals, implemented in `data/`.
abstract interface class SavingsGoalRepository {
  /// Emits every savings goal, newest first, each time one changes.
  Stream<List<SavingsGoal>> watchAll();

  Future<Result<SavingsGoal>> getById(int id);

  Future<Result<SavingsGoal>> create({
    required String name,
    required Money targetAmount,
    required Money currentAmount,
    required int colorValue,
    String? description,
    CalendarDate? targetDate,
  });

  Future<Result<SavingsGoal>> update({
    required int id,
    required String name,
    required Money targetAmount,
    required Money currentAmount,
    required int colorValue,
    String? description,
    CalendarDate? targetDate,
  });

  /// Deletes the goal and returns it.
  Future<Result<SavingsGoal>> delete(int id);
}
