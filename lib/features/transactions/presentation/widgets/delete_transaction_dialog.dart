import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

/// Confirms deleting a movement before touching the database.
class DeleteTransactionDialog extends StatelessWidget {
  const DeleteTransactionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.transactionDeleteTitle),
      content: const Text(AppStrings.transactionDeleteBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancelAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(AppStrings.transactionDeleteAction),
        ),
      ],
    );
  }
}
