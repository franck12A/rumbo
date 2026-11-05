import 'package:drift/drift.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/features/income_sources/data/tables/income_sources_table.dart';

part 'income_source_dao.g.dart';

/// SQL access for the income sources table. Only `data/` may use it.
@DriftAccessor(tables: [IncomeSources])
class IncomeSourceDao extends DatabaseAccessor<AppDatabase>
    with _$IncomeSourceDaoMixin {
  IncomeSourceDao(super.attachedDatabase);

  Stream<List<IncomeSourceRow>> watchActive() {
    final query = select(incomeSources)
      ..where((source) => source.archivedAt.isNull())
      ..orderBy([(source) => OrderingTerm.asc(source.name.lower())]);
    return query.watch();
  }

  Stream<List<IncomeSourceRow>> watchArchived() {
    final query = select(incomeSources)
      ..where((source) => source.archivedAt.isNotNull())
      ..orderBy([(source) => OrderingTerm.asc(source.name.lower())]);
    return query.watch();
  }

  Future<List<IncomeSourceRow>> getActive() {
    final query = select(incomeSources)
      ..where((source) => source.archivedAt.isNull())
      ..orderBy([(source) => OrderingTerm.asc(source.name.lower())]);
    return query.get();
  }

  Future<IncomeSourceRow?> getById(int id) {
    final query = select(incomeSources)
      ..where((source) => source.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<IncomeSourceRow> insertSource({
    required String name,
    required int colorValue,
    required DateTime createdAt,
  }) async {
    final id = await into(incomeSources).insert(
      IncomeSourcesCompanion.insert(
        name: name,
        colorValue: colorValue,
        createdAt: createdAt,
      ),
    );
    final row = await getById(id);
    // The id was just inserted, so the row must be there.
    return row!;
  }

  Future<IncomeSourceRow?> updateSource({
    required int id,
    required String name,
    required int colorValue,
  }) async {
    final updated =
        await (update(
          incomeSources,
        )..where((source) => source.id.equals(id))).write(
          IncomeSourcesCompanion(
            name: Value(name),
            colorValue: Value(colorValue),
          ),
        );
    if (updated == 0) {
      return null;
    }
    return await getById(id);
  }

  Future<IncomeSourceRow?> setArchivedAt(int id, DateTime? archivedAt) async {
    final updated =
        await (update(incomeSources)..where((source) => source.id.equals(id)))
            .write(IncomeSourcesCompanion(archivedAt: Value(archivedAt)));
    if (updated == 0) {
      return null;
    }
    return await getById(id);
  }
}
