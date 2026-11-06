import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/usecases/withdraw_savings_contribution.dart';

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
  late WithdrawSavingsContribution withdrawSavingsContribution;

  setUp(() {
    repository = _MockSavingsGoalRepository();
    withdrawSavingsContribution = WithdrawSavingsContribution(repository);
  });

  test('should subtract the amount when there is enough saved money', () async {
    when(() => repository.getById(1)).thenAnswer((_) async => Success(_goal()));
    when(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto',
        description: 'Ahorro',
        targetAmount: _target,
        currentAmount: const Money.fromCents(150000000),
        targetDate: _deadline,
        colorValue: _color,
      ),
    ).thenAnswer((_) async => Success(_goal(currentCents: 150000000)));

    final result = await withdrawSavingsContribution(
      goalId: 1,
      amount: const Money.fromCents(100000000),
    );

    expect(result.valueOrNull?.currentAmount.cents, 150000000);
  });

  test('should leave zero saved when withdrawing the whole amount', () async {
    when(() => repository.getById(1)).thenAnswer((_) async => Success(_goal()));
    when(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto',
        description: 'Ahorro',
        targetAmount: _target,
        currentAmount: Money.zero,
        targetDate: _deadline,
        colorValue: _color,
      ),
    ).thenAnswer((_) async => Success(_goal(currentCents: 0)));

    final result = await withdrawSavingsContribution(
      goalId: 1,
      amount: const Money.fromCents(250000000),
    );

    expect(result.valueOrNull?.currentAmount, Money.zero);
    expect(result.valueOrNull?.currentAmount.isNegative, isFalse);
  });

  test('should fail when the withdrawal passes the saved amount', () async {
    when(() => repository.getById(1)).thenAnswer((_) async => Success(_goal()));

    final result = await withdrawSavingsContribution(
      goalId: 1,
      amount: const Money.fromCents(300000000),
    );

    expect(result.failureOrNull, _hasField('amount.exceedsAvailable'));
    verifyNever(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto',
        description: 'Ahorro',
        targetAmount: _target,
        currentAmount: const Money.fromCents(-50000000),
        targetDate: _deadline,
        colorValue: _color,
      ),
    );
  });

  test('should fail when the amount is not positive', () async {
    final result = await withdrawSavingsContribution(
      goalId: 1,
      amount: const Money.fromCents(-1),
    );

    expect(result.failureOrNull, _hasField('amount.notPositive'));
    verifyNever(() => repository.getById(1));
  });

  test(
    'should return the not found failure when the goal does not exist',
    () async {
      when(() => repository.getById(9)).thenAnswer(
        (_) async => const Err(NotFoundFailure(resource: 'SavingsGoal')),
      );

      final result = await withdrawSavingsContribution(
        goalId: 9,
        amount: const Money.fromCents(100000000),
      );

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );

  test('should keep large amounts exact when withdrawing', () async {
    const largeTarget = Money.fromCents(9000000000000);
    when(() => repository.getById(1)).thenAnswer(
      (_) async => Success(
        _goal(targetAmount: largeTarget, currentCents: 9000000000000),
      ),
    );
    when(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto',
        description: 'Ahorro',
        targetAmount: largeTarget,
        currentAmount: const Money.fromCents(8999000000000),
        targetDate: _deadline,
        colorValue: _color,
      ),
    ).thenAnswer(
      (_) async => Success(
        _goal(targetAmount: largeTarget, currentCents: 8999000000000),
      ),
    );

    final result = await withdrawSavingsContribution(
      goalId: 1,
      amount: const Money.fromCents(1000000000),
    );

    expect(result.valueOrNull?.currentAmount.cents, 8999000000000);
  });
}
