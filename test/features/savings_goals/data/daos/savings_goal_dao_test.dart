import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/features/savings_goals/data/daos/savings_goal_dao.dart';
import 'package:rumbo/features/savings_goals/data/tables/savings_goals_table.dart';

const _color = 0xFF1565C0;
final _now = DateTime.utc(2026, 11, 6, 12);

Matcher _constraintViolation() => throwsA(
  predicate<Object>(
    (error) => error.toString().toLowerCase().contains('constraint'),
  ),
);

void main() {
  late AppDatabase database;
  late SavingsGoalDao dao;

  setUp(() {
    database = AppDatabase.memory();
    dao = database.savingsGoalDao;
  });

  tearDown(() => database.close());

  Future<SavingsGoalRow> insertGoal({
    String name = 'Comprar un auto',
    int targetAmountCents = 1500000000,
    int currentAmountCents = 0,
    int? targetDate = 20271231,
    DateTime? createdAt,
  }) => dao.insertGoal(
    name: name,
    description: null,
    targetAmountCents: targetAmountCents,
    currentAmountCents: currentAmountCents,
    targetDate: targetDate,
    colorValue: _color,
    createdAt: createdAt ?? _now,
    updatedAt: createdAt ?? _now,
  );

  test('should store and read a savings goal', () async {
    final inserted = await insertGoal();

    final found = await dao.getById(inserted.id);

    expect(found?.name, 'Comprar un auto');
    expect(found?.targetAmountCents, 1500000000);
    expect(found?.currentAmountCents, 0);
    expect(found?.targetDate, 20271231);
    expect(found?.colorValue, _color);
    expect(found?.createdAt, isNotNull);
  });

  test('should list the goals newest first', () async {
    await insertGoal(name: 'Vieja', createdAt: DateTime.utc(2026));
    await insertGoal(name: 'Nueva', createdAt: DateTime.utc(2026, 11, 6));

    final rows = await dao.watchAll().first;

    expect(rows.map((row) => row.name), ['Nueva', 'Vieja']);
  });

  test('should update every editable field when the goal exists', () async {
    final inserted = await insertGoal();
    final updatedAt = DateTime.utc(2026, 11, 7, 9);

    final updated = await dao.updateGoal(
      id: inserted.id,
      name: 'Comprar un auto usado',
      description: 'Ahorro',
      targetAmountCents: 2000000000,
      currentAmountCents: 500000000,
      targetDate: null,
      colorValue: 0xFF2E7D32,
      updatedAt: updatedAt,
    );

    expect(updated?.name, 'Comprar un auto usado');
    expect(updated?.description, 'Ahorro');
    expect(updated?.targetAmountCents, 2000000000);
    expect(updated?.currentAmountCents, 500000000);
    expect(updated?.targetDate, isNull);
    expect(updated?.colorValue, 0xFF2E7D32);
    expect(updated?.updatedAt.isAtSameMomentAs(updatedAt), isTrue);
  });

  test('should delete and return the goal', () async {
    final inserted = await insertGoal();

    final deleted = await dao.deleteById(inserted.id);

    expect(deleted?.id, inserted.id);
    expect(await dao.getById(inserted.id), isNull);
    expect(await dao.deleteById(inserted.id), isNull);
  });

  test('should reject a non positive target amount', () async {
    await expectLater(
      database
          .into(database.savingsGoals)
          .insert(
            SavingsGoalsCompanion.insert(
              name: 'Auto',
              targetAmountCents: 0,
              currentAmountCents: 0,
              colorValue: _color,
              createdAt: _now,
              updatedAt: _now,
            ),
          ),
      _constraintViolation(),
    );
    await expectLater(
      database
          .into(database.savingsGoals)
          .insert(
            SavingsGoalsCompanion.insert(
              name: 'Auto',
              targetAmountCents: -100,
              currentAmountCents: 0,
              colorValue: _color,
              createdAt: _now,
              updatedAt: _now,
            ),
          ),
      _constraintViolation(),
    );
  });

  test('should reject a negative saved amount', () async {
    await expectLater(
      database
          .into(database.savingsGoals)
          .insert(
            SavingsGoalsCompanion.insert(
              name: 'Auto',
              targetAmountCents: 1500000000,
              currentAmountCents: -1,
              colorValue: _color,
              createdAt: _now,
              updatedAt: _now,
            ),
          ),
      _constraintViolation(),
    );
  });

  test('should reject a saved amount larger than the target', () async {
    await expectLater(
      database
          .into(database.savingsGoals)
          .insert(
            SavingsGoalsCompanion.insert(
              name: 'Auto',
              targetAmountCents: 1500000000,
              currentAmountCents: 1500000001,
              colorValue: _color,
              createdAt: _now,
              updatedAt: _now,
            ),
          ),
      _constraintViolation(),
    );
  });

  test('should reject an empty name', () async {
    await expectLater(
      database
          .into(database.savingsGoals)
          .insert(
            SavingsGoalsCompanion.insert(
              name: '',
              targetAmountCents: 1500000000,
              currentAmountCents: 0,
              colorValue: _color,
              createdAt: _now,
              updatedAt: _now,
            ),
          ),
      _constraintViolation(),
    );
  });
}
