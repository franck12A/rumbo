import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';

/// Marks a category as archived without deleting its history.
final class ArchiveCategory {
  const ArchiveCategory(this._repository);

  final CategoryRepository _repository;

  Future<Result<Category>> call(int id) => _repository.archive(id);
}
