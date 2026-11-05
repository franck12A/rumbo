import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/services/income_source_name_rules.dart';

/// Brings an archived income source back to the active list.
///
/// Restoring is rejected when an active source already uses the same name, so
/// the active list never ends up with duplicates.
final class RestoreIncomeSource {
  const RestoreIncomeSource(this._repository);

  final IncomeSourceRepository _repository;

  Future<Result<IncomeSource>> call(int id) async {
    final found = await _repository.getById(id);
    switch (found) {
      case Err(:final failure):
        return Err(failure);
      case Success(:final value):
        final activeSources = await _repository.watchActive().first;
        final alreadyInUse = activeSources.any(
          (source) =>
              source.id != value.id &&
              IncomeSourceNameRules.hasSameName(source.name, value.name),
        );
        if (alreadyInUse) {
          return const Err(
            ValidationFailure(
              field: 'name.duplicate',
              message: 'An active income source already uses that name',
            ),
          );
        }
        return await _repository.restore(id);
    }
  }
}
