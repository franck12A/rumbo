import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rumbo/app/di.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/usecases/archive_category.dart';
import 'package:rumbo/features/categories/domain/usecases/create_category.dart';
import 'package:rumbo/features/categories/domain/usecases/restore_category.dart';
import 'package:rumbo/features/categories/domain/usecases/update_category.dart';
import 'package:rumbo/features/categories/domain/usecases/watch_active_categories.dart';
import 'package:rumbo/features/categories/domain/usecases/watch_archived_categories.dart';

part 'category_providers.g.dart';

@Riverpod(keepAlive: true)
CreateCategory createCategory(Ref ref) =>
    CreateCategory(ref.watch(categoryRepositoryProvider));

@Riverpod(keepAlive: true)
UpdateCategory updateCategory(Ref ref) =>
    UpdateCategory(ref.watch(categoryRepositoryProvider));

@Riverpod(keepAlive: true)
ArchiveCategory archiveCategory(Ref ref) =>
    ArchiveCategory(ref.watch(categoryRepositoryProvider));

@Riverpod(keepAlive: true)
RestoreCategory restoreCategory(Ref ref) =>
    RestoreCategory(ref.watch(categoryRepositoryProvider));

@Riverpod(keepAlive: true)
WatchActiveCategories watchActiveCategories(Ref ref) =>
    WatchActiveCategories(ref.watch(categoryRepositoryProvider));

@Riverpod(keepAlive: true)
WatchArchivedCategories watchArchivedCategories(Ref ref) =>
    WatchArchivedCategories(ref.watch(categoryRepositoryProvider));

/// Active categories shown on the list screen; rebuilds on every change.
@riverpod
Stream<List<Category>> activeCategories(Ref ref) =>
    ref.watch(watchActiveCategoriesProvider)();

/// Archived categories shown on the "Archivadas" tab.
@riverpod
Stream<List<Category>> archivedCategories(Ref ref) =>
    ref.watch(watchArchivedCategoriesProvider)();
