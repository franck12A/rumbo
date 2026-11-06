import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/presentation/transaction_formatters.dart';

/// One movement: reference, note, signed amount and delete action.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.view,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final TransactionView view;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reference = view.source ?? view.category;
    final colorValue = reference?.colorValue;
    final note = view.transaction.note;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onEdit,
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: colorValue == null
              ? theme.colorScheme.surfaceContainerHighest
              : Color(colorValue),
        ),
        title: Text(reference?.name ?? ''),
        subtitle: note == null
            ? null
            : Text(note, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              TransactionFormatters.signedAmount(view.transaction),
              style: theme.textTheme.titleMedium?.copyWith(
                color: view.transaction.isIncome
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: AppStrings.transactionDeleteTooltip,
            ),
          ],
        ),
      ),
    );
  }
}
