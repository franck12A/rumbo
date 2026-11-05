import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/features/categories/data/daos/category_dao.dart';

const _color = 0xFF6A1B9A;
final _createdAt = DateTime(2026);

void main() {
  late AppDatabase database;
  late CategoryDao dao;

  setUp(() async {
    database = AppDatabase.memory();
    dao = database.categoryDao;
    // The database seeds default categories on create; these tests start clean.
    await database.delete(database.categories).go();
  });

  tearDown(() => database.close());

  test('should return the stored category when getting it by id', () async {
    final inserted = await dao.insertCategory(
      name: 'Materiales',
      colorValue: _color,
      createdAt: _createdAt,
    );

    final found = await dao.getById(inserted.id);

    expect(found?.name, 'Materiales');
    expect(found?.colorValue, _color);
    expect(found?.archivedAt, isNull);
  });

  test('should keep active categories sorted by name ignoring case', () async {
    await dao.insertCategory(
      name: 'zeta',
      colorValue: _color,
      createdAt: _createdAt,
    );
    await dao.insertCategory(
      name: 'Alfa',
      colorValue: _color,
      createdAt: _createdAt,
    );
    await dao.insertCategory(
      name: 'beta',
      colorValue: _color,
      createdAt: _createdAt,
    );

    final active = await dao.watchActive().first;

    expect(active.map((row) => row.name), ['Alfa', 'beta', 'zeta']);
  });

  test('should list only archived categories in the archived stream', () async {
    final active = await dao.insertCategory(
      name: 'Materiales',
      colorValue: _color,
      createdAt: _createdAt,
    );
    final archived = await dao.insertCategory(
      name: 'Viejos',
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
      final inserted = await dao.insertCategory(
        name: 'Materiales',
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

  test('should update name and color when the category exists', () async {
    final inserted = await dao.insertCategory(
      name: 'Materiales',
      colorValue: _color,
      createdAt: _createdAt,
    );

    final updated = await dao.updateCategory(
      id: inserted.id,
      name: 'Insumos',
      colorValue: 0xFF1565C0,
    );

    expect(updated?.name, 'Insumos');
    expect(updated?.colorValue, 0xFF1565C0);
  });

  test('should return null when the id does not exist', () async {
    expect(
      await dao.updateCategory(id: 99, name: 'Insumos', colorValue: _color),
      isNull,
    );
    expect(await dao.setArchivedAt(99, DateTime(2026, 2)), isNull);
  });
}
