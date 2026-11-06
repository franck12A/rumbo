import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/usecases/create_savings_goal.dart';

class _MockSavingsGoalRepository extends Mock implements SavingsGoalRepository;

const _target = Money.fromCents(1500000000);
const _color = 0xFF1565C0;

SavingsGoal _goal({String name = 'Comprar un auto'}) => SavingsGoal(
  id: 1,
  name: name,
  targetAmount: _target,
  currentAmount: Money.zero,
  colorValue: _color,
  createdAt: DateTime.utc(2026, 11, 6),
  updatedAt: DateTime.utc(2026, 11, 6),
);

Matcher _hasField(String field) =>
    isA<ValidationFailure>().having((failure) => failure.field, 'field', field);

void main() {
  late _MockSavingsGoalRepository repository;
  late CreateSavingsGoal createSavingsGoal;

  setUp(() {
    repository = _MockSavingsGoalRepository();
    createSavingsGoal = CreateSavingsGoal(repository);
  });

  void verifyNeverCreated() {
    verifyNever(
      () => repository.create(
        name: 'Comprar un auto',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    );
  }

  test('should create the goal with a trimmed name and description '
      'when the input is valid', () async {
    when(
      () => repository.create(
        name: 'Comprar un auto',
        description: 'Ahorro mensual',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    ).thenAnswer((_) async => Success(_goal()));

    final result = await createSavingsGoal(
      name: '  Comprar un auto  ',
      description: '  Ahorro mensual  ',
      targetAmount: _target,
      colorValue: _color,
    );

    expect(result.valueOrNull?.name, 'Comprar un auto');
    verify(
      () => repository.create(
        name: 'Comprar un auto',
        description: 'Ahorro mensual',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    ).called(1);
  });

  test('should accept a goal without a deadline', () async {
    when(
      () => repository.create(
        name: 'Viaje',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    ).thenAnswer((_) async => Success(_goal(name: 'Viaje')));

    final result = await createSavingsGoal(
      name: 'Viaje',
      targetAmount: _target,
      colorValue: _color,
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => repository.create(
        name: 'Viaje',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    ).called(1);
  });

  test('should fail when the name is empty', () async {
    final result = await createSavingsGoal(
      name: '   ',
      targetAmount: _target,
      colorValue: _color,
    );

    expect(result.failureOrNull, _hasField('name.empty'));
    verifyNeverCreated();
  });

  test('should fail when the name is longer than 60 characters', () async {
    final result = await createSavingsGoal(
      name: 'a' * 61,
      targetAmount: _target,
      colorValue: _color,
    );

    expect(result.failureOrNull, _hasField('name.tooLong'));
    verifyNeverCreated();
  });

  test('should fail when the target amount is not positive', () async {
    final result = await createSavingsGoal(
      name: 'Comprar un auto',
      targetAmount: Money.zero,
      colorValue: _color,
    );

    expect(result.failureOrNull, _hasField('targetAmount.notPositive'));
    verifyNeverCreated();
  });

  test('should fail when the saved amount is negative', () async {
    final result = await createSavingsGoal(
      name: 'Comprar un auto',
      targetAmount: _target,
      currentAmount: const Money.fromCents(-1),
      colorValue: _color,
    );

    expect(result.failureOrNull, _hasField('currentAmount.negative'));
    verifyNeverCreated();
  });

  test('should fail when the saved amount exceeds the target', () async {
    final result = await createSavingsGoal(
      name: 'Comprar un auto',
      targetAmount: _target,
      currentAmount: const Money.fromCents(1500000001),
      colorValue: _color,
    );

    expect(result.failureOrNull, _hasField('currentAmount.exceedsTarget'));
    verifyNeverCreated();
  });

  test('should return the repository failure when the insert fails', () async {
    const failure = DatabaseFailure(message: 'insert failed');
    when(
      () => repository.create(
        name: 'Comprar un auto',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    ).thenAnswer((_) async => const Err(failure));

    final result = await createSavingsGoal(
      name: 'Comprar un auto',
      targetAmount: _target,
      colorValue: _color,
    );

    expect(result.failureOrNull, same(failure));
  });
}
