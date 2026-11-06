import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/transactions/domain/entities/month_summary.dart';
import 'package:rumbo/features/transactions/presentation/providers/transaction_providers.dart';

/// Income, expense and balance totals of the selected month.
class TransactionsMonthSummary extends ConsumerWidget {
  const TransactionsMonthSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthSummaryProvider);

    return summary.when(
      loading: () => const SizedBox(
        height: 88,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (summary) => _SummaryCards(summary: summary),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNegative = summary.balance.isNegative;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: AppStrings.transactionsSummaryIncome,
            value: summary.totalIncome.format(),
            valueColor: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: AppStrings.transactionsSummaryExpense,
            value: summary.totalExpense.format(),
            valueColor: theme.colorScheme.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: AppStrings.transactionsSummaryBalance,
            value: summary.balance.format(),
            valueColor: isNegative
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(color: valueColor),
            ),
          ],
        ),
      ),
    );
  }
}
