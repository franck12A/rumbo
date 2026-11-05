import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';

/// Persistence boundary for categories, implemented in `data/`.
abstract interface class CategoryRepository {
  /// Emits the active categories, ordered by name, every time they change.
  Stream<List<Category>> watchActive();

  /// Emits the archived categories, ordered by name, every time they change.
  Stream<List<Category>> watchArchived();

  Future<Result<Category>> getById(int id);

  Future<Result<Category>> create({
    required String name,
    required int colorValue,
  });

  Future<Result<Category>> update({
    required int id,
    required String name,
    required int colorValue,
  });

  Future<Result<Category>> archive(int id);

  Future<Result<Category>> restore(int id);
}
