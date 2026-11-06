import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/savings_goals/data/daos/savings_goal_dao.dart';
import 'package:rumbo/features/savings_goals/data/mappers/savings_goal_mapper.dart';
import 'package:rumbo/features/savings_goals/data/tables/savings_goals_table.dart';
import 'package:rumbo/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:rumbo/features/savings_goals/domain/repositories/savings_goal_repository.dart';

/// Drift-backed implementation of [SavingsGoalRepository].
final class DriftSavingsGoalRepository implements SavingsGoalRepository {
  const DriftSavingsGoalRepository(this._dao);

  final SavingsGoalDao _dao;

  @override
  Stream<List<SavingsGoal>> watchAll() => _dao.watchAll().map(
    (rows) => rows.map(SavingsGoalMapper.toDomain).toList(growable: false),
  );

  @override
  Future<Result<SavingsGoal>> getById(int id) => _run(() => _dao.getById(id));

  @override
  Future<Result<SavingsGoal>> create({
    required String name,
    required Money targetAmount,
    required Money currentAmount,
    required int colorValue,
    String? description,
    CalendarDate? targetDate,
  }) {
    final now = DateTime.now().toUtc();
    return _run(
      () => _dao.insertGoal(
        name: name,
        description: description,
        targetAmountCents: targetAmount.cents,
        currentAmountCents: currentAmount.cents,
        targetDate: targetDate?.value,
        colorValue: colorValue,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<Result<SavingsGoal>> update({
    required int id,
    required String name,
    required Money targetAmount,
    required Money currentAmount,
    required int colorValue,
    String? description,
    CalendarDate? targetDate,
  }) => _run(
    () => _dao.updateGoal(
      id: id,
      name: name,
      description: description,
      targetAmountCents: targetAmount.cents,
      currentAmountCents: currentAmount.cents,
      targetDate: targetDate?.value,
      colorValue: colorValue,
      updatedAt: DateTime.now().toUtc(),
    ),
  );

  @override
  Future<Result<SavingsGoal>> delete(int id) => _run(() => _dao.deleteById(id));

  Future<Result<SavingsGoal>> _run(
    Future<SavingsGoalRow?> Function() action,
  ) async {
    try {
      final row = await action();
      if (row == null) {
        return const Err(NotFoundFailure(resource: 'SavingsGoal'));
      }
      return Success(SavingsGoalMapper.toDomain(row));
    } on Exception catch (error) {
      return Err(DatabaseFailure(cause: error));
    }
  }
}
