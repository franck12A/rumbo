import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';

/// Invariants shared by the savings goal use cases.
abstract final class SavingsGoalRules {
  static const maxNameLength = 60;

  /// Removes the surrounding whitespace the user may have typed.
  static String normalizeName(String raw) => raw.trim();

  /// Trims the description and turns a blank one into `null`.
  static String? normalizeDescription(String? raw) {
    final trimmed = raw?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Returns the failure that forbids the goal, or `null` if it is valid.
  ///
  /// A `CalendarDate` rejects impossible days when it is built, so a goal
  /// date is valid by construction.
  static Failure? validate({
    required String name,
    required Money targetAmount,
    required Money currentAmount,
  }) {
    if (name.isEmpty) {
      return const ValidationFailure(
        field: 'name.empty',
        message: 'Goal name must not be empty',
      );
    }
    if (name.runes.length > maxNameLength) {
      return const ValidationFailure(
        field: 'name.tooLong',
        message: 'Goal name is longer than $maxNameLength characters',
      );
    }
    if (!targetAmount.isPositive) {
      return const ValidationFailure(
        field: 'targetAmount.notPositive',
        message: 'Target amount must be greater than zero',
      );
    }
    if (currentAmount.isNegative) {
      return const ValidationFailure(
        field: 'currentAmount.negative',
        message: 'Saved amount must not be negative',
      );
    }
    if (currentAmount > targetAmount) {
      return const ValidationFailure(
        field: 'currentAmount.exceedsTarget',
        message: 'Saved amount cannot exceed the target amount',
      );
    }
    return null;
  }

  /// Returns the failure that forbids the [amount], or `null` if it is valid.
  static Failure? validateAmount(Money amount) {
    if (!amount.isPositive) {
      return const ValidationFailure(
        field: 'amount.notPositive',
        message: 'Amount must be greater than zero',
      );
    }
    return null;
  }

  /// Rejects a contribution that would push the progress past 100 %.
  ///
  /// [amount] is expected to be positive: [validateAmount] runs first.
  static Failure? validateContribution({
    required SavingsGoal goal,
    required Money amount,
  }) {
    if (goal.currentAmount + amount > goal.targetAmount) {
      return const ValidationFailure(
        field: 'amount.exceedsRemaining',
        message: 'Contribution exceeds the amount still needed',
      );
    }
    return null;
  }

  /// Rejects a withdrawal larger than the money saved so far.
  ///
  /// [amount] is expected to be positive: [validateAmount] runs first.
  static Failure? validateWithdrawal({
    required SavingsGoal goal,
    required Money amount,
  }) {
    if (amount > goal.currentAmount) {
      return const ValidationFailure(
        field: 'amount.exceedsAvailable',
        message: 'Withdrawal exceeds the saved amount',
      );
    }
    return null;
  }
}
