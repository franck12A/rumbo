import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rumbo/core/database/app_database.dart';

/// Schema the app shipped before income sources existed: only the pragma.
class _SchemaV1Database extends GeneratedDatabase {
  _SchemaV1Database(super.executor);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy();
}

Future<File> _createVersion1File(Directory directory) async {
  final file = File(p.join(directory.path, 'rumbo.sqlite'));
  final legacy = _SchemaV1Database(NativeDatabase(file));
  await legacy.customStatement('PRAGMA user_version = 1');
  await legacy.close();
  return file;
}

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('rumbo_migration');
  });

  tearDown(() => directory.delete(recursive: true));

  test(
    'should upgrade a version 1 database and seed the default sources',
    () async {
      final file = await _createVersion1File(directory);

      final database = AppDatabase.file(file);
      addTearDown(database.close);

      final rows = await database.select(database.incomeSources).get();
      final version = await database
          .customSelect('PRAGMA user_version')
          .getSingle();

      expect(rows, hasLength(2));
      expect(
        rows.map((row) => row.name),
        containsAll(<String>['Reparación de pelotas', 'Restaurante']),
      );
      expect(version.read<int>('user_version'), 2);
    },
  );

  test(
    'should not seed again when the upgraded database is reopened',
    () async {
      final file = await _createVersion1File(directory);

      final upgraded = AppDatabase.file(file);
      await upgraded.customSelect('SELECT 1').getSingle();
      await upgraded.close();

      final reopened = AppDatabase.file(file);
      addTearDown(reopened.close);

      final rows = await reopened.select(reopened.incomeSources).get();

      expect(rows, hasLength(2));
    },
  );
}
