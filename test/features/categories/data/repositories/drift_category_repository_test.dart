import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/features/categories/data/repositories/drift_category_repository.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';

const _color = 0xFF6A1B9A;

void main() {
  late AppDatabase database;
  late DriftCategoryRepository repository;

  setUp(() async {
    database = AppDatabase.memory();
    repository = DriftCategoryRepository(database.categoryDao);
    // The database seeds default categories on create; these tests start clean.
    await database.delete(database.categories).go();
  });

  tearDown(() => database.close());

  test('should store the category when creating it', () async {
    final result = await repository.create(
      name: 'Materiales',
      colorValue: _color,
    );

    final created = result.valueOrNull;
    expect(created, isA<Category>());
    expect(created?.name, 'Materiales');
    expect(created?.colorValue, _color);
    expect(created?.isArchived, isFalse);
    expect(await repository.getById(created!.id), isNotNull);
  });

  test(
    'should stream domain entities when watching the active categories',
    () async {
      await repository.create(name: 'Materiales', colorValue: _color);

      final categories = await repository.watchActive().first;

      expect(categories, hasLength(1));
      expect(categories.single, isA<Category>());
      expect(categories.single.name, 'Materiales');
    },
  );

  test('should stream only archived categories when watching them', () async {
    final kept = (await repository.create(
      name: 'Materiales',
      colorValue: _color,
    )).valueOrNull!;
    final archived = (await repository.create(
      name: 'Viejos',
      colorValue: _color,
    )).valueOrNull!;
    await repository.archive(archived.id);

    final categories = await repository.watchArchived().first;

    expect(categories.map((category) => category.id), [archived.id]);
    expect(categories.map((category) => category.id), isNot(contains(kept.id)));
  });

  test(
    'should return a not found failure when the id does not exist',
    () async {
      final result = await repository.getById(99);

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );

  test('should update name and color when the category exists', () async {
    final created = (await repository.create(
      name: 'Materiales',
      colorValue: _color,
    )).valueOrNull!;

    final result = await repository.update(
      id: created.id,
      name: 'Insumos',
      colorValue: 0xFF1565C0,
    );

    expect(result.valueOrNull?.name, 'Insumos');
    expect(result.valueOrNull?.colorValue, 0xFF1565C0);
  });

  test('should archive and restore when the category exists', () async {
    final created = (await repository.create(
      name: 'Materiales',
      colorValue: _color,
    )).valueOrNull!;

    final archived = await repository.archive(created.id);
    expect(archived.valueOrNull?.isArchived, isTrue);

    final restored = await repository.restore(created.id);
    expect(restored.valueOrNull?.isArchived, isFalse);
  });

  test(
    'should return a not found failure when archiving a missing category',
    () async {
      final result = await repository.archive(99);

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );
}
