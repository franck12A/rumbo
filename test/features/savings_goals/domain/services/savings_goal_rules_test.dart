import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/services/savings_goal_rules.dart';

const _target = Money.fromCents(1500000000);

SavingsGoal _goal({
  Money currentAmount = const Money.fromCents(250000000),
  Money targetAmount = _target,
}) => SavingsGoal(
  id: 1,
  name: 'Comprar un auto',
  targetAmount: targetAmount,
  currentAmount: currentAmount,
  colorValue: 0xFF1565C0,
  createdAt: DateTime.utc(2026, 11, 6),
  updatedAt: DateTime.utc(2026, 11, 6),
);

Failure? _validate({
  String name = 'Comprar un auto',
  Money targetAmount = _target,
  Money currentAmount = Money.zero,
}) => SavingsGoalRules.validate(
  name: SavingsGoalRules.normalizeName(name),
  targetAmount: targetAmount,
  currentAmount: currentAmount,
);

Matcher _hasField(String field) =>
    isA<ValidationFailure>().having((failure) => failure.field, 'field', field);

void main() {
  group('name', () {
    test('should accept a name with exactly 60 characters', () {
      final failure = _validate(name: 'a' * 60);

      expect(failure, isNull);
    });

    test('should reject an empty name', () {
      expect(_validate(name: '   '), _hasField('name.empty'));
    });

    test('should reject a name longer than 60 characters', () {
      expect(_validate(name: 'a' * 61), _hasField('name.tooLong'));
    });

    test('should trim the name and the description', () {
      expect(SavingsGoalRules.normalizeName('  Auto  '), 'Auto');
      expect(SavingsGoalRules.normalizeDescription('  Ahorro  '), 'Ahorro');
      expect(SavingsGoalRules.normalizeDescription('   '), isNull);
      expect(SavingsGoalRules.normalizeDescription(null), isNull);
    });
  });

  group('amounts', () {
    test('should reject a zero target amount', () {
      expect(
        _validate(targetAmount: Money.zero),
        _hasField('targetAmount.notPositive'),
      );
    });

    test('should reject a negative target amount', () {
      expect(
        _validate(targetAmount: const Money.fromCents(-1)),
        _hasField('targetAmount.notPositive'),
      );
    });

    test('should reject a negative saved amount', () {
      expect(
        _validate(currentAmount: const Money.fromCents(-1)),
        _hasField('currentAmount.negative'),
      );
    });

    test('should reject a saved amount larger than the target', () {
      expect(
        _validate(currentAmount: const Money.fromCents(1500000001)),
        _hasField('currentAmount.exceedsTarget'),
      );
    });

    test('should accept a saved amount equal to the target', () {
      expect(_validate(currentAmount: _target), isNull);
    });

    test('should reject a non positive contribution', () {
      expect(
        SavingsGoalRules.validateAmount(Money.zero),
        _hasField('amount.notPositive'),
      );
    });
  });

  group('movements', () {
    test('should reject a contribution that passes the target', () {
      final failure = SavingsGoalRules.validateContribution(
        goal: _goal(),
        amount: const Money.fromCents(1250000001),
      );

      expect(failure, _hasField('amount.exceedsRemaining'));
    });

    test('should accept a contribution that reaches the target exactly', () {
      final failure = SavingsGoalRules.validateContribution(
        goal: _goal(),
        amount: const Money.fromCents(1250000000),
      );

      expect(failure, isNull);
    });

    test('should reject a withdrawal larger than the saved amount', () {
      final failure = SavingsGoalRules.validateWithdrawal(
        goal: _goal(),
        amount: const Money.fromCents(250000001),
      );

      expect(failure, _hasField('amount.exceedsAvailable'));
    });

    test('should accept a withdrawal of the whole saved amount', () {
      final failure = SavingsGoalRules.validateWithdrawal(
        goal: _goal(),
        amount: const Money.fromCents(250000000),
      );

      expect(failure, isNull);
    });
  });
}
