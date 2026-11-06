import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';

const _target = Money.fromCents(1500000000);

SavingsGoal _goal({
  Money targetAmount = _target,
  Money currentAmount = const Money.fromCents(250000000),
}) => SavingsGoal(
  id: 1,
  name: 'Comprar un auto',
  targetAmount: targetAmount,
  currentAmount: currentAmount,
  colorValue: 0xFF1565C0,
  createdAt: DateTime.utc(2026, 11, 6),
  updatedAt: DateTime.utc(2026, 11, 6),
);

void main() {
  test(
    'should compute the progress percentage when part of the target is saved',
    () {
      final goal = _goal();

      expect(goal.progressPercentage, closeTo(16.67, 0.01));
      expect(goal.isCompleted, isFalse);
    },
  );

  test('should cap the progress at 100 percent when the target is reached', () {
    final goal = _goal(currentAmount: _target);

    expect(goal.progress, 1.0);
    expect(goal.progressPercentage, 100);
    expect(goal.isCompleted, isTrue);
  });

  test(
    'should cap the progress at 100 percent when the saved amount is larger',
    () {
      final goal = _goal(currentAmount: const Money.fromCents(2000000000));

      expect(goal.progress, 1.0);
    },
  );

  test('should report zero progress when nothing was saved', () {
    final goal = _goal(currentAmount: Money.zero);

    expect(goal.progress, 0.0);
    expect(goal.isCompleted, isFalse);
  });

  test('should keep large amounts exact when computing the progress', () {
    final goal = _goal(
      targetAmount: const Money.fromCents(9000000000000),
      currentAmount: const Money.fromCents(4500000000000),
    );

    expect(goal.progress, closeTo(0.5, 0.0001));
  });
}
