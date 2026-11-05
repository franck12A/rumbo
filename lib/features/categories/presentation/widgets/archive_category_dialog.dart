import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

/// Confirms archiving before touching the database.
class ArchiveCategoryDialog extends StatelessWidget {
  const ArchiveCategoryDialog({required this.categoryName, super.key});

  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.categoryArchiveTitle),
      content: Text(AppStrings.categoryArchiveBody(categoryName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(AppStrings.categoryArchiveAction),
        ),
      ],
    );
  }
}
