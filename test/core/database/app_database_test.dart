import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.memory();
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'should open an in-memory database when using the test constructor',
    () async {
      final row = await database.customSelect('SELECT 1 AS value').getSingle();

      expect(row.read<int>('value'), 1);
    },
  );

  test('should enable foreign keys when the database opens', () async {
    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();

    expect(row.read<int>('foreign_keys'), 1);
  });

  test('should report schema version 4 when created', () {
    expect(database.schemaVersion, 4);
  });
}
