import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/features/income_sources/data/daos/income_source_dao.dart';

const _color = 0xFFEF6C00;
final _createdAt = DateTime(2026);

void main() {
  late AppDatabase database;
  late IncomeSourceDao dao;

  setUp(() async {
    database = AppDatabase.memory();
    dao = database.incomeSourceDao;
    // The database seeds default sources on create; these tests start clean.
    await database.delete(database.incomeSources).go();
  });

  tearDown(() => database.close());

  test('should return the stored source when getting it by id', () async {
    final inserted = await dao.insertSource(
      name: 'Restaurante',
      colorValue: _color,
      createdAt: _createdAt,
    );

    final found = await dao.getById(inserted.id);

    expect(found?.name, 'Restaurante');
    expect(found?.colorValue, _color);
    expect(found?.archivedAt, isNull);
  });

  test('should keep active sources sorted by name ignoring case', () async {
    await dao.insertSource(
      name: 'zeta',
      colorValue: _color,
      createdAt: _createdAt,
    );
    await dao.insertSource(
      name: 'Alfa',
      colorValue: _color,
      createdAt: _createdAt,
    );
    await dao.insertSource(
      name: 'beta',
      colorValue: _color,
      createdAt: _createdAt,
    );

    final active = await dao.getActive();

    expect(active.map((row) => row.name), ['Alfa', 'beta', 'zeta']);
  });

  test('should hide archived sources from the active stream', () async {
    final active = await dao.insertSource(
      name: 'Restaurante',
      colorValue: _color,
      createdAt: _createdAt,
    );
    final archived = await dao.insertSource(
      name: 'Pelotas',
      colorValue: _color,
      createdAt: _createdAt,
    );
    await dao.setArchivedAt(archived.id, DateTime(2026, 2));

    final rows = await dao.watchActive().first;

    expect(rows.map((row) => row.id), [active.id]);
  });

  test('should list only archived sources in the archived stream', () async {
    final active = await dao.insertSource(
      name: 'Restaurante',
      colorValue: _color,
      createdAt: _createdAt,
    );
    final archived = await dao.insertSource(
      name: 'Pelotas',
      colorValue: _color,
      createdAt: _createdAt,
    );
    await dao.setArchivedAt(archived.id, DateTime(2026, 2));

    final rows = await dao.watchArchived().first;

    expect(rows.map((row) => row.id), [archived.id]);
    expect(rows.map((row) => row.id), isNot(contains(active.id)));
  });

  test(
    'should set and clear archivedAt when archiving and restoring',
    () async {
      final inserted = await dao.insertSource(
        name: 'Restaurante',
        colorValue: _color,
        createdAt: _createdAt,
      );
      final archivedAt = DateTime(2026, 2);

      final archived = await dao.setArchivedAt(inserted.id, archivedAt);
      expect(archived?.archivedAt?.isAtSameMomentAs(archivedAt), isTrue);

      final restored = await dao.setArchivedAt(inserted.id, null);
      expect(restored?.archivedAt, isNull);
    },
  );

  test('should update name and color when the source exists', () async {
    final inserted = await dao.insertSource(
      name: 'Restaurante',
      colorValue: _color,
      createdAt: _createdAt,
    );

    final updated = await dao.updateSource(
      id: inserted.id,
      name: 'Bar',
      colorValue: 0xFF1565C0,
    );

    expect(updated?.name, 'Bar');
    expect(updated?.colorValue, 0xFF1565C0);
  });

  test('should return null when the id does not exist', () async {
    expect(
      await dao.updateSource(id: 99, name: 'Bar', colorValue: _color),
      isNull,
    );
    expect(await dao.setArchivedAt(99, DateTime(2026, 2)), isNull);
  });
}
