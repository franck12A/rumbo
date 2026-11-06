import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/data/tables/savings_goals_table.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';

/// Translates drift rows into domain entities so no drift type leaves `data/`.
abstract final class SavingsGoalMapper {
  static SavingsGoal toDomain(SavingsGoalRow row) {
    final targetDate = row.targetDate;
    return SavingsGoal(
      id: row.id,
      name: row.name,
      description: row.description,
      targetAmount: Money.fromCents(row.targetAmountCents),
      currentAmount: Money.fromCents(row.currentAmountCents),
      targetDate: targetDate == null ? null : CalendarDate.fromInt(targetDate),
      colorValue: row.colorValue,
      // Instants are always handed out in UTC.
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
    );
  }
}
