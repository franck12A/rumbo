import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

/// Shown when the selected month has no movements.
class TransactionsEmptyState extends StatelessWidget {
  const TransactionsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.transactionsEmptyTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.transactionsEmptySubtitle,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
