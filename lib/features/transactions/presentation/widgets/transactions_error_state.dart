import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

/// Shown when the month movements stream fails.
class TransactionsErrorState extends StatelessWidget {
  const TransactionsErrorState({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.transactionsErrorTitle,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retryAction),
            ),
          ],
        ),
      ),
    );
  }
}
