import 'package:drift/drift.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/features/savings_goals/data/tables/savings_goals_table.dart';

part 'savings_goal_dao.g.dart';

/// SQL access for the savings goals table. Only `data/` may use it.
@DriftAccessor(tables: [SavingsGoals])
class SavingsGoalDao extends DatabaseAccessor<AppDatabase>
    with _$SavingsGoalDaoMixin {
  SavingsGoalDao(super.attachedDatabase);

  Stream<List<SavingsGoalRow>> watchAll() {
    final query = select(savingsGoals)
      ..orderBy([
        (goal) => OrderingTerm.desc(goal.createdAt),
        (goal) => OrderingTerm.desc(goal.id),
      ]);
    return query.watch();
  }

  Future<SavingsGoalRow?> getById(int id) {
    final query = select(savingsGoals)..where((goal) => goal.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<SavingsGoalRow> insertGoal({
    required String name,
    required String? description,
    required int targetAmountCents,
    required int currentAmountCents,
    required int? targetDate,
    required int colorValue,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    final id = await into(savingsGoals).insert(
      SavingsGoalsCompanion.insert(
        name: name,
        description: Value(description),
        targetAmountCents: targetAmountCents,
        currentAmountCents: currentAmountCents,
        targetDate: Value(targetDate),
        colorValue: colorValue,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
    final row = await getById(id);
    // The id was just inserted, so the row must be there.
    return row!;
  }

  Future<SavingsGoalRow?> updateGoal({
    required int id,
    required String name,
    required String? description,
    required int targetAmountCents,
    required int currentAmountCents,
    required int? targetDate,
    required int colorValue,
    required DateTime updatedAt,
  }) async {
    final updated =
        await (update(savingsGoals)..where((goal) => goal.id.equals(id))).write(
          SavingsGoalsCompanion(
            name: Value(name),
            description: Value(description),
            targetAmountCents: Value(targetAmountCents),
            currentAmountCents: Value(currentAmountCents),
            targetDate: Value(targetDate),
            colorValue: Value(colorValue),
            updatedAt: Value(updatedAt),
          ),
        );
    if (updated == 0) {
      return null;
    }
    return await getById(id);
  }

  /// Deletes the row and returns it, or `null` when it did not exist.
  Future<SavingsGoalRow?> deleteById(int id) async {
    final row = await getById(id);
    if (row == null) {
      return null;
    }
    await (delete(savingsGoals)..where((goal) => goal.id.equals(id))).go();
    return row;
  }
}
