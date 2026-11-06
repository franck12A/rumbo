import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:rumbo/features/transactions/presentation/transaction_actions.dart';
import 'package:rumbo/features/transactions/presentation/widgets/transactions_empty_state.dart';
import 'package:rumbo/features/transactions/presentation/widgets/transactions_error_state.dart';
import 'package:rumbo/features/transactions/presentation/widgets/transactions_list.dart';
import 'package:rumbo/features/transactions/presentation/widgets/transactions_month_selector.dart';
import 'package:rumbo/features/transactions/presentation/widgets/transactions_month_summary.dart';

/// Main screen: movements of the selected month, grouped by day.
class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final views = ref.watch(monthTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactionsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: () => showTransactionFormDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.transactionsNewIncome),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => showTransactionFormDialog(
                    context,
                    ref,
                    initialType: TransactionType.expense,
                  ),
                  icon: const Icon(Icons.remove),
                  label: const Text(AppStrings.transactionsNewExpense),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TransactionsMonthSelector(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TransactionsMonthSummary(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: views.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => TransactionsErrorState(
                onRetry: () {
                  ref
                    ..invalidate(monthTransactionsProvider)
                    ..invalidate(monthSummaryProvider);
                },
              ),
              data: (views) {
                if (views.isEmpty) {
                  return const TransactionsEmptyState();
                }
                return TransactionsList(
                  views: views,
                  onEdit: (view) =>
                      showTransactionFormDialog(context, ref, view: view),
                  onDelete: (view) =>
                      confirmAndDeleteTransaction(context, ref, view),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
