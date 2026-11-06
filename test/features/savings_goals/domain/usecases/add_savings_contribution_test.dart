import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/usecases/add_savings_contribution.dart';

class _MockSavingsGoalRepository extends Mock implements SavingsGoalRepository;

const _target = Money.fromCents(1500000000);
const _color = 0xFF1565C0;
final _deadline = CalendarDate(year: 2027, month: 12, day: 31);

SavingsGoal _goal({
  int currentCents = 250000000,
  Money targetAmount = _target,
}) => SavingsGoal(
  id: 1,
  name: 'Comprar un auto',
  description: 'Ahorro',
  targetAmount: targetAmount,
  currentAmount: Money.fromCents(currentCents),
  targetDate: _deadline,
  colorValue: _color,
  createdAt: DateTime.utc(2026, 11, 6),
  updatedAt: DateTime.utc(2026, 11, 6),
);

Matcher _hasField(String field) =>
    isA<ValidationFailure>().having((failure) => failure.field, 'field', field);

void main() {
  late _MockSavingsGoalRepository repository;
  late AddSavingsContribution addSavingsContribution;

  setUp(() {
    repository = _MockSavingsGoalRepository();
    addSavingsContribution = AddSavingsContribution(repository);
  });

  void verifyNeverUpdated() {
    verifyNever(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto',
        description: 'Ahorro',
        targetAmount: _target,
        currentAmount: const Money.fromCents(350000000),
        targetDate: _deadline,
        colorValue: _color,
      ),
    );
  }

  test(
    'should add the amount to the saved money when the goal exists',
    () async {
      when(() => repository.getById(1))
          .thenAnswer((_) async => Success(_goal()));
      when(
        () => repository.update(
          id: 1,
          name: 'Comprar un auto',
          description: 'Ahorro',
          targetAmount: _target,
          currentAmount: const Money.fromCents(350000000),
          targetDate: _deadline,
          colorValue: _color,
        ),
      ).thenAnswer((_) async => Success(_goal(currentCents: 350000000)));

      final result = await addSavingsContribution(
        goalId: 1,
        amount: const Money.fromCents(100000000),
      );

      expect(result.valueOrNull?.currentAmount.cents, 350000000);
    },
  );

  test(
    'should complete the goal when the contribution reaches the target',
    () async {
      when(() => repository.getById(1))
          .thenAnswer((_) async => Success(_goal(currentCents: 1400000000)));
      when(
        () => repository.update(
          id: 1,
          name: 'Comprar un auto',
          description: 'Ahorro',
          targetAmount: _target,
          currentAmount: _target,
          targetDate: _deadline,
          colorValue: _color,
        ),
      ).thenAnswer((_) async => Success(_goal(currentCents: 1500000000)));

      final result = await addSavingsContribution(
        goalId: 1,
        amount: const Money.fromCents(100000000),
      );

      expect(result.valueOrNull?.isCompleted, isTrue);
      expect(result.valueOrNull?.progress, 1.0);
    },
  );

  test('should fail when the amount is not positive', () async {
    final result = await addSavingsContribution(goalId: 1, amount: Money.zero);

    expect(result.failureOrNull, _hasField('amount.notPositive'));
    verifyNever(() => repository.getById(1));
  });

  test(
    'should fail when the contribution passes the remaining amount',
    () async {
      when(() => repository.getById(1))
          .thenAnswer((_) async => Success(_goal(currentCents: 1450000000)));

      final result = await addSavingsContribution(
        goalId: 1,
        amount: const Money.fromCents(100000000),
      );

      expect(result.failureOrNull, _hasField('amount.exceedsRemaining'));
      verifyNeverUpdated();
    },
  );

  test(
    'should return the not found failure when the goal does not exist',
    () async {
      when(() => repository.getById(9)).thenAnswer(
        (_) async => const Err(NotFoundFailure(resource: 'SavingsGoal')),
      );

      final result = await addSavingsContribution(
        goalId: 9,
        amount: const Money.fromCents(100000000),
      );

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );

  test('should keep large amounts exact when contributing', () async {
    const largeTarget = Money.fromCents(9000000000000);
    when(() => repository.getById(1)).thenAnswer(
      (_) async => Success(
        _goal(targetAmount: largeTarget, currentCents: 8999000000000),
      ),
    );
    when(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto',
        description: 'Ahorro',
        targetAmount: largeTarget,
        currentAmount: largeTarget,
        targetDate: _deadline,
        colorValue: _color,
      ),
    ).thenAnswer(
      (_) async => Success(
        _goal(targetAmount: largeTarget, currentCents: 9000000000000),
      ),
    );

    final result = await addSavingsContribution(
      goalId: 1,
      amount: const Money.fromCents(1000000000),
    );

    expect(result.valueOrNull?.currentAmount.cents, 9000000000000);
  });
}
