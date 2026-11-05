import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/categories/data/daos/category_dao.dart';
import 'package:rumbo/features/categories/data/mappers/category_mapper.dart';
import 'package:rumbo/features/categories/data/tables/categories_table.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';

/// Drift-backed implementation of [CategoryRepository].
final class DriftCategoryRepository implements CategoryRepository {
  const DriftCategoryRepository(this._dao);

  final CategoryDao _dao;

  @override
  Stream<List<Category>> watchActive() => _dao.watchActive().map(
    (rows) => rows.map(CategoryMapper.toDomain).toList(growable: false),
  );

  @override
  Stream<List<Category>> watchArchived() => _dao.watchArchived().map(
    (rows) => rows.map(CategoryMapper.toDomain).toList(growable: false),
  );

  @override
  Future<Result<Category>> getById(int id) => _run(() => _dao.getById(id));

  @override
  Future<Result<Category>> create({
    required String name,
    required int colorValue,
  }) => _run(
    () => _dao.insertCategory(
      name: name,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    ),
  );

  @override
  Future<Result<Category>> update({
    required int id,
    required String name,
    required int colorValue,
  }) => _run(
    () => _dao.updateCategory(id: id, name: name, colorValue: colorValue),
  );

  @override
  Future<Result<Category>> archive(int id) =>
      _run(() => _dao.setArchivedAt(id, DateTime.now()));

  @override
  Future<Result<Category>> restore(int id) =>
      _run(() => _dao.setArchivedAt(id, null));

  Future<Result<Category>> _run(Future<CategoryRow?> Function() action) async {
    try {
      final row = await action();
      if (row == null) {
        return const Err(NotFoundFailure(resource: 'Category'));
      }
      return Success(CategoryMapper.toDomain(row));
    } on Exception catch (error) {
      return Err(DatabaseFailure(cause: error));
    }
  }
}
