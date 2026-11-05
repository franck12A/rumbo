import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/features/categories/presentation/category_actions.dart';
import 'package:rumbo/features/categories/presentation/providers/category_providers.dart';
import 'package:rumbo/features/categories/presentation/widgets/categories_empty_state.dart';
import 'package:rumbo/features/categories/presentation/widgets/categories_error_state.dart';
import 'package:rumbo/features/categories/presentation/widgets/category_tile.dart';

/// Active tab of the categories screen.
class CategoriesActiveTab extends ConsumerWidget {
  const CategoriesActiveTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(activeCategoriesProvider);

    return categories.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => CategoriesErrorState(
        onRetry: () => ref.invalidate(activeCategoriesProvider),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return const CategoriesEmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryTile(
              category: category,
              onEdit: () =>
                  showCategoryFormDialog(context, ref, category: category),
              onArchive: () =>
                  confirmAndArchiveCategory(context, ref, category),
            );
          },
        );
      },
    );
  }
}
