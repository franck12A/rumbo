import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/usecases/update_savings_goal.dart';

class _MockSavingsGoalRepository extends Mock implements SavingsGoalRepository;

const _target = Money.fromCents(1500000000);
const _color = 0xFF1565C0;

SavingsGoal _goal({String name = 'Comprar un auto', Money? currentAmount}) =>
    SavingsGoal(
      id: 1,
      name: name,
      targetAmount: _target,
      currentAmount: currentAmount ?? Money.zero,
      colorValue: _color,
      createdAt: DateTime.utc(2026, 11, 6),
      updatedAt: DateTime.utc(2026, 11, 6),
    );

Matcher _hasField(String field) =>
    isA<ValidationFailure>().having((failure) => failure.field, 'field', field);

void main() {
  late _MockSavingsGoalRepository repository;
  late UpdateSavingsGoal updateSavingsGoal;

  setUp(() {
    repository = _MockSavingsGoalRepository();
    updateSavingsGoal = UpdateSavingsGoal(repository);
  });

  test('should update the goal when the input is valid', () async {
    when(() => repository.getById(1)).thenAnswer((_) async => Success(_goal()));
    when(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto usado',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    ).thenAnswer((_) async => Success(_goal(name: 'Comprar un auto usado')));

    final result = await updateSavingsGoal(
      id: 1,
      name: '  Comprar un auto usado  ',
      targetAmount: _target,
      currentAmount: Money.zero,
      colorValue: _color,
    );

    expect(result.valueOrNull?.name, 'Comprar un auto usado');
    verify(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto usado',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    ).called(1);
  });

  test('should clear a blank description when updating', () async {
    when(() => repository.getById(1)).thenAnswer((_) async => Success(_goal()));
    when(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    ).thenAnswer((_) async => Success(_goal()));

    await updateSavingsGoal(
      id: 1,
      name: 'Comprar un auto',
      description: '   ',
      targetAmount: _target,
      currentAmount: Money.zero,
      colorValue: _color,
    );

    verify(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    ).called(1);
  });

  test('should fail validation before reading the goal', () async {
    final result = await updateSavingsGoal(
      id: 1,
      name: '  ',
      targetAmount: _target,
      currentAmount: Money.zero,
      colorValue: _color,
    );

    expect(result.failureOrNull, _hasField('name.empty'));
    verifyNever(() => repository.getById(1));
  });

  test(
    'should return the not found failure when the goal does not exist',
    () async {
      when(() => repository.getById(9)).thenAnswer(
        (_) async => const Err(NotFoundFailure(resource: 'SavingsGoal')),
      );

      final result = await updateSavingsGoal(
        id: 9,
        name: 'Comprar un auto',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      );

      expect(result.failureOrNull, isA<NotFoundFailure>());
      verifyNever(
        () => repository.update(
          id: 9,
          name: 'Comprar un auto',
          targetAmount: _target,
          currentAmount: Money.zero,
          colorValue: _color,
        ),
      );
    },
  );

  test('should return the repository failure when the update fails', () async {
    const failure = DatabaseFailure(message: 'update failed');
    when(() => repository.getById(1)).thenAnswer((_) async => Success(_goal()));
    when(
      () => repository.update(
        id: 1,
        name: 'Comprar un auto',
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      ),
    ).thenAnswer((_) async => const Err(failure));

    final result = await updateSavingsGoal(
      id: 1,
      name: 'Comprar un auto',
      targetAmount: _target,
      currentAmount: Money.zero,
      colorValue: _color,
    );

    expect(result.failureOrNull, same(failure));
  });
}
