import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';

/// Brings an archived income source back to the active list.
final class RestoreIncomeSource {
  const RestoreIncomeSource(this._repository);

  final IncomeSourceRepository _repository;

  Future<Result<IncomeSource>> call(int id) => _repository.restore(id);
}
