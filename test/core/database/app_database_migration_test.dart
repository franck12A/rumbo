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

File _databaseFile(Directory directory) =>
    File(p.join(directory.path, 'rumbo.sqlite'));

Future<File> _createVersion1File(Directory directory) async {
  final file = _databaseFile(directory);
  final legacy = _SchemaV1Database(NativeDatabase(file));
  await legacy.customStatement('PRAGMA user_version = 1');
  await legacy.close();
  return file;
}

/// Builds a version 2 file: income sources with an extra user row and no
/// categories table yet.
Future<File> _createVersion2File(Directory directory) async {
  final file = _databaseFile(directory);
  final current = AppDatabase.file(file);
  await current
      .into(current.incomeSources)
      .insert(
        IncomeSourcesCompanion.insert(
          name: 'Kiosco',
          colorValue: 0xFF1565C0,
          createdAt: DateTime(2026),
        ),
      );
  await current.customStatement('DROP TABLE transactions');
  await current.customStatement('DROP TABLE categories');
  await current.customStatement('DROP TABLE savings_goals');
  await current.customStatement('PRAGMA user_version = 2');
  await current.close();
  return file;
}

/// Builds a version 3 file: both existing features, an extra row in each and
/// no transactions table yet.
Future<File> _createVersion3File(Directory directory) async {
  final file = _databaseFile(directory);
  final current = AppDatabase.file(file);
  await current
      .into(current.incomeSources)
      .insert(
        IncomeSourcesCompanion.insert(
          name: 'Kiosco',
          colorValue: 0xFF1565C0,
          createdAt: DateTime(2026),
        ),
      );
  await current
      .into(current.categories)
      .insert(
        CategoriesCompanion.insert(
          name: 'Regalos',
          colorValue: 0xFF00838F,
          createdAt: DateTime(2026),
        ),
      );
  await current.customStatement('DROP TABLE transactions');
  await current.customStatement('DROP TABLE savings_goals');
  await current.customStatement('PRAGMA user_version = 3');
  await current.close();
  return file;
}

/// Builds a version 4 file: every feature the app had before savings goals.
Future<File> _createVersion4File(Directory directory) async {
  final file = _databaseFile(directory);
  final current = AppDatabase.file(file);
  final sources = await current.select(current.incomeSources).get();
  await current
      .into(current.transactions)
      .insert(
        TransactionsCompanion.insert(
          type: 'income',
          amountCents: 150000,
          date: 20261105,
          incomeSourceId: Value(sources.first.id),
          createdAt: DateTime.utc(2026, 11, 5, 12),
        ),
      );
  await current.customStatement('DROP TABLE savings_goals');
  await current.customStatement('PRAGMA user_version = 4');
  await current.close();
  return file;
}

Future<int> _schemaVersion(AppDatabase database) async {
  final row = await database.customSelect('PRAGMA user_version').getSingle();
  return row.read<int>('user_version');
}

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('rumbo_migration');
  });

  tearDown(() => directory.delete(recursive: true));

  test('should upgrade a version 1 database and seed both features', () async {
    final file = await _createVersion1File(directory);

    final database = AppDatabase.file(file);
    addTearDown(database.close);

    final sources = await database.select(database.incomeSources).get();
    final categories = await database.select(database.categories).get();

    expect(sources, hasLength(2));
    expect(
      sources.map((row) => row.name),
      containsAll(<String>['Reparación de pelotas', 'Restaurante']),
    );
    expect(categories, hasLength(4));
    expect(
      categories.map((row) => row.name),
      containsAll(<String>['Materiales', 'Transporte', 'Comida', 'Otros']),
    );
    expect(await _schemaVersion(database), 5);
  });

  test(
    'should upgrade a version 2 database without losing income sources',
    () async {
      final file = await _createVersion2File(directory);

      final database = AppDatabase.file(file);
      addTearDown(database.close);

      final sources = await database.select(database.incomeSources).get();
      final categories = await database.select(database.categories).get();

      expect(sources, hasLength(3));
      expect(sources.map((row) => row.name), contains('Kiosco'));
      expect(categories, hasLength(4));
      expect(
        categories.map((row) => row.name),
        containsAll(<String>['Materiales', 'Transporte', 'Comida', 'Otros']),
      );
      expect(await _schemaVersion(database), 5);
    },
  );

  test(
    'should upgrade a version 3 database without losing existing data',
    () async {
      final file = await _createVersion3File(directory);

      final database = AppDatabase.file(file);
      addTearDown(database.close);

      final sources = await database.select(database.incomeSources).get();
      final categories = await database.select(database.categories).get();
      final transactions = await database.select(database.transactions).get();

      expect(sources, hasLength(3));
      expect(sources.map((row) => row.name), contains('Kiosco'));
      expect(categories, hasLength(5));
      expect(categories.map((row) => row.name), contains('Regalos'));
      expect(transactions, isEmpty);
      expect(await _schemaVersion(database), 5);
    },
  );

  test(
    'should upgrade a version 4 database keeping the existing data',
    () async {
      final file = await _createVersion4File(directory);

      final database = AppDatabase.file(file);
      addTearDown(database.close);

      final goals = await database.select(database.savingsGoals).get();
      final transactions = await database.select(database.transactions).get();
      final sources = await database.select(database.incomeSources).get();

      expect(goals, isEmpty);
      expect(transactions, hasLength(1));
      expect(transactions.single.amountCents, 150000);
      expect(sources, hasLength(2));
      expect(await _schemaVersion(database), 5);
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

      final sources = await reopened.select(reopened.incomeSources).get();
      final categories = await reopened.select(reopened.categories).get();

      expect(sources, hasLength(2));
      expect(categories, hasLength(4));
    },
  );
}
