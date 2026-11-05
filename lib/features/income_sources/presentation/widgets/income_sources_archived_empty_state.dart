import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

/// Shown when no income source has been archived yet.
class IncomeSourcesArchivedEmptyState extends StatelessWidget {
  const IncomeSourcesArchivedEmptyState({super.key});

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
              Icons.inventory_2_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.incomeSourcesArchivedEmptyTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.incomeSourcesArchivedEmptySubtitle,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
