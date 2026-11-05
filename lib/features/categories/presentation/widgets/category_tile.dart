import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/presentation/category_colors.dart';

/// One category in the list, with its edit and archive actions.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onArchive,
    super.key,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: AppStrings.categoryEditTooltip,
            ),
            IconButton(
              onPressed: onArchive,
              icon: const Icon(Icons.archive_outlined),
              tooltip: AppStrings.categoryArchiveTooltip,
            ),
          ],
        ),
      ),
    );
  }
}
