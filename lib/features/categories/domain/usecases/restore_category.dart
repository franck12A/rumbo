import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/categories/domain/services/category_name_rules.dart';

/// Brings an archived category back to the active list.
///
/// Restoring is rejected when an active category already uses the same name,
/// so the active list never ends up with duplicates.
final class RestoreCategory {
  const RestoreCategory(this._repository);

  final CategoryRepository _repository;

  Future<Result<Category>> call(int id) async {
    final found = await _repository.getById(id);
    switch (found) {
      case Err(:final failure):
        return Err(failure);
      case Success(:final value):
        final activeCategories = await _repository.watchActive().first;
        final alreadyInUse = activeCategories.any(
          (category) =>
              category.id != value.id &&
              CategoryNameRules.hasSameName(category.name, value.name),
        );
        if (alreadyInUse) {
          return const Err(
            ValidationFailure(
              field: 'name.duplicate',
              message: 'An active category already uses that name',
            ),
          );
        }
        return await _repository.restore(id);
    }
  }
}
