import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/categories/domain/services/category_name_rules.dart';

/// Creates an active category once the name rules pass.
final class CreateCategory {
  const CreateCategory(this._repository);

  final CategoryRepository _repository;

  Future<Result<Category>> call({
    required String name,
    required int colorValue,
  }) async {
    final normalizedName = CategoryNameRules.normalize(name);
    final validation = CategoryNameRules.validate(normalizedName);
    if (validation != null) {
      return Err(validation);
    }

    final activeCategories = await _repository.watchActive().first;
    final alreadyExists = activeCategories.any(
      (category) =>
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

    return await _repository.create(
      name: normalizedName,
      colorValue: colorValue,
    );
  }
}
