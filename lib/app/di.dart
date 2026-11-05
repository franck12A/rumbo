import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rumbo/app/lookups/category_lookup_adapter.dart';
import 'package:rumbo/app/lookups/income_source_lookup_adapter.dart';
import 'package:rumbo/core/database/database_provider.dart';
import 'package:rumbo/features/categories/data/repositories/drift_category_repository.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/income_sources/data/repositories/drift_income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:rumbo/features/transactions/domain/lookups/category_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/income_source_lookup.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';

part 'di.g.dart';

/// Composition root: the only place that decides which implementation backs a
/// domain interface. Features depend on `domain` only.
@Riverpod(keepAlive: true)
IncomeSourceRepository incomeSourceRepository(Ref ref) =>
    DriftIncomeSourceRepository(ref.watch(appDatabaseProvider).incomeSourceDao);

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) =>
    DriftCategoryRepository(ref.watch(appDatabaseProvider).categoryDao);

@Riverpod(keepAlive: true)
IncomeSourceLookup incomeSourceLookup(Ref ref) =>
    IncomeSourceLookupAdapter(ref.watch(incomeSourceRepositoryProvider));

@Riverpod(keepAlive: true)
CategoryLookup categoryLookup(Ref ref) =>
    CategoryLookupAdapter(ref.watch(categoryRepositoryProvider));

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) =>
    DriftTransactionRepository(
      ref.watch(appDatabaseProvider).transactionDao,
      ref.watch(incomeSourceLookupProvider),
      ref.watch(categoryLookupProvider),
    );
