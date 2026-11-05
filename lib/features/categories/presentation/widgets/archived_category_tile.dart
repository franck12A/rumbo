import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/presentation/category_colors.dart';

/// One archived category, with the action that brings it back.
class ArchivedCategoryTile extends StatelessWidget {
  const ArchivedCategoryTile({
    required this.category,
    required this.onRestore,
    super.key,
  });

  final Category category;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: CategoryColors.of(category.colorValue),
        ),
        title: Text(category.name),
        trailing: TextButton.icon(
          onPressed: onRestore,
          icon: const Icon(Icons.unarchive_outlined),
          label: const Text(AppStrings.restoreAction),
        ),
      ),
    );
  }
}
