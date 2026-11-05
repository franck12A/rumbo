import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/services/income_source_name_rules.dart';

/// Renames and recolors an existing income source.
final class UpdateIncomeSource {
  const UpdateIncomeSource(this._repository);

  final IncomeSourceRepository _repository;

  Future<Result<IncomeSource>> call({
    required int id,
    required String name,
    required int colorValue,
  }) async {
    final normalizedName = IncomeSourceNameRules.normalize(name);
    final validation = IncomeSourceNameRules.validate(normalizedName);
    if (validation != null) {
      return Err(validation);
    }

    final activeSources = await _repository.watchActive().first;
    // The source being edited keeps its own name, so it must be excluded here.
    final alreadyExists = activeSources.any(
      (source) =>
          source.id != id &&
          IncomeSourceNameRules.hasSameName(source.name, normalizedName),
    );
    if (alreadyExists) {
      return const Err(
        ValidationFailure(
          field: 'name.duplicate',
          message: 'An active income source already uses that name',
        ),
      );
    }

    return await _repository.update(
      id: id,
      name: normalizedName,
      colorValue: colorValue,
    );
  }
}
