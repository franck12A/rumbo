import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';

part 'savings_goal.freezed.dart';

/// A savings target, like "Comprar un auto", and the money saved for it.
@freezed
abstract class SavingsGoal with _$SavingsGoal {
  const factory SavingsGoal({
    required int id,
    required String name,
    required Money targetAmount,
    required Money currentAmount,
    required int colorValue,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    CalendarDate? targetDate,
  }) = _SavingsGoal;

  const SavingsGoal._();

  /// Whether the saved amount already reached the target.
  ///
  /// Derived from the amounts, so a stored flag could never disagree with them.
  bool get isCompleted => currentAmount >= targetAmount;

  /// Saved share of the target, between 0 and 1.
  double get progress {
    if (!targetAmount.isPositive) {
      return 0;
    }
    final ratio = currentAmount.cents / targetAmount.cents;
    return ratio >= 1 ? 1.0 : ratio;
  }

  /// Saved share of the target as a percentage, e.g. `16.67`.
  double get progressPercentage => progress * 100;
}
