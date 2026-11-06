import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/data/repositories/drift_savings_goal_repository.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';

const _color = 0xFF1565C0;
const _target = Money.fromCents(1500000000);
const _saved = Money.fromCents(250000000);
final _deadline = CalendarDate(year: 2027, month: 12, day: 31);

void main() {
  late AppDatabase database;
  late DriftSavingsGoalRepository repository;

  setUp(() {
    database = AppDatabase.memory();
    repository = DriftSavingsGoalRepository(database.savingsGoalDao);
  });

  tearDown(() => database.close());

  Future<SavingsGoal> createGoal({
    String name = 'Comprar un auto',
    CalendarDate? targetDate,
  }) async {
    final result = await repository.create(
      name: name,
      description: 'Ahorro',
      targetAmount: _target,
      currentAmount: _saved,
      targetDate: targetDate,
      colorValue: _color,
    );
    return result.valueOrNull!;
  }

  test('should store the amounts in cents and the date as yyyymmdd', () async {
    await createGoal(targetDate: _deadline);

    final row = await database.select(database.savingsGoals).getSingle();

    expect(row.targetAmountCents, 1500000000);
    expect(row.currentAmountCents, 250000000);
    expect(row.targetDate, 20271231);
  });

  test('should stream domain entities when watching the goals', () async {
    await createGoal(name: 'Primera');
    await createGoal(name: 'Segunda');

    final goals = await repository.watchAll().first;

    expect(goals, hasLength(2));
    expect(goals.first, isA<SavingsGoal>());
    expect(goals.map((goal) => goal.name), ['Segunda', 'Primera']);
    expect(goals.first.targetAmount, _target);
    expect(goals.first.currentAmount, _saved);
  });

  test('should keep a goal without deadline valid', () async {
    final created = await createGoal();

    expect(created.targetDate, isNull);
  });

  test('should update the saved amount and keep the deadline', () async {
    final created = await createGoal(targetDate: _deadline);

    final result = await repository.update(
      id: created.id,
      name: created.name,
      description: created.description,
      targetAmount: _target,
      currentAmount: const Money.fromCents(350000000),
      targetDate: created.targetDate,
      colorValue: created.colorValue,
    );

    expect(result.valueOrNull?.currentAmount.cents, 350000000);
    expect(result.valueOrNull?.targetDate?.value, 20271231);
  });

  test('should delete the goal when it exists', () async {
    final created = await createGoal();

    final deleted = await repository.delete(created.id);

    expect(deleted.valueOrNull?.id, created.id);
    expect(
      (await repository.getById(created.id)).failureOrNull,
      isA<NotFoundFailure>(),
    );
  });

  test(
    'should return a not found failure when the id does not exist',
    () async {
      final result = await repository.getById(99);

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );

  test(
    'should return a not found failure when updating a deleted goal',
    () async {
      final created = await createGoal();
      await repository.delete(created.id);

      final result = await repository.update(
        id: created.id,
        name: created.name,
        targetAmount: _target,
        currentAmount: Money.zero,
        colorValue: _color,
      );

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );

  test(
    'should return a database failure when a constraint rejects the row',
    () async {
      final result = await repository.create(
        name: 'Auto',
        targetAmount: _target,
        // The repository trusts the domain, so this reaches the CHECK.
        currentAmount: const Money.fromCents(1600000000),
        colorValue: _color,
      );

      expect(result.failureOrNull, isA<DatabaseFailure>());
    },
  );
}
