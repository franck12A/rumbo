import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rumbo/core/database/app_database.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/features/income_sources/data/repositories/drift_income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';

const _color = 0xFFEF6C00;

void main() {
  late AppDatabase database;
  late DriftIncomeSourceRepository repository;

  setUp(() async {
    database = AppDatabase.memory();
    repository = DriftIncomeSourceRepository(database.incomeSourceDao);
    // The database seeds default sources on create; these tests start clean.
    await database.delete(database.incomeSources).go();
  });

  tearDown(() => database.close());

  test('should store the source when creating it', () async {
    final result = await repository.create(
      name: 'Restaurante',
      colorValue: _color,
    );

    final created = result.valueOrNull;
    expect(created, isA<IncomeSource>());
    expect(created?.name, 'Restaurante');
    expect(created?.colorValue, _color);
    expect(created?.isArchived, isFalse);
    expect(await repository.getById(created!.id), isNotNull);
  });

  test(
    'should stream domain entities when watching the active sources',
    () async {
      await repository.create(name: 'Restaurante', colorValue: _color);

      final sources = await repository.watchActive().first;

      expect(sources, hasLength(1));
      expect(sources.single, isA<IncomeSource>());
      expect(sources.single.name, 'Restaurante');
    },
  );

  test(
    'should return a not found failure when the id does not exist',
    () async {
      final result = await repository.getById(99);

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );

  test('should update name and color when the source exists', () async {
    final created = (await repository.create(
      name: 'Restaurante',
      colorValue: _color,
    )).valueOrNull!;

    final result = await repository.update(
      id: created.id,
      name: 'Bar',
      colorValue: 0xFF1565C0,
    );

    expect(result.valueOrNull?.name, 'Bar');
    expect(result.valueOrNull?.colorValue, 0xFF1565C0);
  });

  test('should archive and restore when the source exists', () async {
    final created = (await repository.create(
      name: 'Restaurante',
      colorValue: _color,
    )).valueOrNull!;

    final archived = await repository.archive(created.id);
    expect(archived.valueOrNull?.isArchived, isTrue);

    final restored = await repository.restore(created.id);
    expect(restored.valueOrNull?.isArchived, isFalse);
  });

  test(
    'should return a not found failure when archiving a missing source',
    () async {
      final result = await repository.archive(99);

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );

  test('should keep a created source when the database is reopened', () async {
    final directory = await Directory.systemTemp.createTemp('rumbo_persist');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(p.join(directory.path, 'rumbo.sqlite'));

    final first = AppDatabase.file(file);
    final created = await DriftIncomeSourceRepository(first.incomeSourceDao)
        .create(name: 'Restaurante', colorValue: _color);
    expect(created.isSuccess, isTrue);
    await first.close();

    final reopened = AppDatabase.file(file);
    addTearDown(reopened.close);
    final sources = await DriftIncomeSourceRepository(reopened.incomeSourceDao)
        .watchActive()
        .first;

    expect(sources.map((source) => source.name), contains('Restaurante'));
  });
}
