import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/transactions/presentation/providers/selected_month_provider.dart';
import 'package:rumbo/features/transactions/presentation/transaction_formatters.dart';

/// Month label with the arrows that move it forward and backward.
class TransactionsMonthSelector extends ConsumerWidget {
  const TransactionsMonthSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthControllerProvider);
    final controller = ref.read(selectedMonthControllerProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: controller.goToPreviousMonth,
          icon: const Icon(Icons.chevron_left),
          tooltip: AppStrings.transactionsPreviousMonth,
        ),
        SizedBox(
          width: 200,
          child: Text(
            TransactionFormatters.monthLabel(month),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: controller.goToNextMonth,
          icon: const Icon(Icons.chevron_right),
          tooltip: AppStrings.transactionsNextMonth,
        ),
        IconButton(
          onPressed: controller.goToCurrentMonth,
          icon: const Icon(Icons.today_outlined),
          tooltip: AppStrings.transactionsCurrentMonth,
        ),
      ],
    );
  }
}
