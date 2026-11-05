import 'package:rumbo/features/income_sources/data/tables/income_sources_table.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';

/// Translates drift rows into domain entities so no drift type leaves `data/`.
abstract final class IncomeSourceMapper {
  static IncomeSource toDomain(IncomeSourceRow row) => IncomeSource(
    id: row.id,
    name: row.name,
    colorValue: row.colorValue,
    archivedAt: row.archivedAt,
    createdAt: row.createdAt,
  );
}
