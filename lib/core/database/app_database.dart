import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rumbo/features/categories/data/daos/category_dao.dart';
import 'package:rumbo/features/categories/data/tables/categories_table.dart';
import 'package:rumbo/features/income_sources/data/daos/income_source_dao.dart';
import 'package:rumbo/features/income_sources/data/tables/income_sources_table.dart';
import 'package:rumbo/features/savings_goals/data/daos/savings_goal_dao.dart';
import 'package:rumbo/features/savings_goals/data/tables/savings_goals_table.dart';
import 'package:rumbo/features/transactions/data/daos/transaction_dao.dart';
import 'package:rumbo/features/transactions/data/tables/transactions_table.dart';

part 'app_database.g.dart';

/// Single SQLite database of the app.
///
/// Business tables are declared by each feature and added to this class.
@DriftDatabase(
  tables: [IncomeSources, Categories, Transactions, SavingsGoals],
  daos: [IncomeSourceDao, CategoryDao, TransactionDao, SavingsGoalDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Opens a throwaway in-memory database, used by tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  /// Opens the database stored at [file]; used by migration tests.
  AppDatabase.file(File file) : super(NativeDatabase(file));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedIncomeSources();
      await _seedCategories();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(incomeSources);
        await m.createIndex(incomeSourcesArchivedAt);
        await _seedIncomeSources();
      }
      if (from < 3) {
        await m.createTable(categories);
        await m.createIndex(categoriesArchivedAt);
        await _seedCategories();
      }
      if (from < 4) {
        await m.createTable(transactions);
        await m.createIndex(transactionsDate);
        await m.createIndex(transactionsIncomeSourceId);
        await m.createIndex(transactionsCategoryId);
      }
      if (from < 5) {
        await m.createTable(savingsGoals);
        await m.createIndex(savingsGoalsTargetDate);
      }
    },
    beforeOpen: (details) async {
      // SQLite resets foreign keys on every connection, so they must be
      // enabled each time the database is opened.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // Seeded from the database itself so a fresh install and an upgraded one get
  // the same defaults, without the UI knowing about them.
  Future<void> _seedIncomeSources() async {
    const seeds = [
      (name: 'Reparación de pelotas', colorValue: 0xFF2E7D32),
      (name: 'Restaurante', colorValue: 0xFFEF6C00),
    ];
    for (final seed in seeds) {
      await into(incomeSources).insert(
        IncomeSourcesCompanion.insert(
          name: seed.name,
          colorValue: seed.colorValue,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _seedCategories() async {
    const seeds = [
      (name: 'Materiales', colorValue: 0xFF6A1B9A),
      (name: 'Transporte', colorValue: 0xFF1565C0),
      (name: 'Comida', colorValue: 0xFFEF6C00),
      (name: 'Otros', colorValue: 0xFF546E7A),
    ];
    for (final seed in seeds) {
      await into(categories).insert(
        CategoriesCompanion.insert(
          name: seed.name,
          colorValue: seed.colorValue,
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'rumbo.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
