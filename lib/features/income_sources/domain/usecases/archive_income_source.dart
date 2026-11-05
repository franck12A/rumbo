import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';

/// Marks an income source as archived without deleting its history.
final class ArchiveIncomeSource {
  const ArchiveIncomeSource(this._repository);

  final IncomeSourceRepository _repository;

  Future<Result<IncomeSource>> call(int id) => _repository.archive(id);
}
