import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/categories/domain/services/category_name_rules.dart';

/// Renames and recolors an existing category.
final class UpdateCategory {
  const UpdateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Result<Category>> call({
    required int id,
    required String name,
    required int colorValue,
  }) async {
    final normalizedName = CategoryNameRules.normalize(name);
    final validation = CategoryNameRules.validate(normalizedName);
    if (validation != null) {
      return Err(validation);
    }

    final activeCategories = await _repository.watchActive().first;
    // The category being edited keeps its own name, so it must be excluded.
    final alreadyExists = activeCategories.any(
      (category) =>
          category.id != id &&
          CategoryNameRules.hasSameName(category.name, normalizedName),
    );
    if (alreadyExists) {
      return const Err(
        ValidationFailure(
          field: 'name.duplicate',
          message: 'An active category already uses that name',
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
