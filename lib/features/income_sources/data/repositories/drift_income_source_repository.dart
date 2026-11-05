import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/data/daos/income_source_dao.dart';
import 'package:rumbo/features/income_sources/data/mappers/income_source_mapper.dart';
import 'package:rumbo/features/income_sources/data/tables/income_sources_table.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';

/// Drift-backed implementation of [IncomeSourceRepository].
final class DriftIncomeSourceRepository implements IncomeSourceRepository {
  const DriftIncomeSourceRepository(this._dao);

  final IncomeSourceDao _dao;

  @override
  Stream<List<IncomeSource>> watchActive() => _dao.watchActive().map(
    (rows) => rows.map(IncomeSourceMapper.toDomain).toList(growable: false),
  );

  @override
  Future<Result<IncomeSource>> getById(int id) => _run(() => _dao.getById(id));

  @override
  Future<Result<IncomeSource>> create({
    required String name,
    required int colorValue,
  }) => _run(
    () => _dao.insertSource(
      name: name,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    ),
  );

  @override
  Future<Result<IncomeSource>> update({
    required int id,
    required String name,
    required int colorValue,
  }) =>
      _run(() => _dao.updateSource(id: id, name: name, colorValue: colorValue));

  @override
  Future<Result<IncomeSource>> archive(int id) =>
      _run(() => _dao.setArchivedAt(id, DateTime.now()));

  @override
  Future<Result<IncomeSource>> restore(int id) =>
      _run(() => _dao.setArchivedAt(id, null));

  Future<Result<IncomeSource>> _run(
    Future<IncomeSourceRow?> Function() action,
  ) async {
    try {
      final row = await action();
      if (row == null) {
        return const Err(NotFoundFailure(resource: 'IncomeSource'));
      }
      return Success(IncomeSourceMapper.toDomain(row));
    } on Exception catch (error) {
      return Err(DatabaseFailure(cause: error));
    }
  }
}
