import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

/// Confirms archiving before touching the database.
class ArchiveIncomeSourceDialog extends StatelessWidget {
  const ArchiveIncomeSourceDialog({required this.sourceName, super.key});

  final String sourceName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.incomeSourceArchiveTitle),
      content: Text(AppStrings.incomeSourceArchiveBody(sourceName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(AppStrings.incomeSourceArchiveAction),
        ),
      ],
    );
  }
}
