import 'package:rumbo/features/categories/data/tables/categories_table.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';

/// Translates drift rows into domain entities so no drift type leaves `data/`.
abstract final class CategoryMapper {
  static Category toDomain(CategoryRow row) => Category(
    id: row.id,
    name: row.name,
    colorValue: row.colorValue,
    archivedAt: row.archivedAt,
    createdAt: row.createdAt,
  );
}
