import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/features/categories/presentation/category_actions.dart';
import 'package:rumbo/features/categories/presentation/providers/category_providers.dart';
import 'package:rumbo/features/categories/presentation/widgets/archived_category_tile.dart';
import 'package:rumbo/features/categories/presentation/widgets/categories_archived_empty_state.dart';
import 'package:rumbo/features/categories/presentation/widgets/categories_error_state.dart';

/// Archived tab of the categories screen, with the restore action.
class CategoriesArchivedTab extends ConsumerWidget {
  const CategoriesArchivedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(archivedCategoriesProvider);

    return categories.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => CategoriesErrorState(
        onRetry: () => ref.invalidate(archivedCategoriesProvider),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const CategoriesArchivedEmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final category = categories[index];
            return ArchivedCategoryTile(
              category: category,
              onRestore: () => restoreArchivedCategory(context, ref, category),
            );
          },
        );
      },
    );
  }
}
