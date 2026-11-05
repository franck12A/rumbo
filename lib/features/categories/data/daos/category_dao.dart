import 'package:drift/drift.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/features/categories/data/tables/categories_table.dart';

part 'category_dao.g.dart';

/// SQL access for the categories table. Only `data/` may use it.
@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.attachedDatabase);

  Stream<List<CategoryRow>> watchActive() {
    final query = select(categories)
      ..where((category) => category.archivedAt.isNull())
      ..orderBy([(category) => OrderingTerm.asc(category.name.lower())]);
    return query.watch();
  }

  Stream<List<CategoryRow>> watchArchived() {
    final query = select(categories)
      ..where((category) => category.archivedAt.isNotNull())
      ..orderBy([(category) => OrderingTerm.asc(category.name.lower())]);
    return query.watch();
  }

  Future<CategoryRow?> getById(int id) {
    final query = select(categories)
      ..where((category) => category.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<CategoryRow> insertCategory({
    required String name,
    required int colorValue,
    required DateTime createdAt,
  }) async {
    final id = await into(categories).insert(
      CategoriesCompanion.insert(
        name: name,
        colorValue: colorValue,
        createdAt: createdAt,
      ),
    );
    final row = await getById(id);
    // The id was just inserted, so the row must be there.
    return row!;
  }

  Future<CategoryRow?> updateCategory({
    required int id,
    required String name,
    required int colorValue,
  }) async {
    final updated =
        await (update(
          categories,
        )..where((category) => category.id.equals(id))).write(
          CategoriesCompanion(name: Value(name), colorValue: Value(colorValue)),
        );
    if (updated == 0) {
      return null;
    }
    return await getById(id);
  }

  Future<CategoryRow?> setArchivedAt(int id, DateTime? archivedAt) async {
    final updated =
        await (update(categories)..where((category) => category.id.equals(id)))
            .write(CategoriesCompanion(archivedAt: Value(archivedAt)));
    if (updated == 0) {
      return null;
    }
    return await getById(id);
  }
}
