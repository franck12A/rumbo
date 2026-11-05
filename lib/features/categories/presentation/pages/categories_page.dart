import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/categories/presentation/category_actions.dart';
import 'package:rumbo/features/categories/presentation/widgets/categories_active_tab.dart';
import 'package:rumbo/features/categories/presentation/widgets/categories_archived_tab.dart';

/// Categories screen: active list plus the archived one.
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.categoriesTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                onPressed: () => showCategoryFormDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.categoriesAdd),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: AppStrings.activeTabLabel),
              Tab(text: AppStrings.archivedTabLabel),
            ],
          ),
        ),
        body: const TabBarView(
          children: [CategoriesActiveTab(), CategoriesArchivedTab()],
        ),
      ),
    );
  }
}
