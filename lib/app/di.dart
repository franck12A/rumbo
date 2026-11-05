import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rumbo/core/database/database_provider.dart';
import 'package:rumbo/features/categories/data/repositories/drift_category_repository.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/income_sources/data/repositories/drift_income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';

part 'di.g.dart';

/// Composition root: the only place that decides which implementation backs a
/// domain interface. Features depend on `domain` only.
@Riverpod(keepAlive: true)
IncomeSourceRepository incomeSourceRepository(Ref ref) =>
    DriftIncomeSourceRepository(ref.watch(appDatabaseProvider).incomeSourceDao);

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) =>
    DriftCategoryRepository(ref.watch(appDatabaseProvider).categoryDao);
