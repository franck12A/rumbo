import 'package:drift/drift.dart';

/// Drift table behind the categories feature.
///
/// [CategoryRow] is declared here instead of letting drift generate one, so
/// `data/` owns the row type and mappers can live in separate files.
@TableIndex(name: 'categories_archived_at', columns: {#archivedAt})
@UseRowClass(CategoryRow)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 40)();

  IntColumn get colorValue => integer()();

  DateTimeColumn get archivedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}

/// One stored category, exactly as drift reads it.
class CategoryRow {
  const CategoryRow({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.archivedAt,
    required this.createdAt,
  });

  final int id;
  final String name;
  final int colorValue;
  final DateTime? archivedAt;
  final DateTime createdAt;
}
