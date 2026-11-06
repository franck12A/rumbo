import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rumbo/app/app_routes.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:rumbo/features/transactions/presentation/transaction_draft.dart';
import 'package:rumbo/features/transactions/presentation/transaction_failure_messages.dart';
import 'package:rumbo/features/transactions/presentation/widgets/delete_transaction_dialog.dart';
import 'package:rumbo/features/transactions/presentation/widgets/transaction_form_dialog.dart';

/// Dialog and snackbar flows of the transactions screen.
Future<void> showTransactionFormDialog(
  BuildContext context,
  WidgetRef ref, {
  TransactionType initialType = TransactionType.income,
  TransactionView? view,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) => TransactionFormDialog(
    initialType: view?.transaction.type ?? initialType,
    view: view,
    onSubmit: (draft) => _submit(ref, view, draft),
    onOpenIncomeSources: () {
      Navigator.of(dialogContext).pop();
      context.go(AppRoutes.incomeSources);
    },
    onOpenCategories: () {
      Navigator.of(dialogContext).pop();
      context.go(AppRoutes.categories);
    },
  ),
);

Future<void> confirmAndDeleteTransaction(
  BuildContext context,
  WidgetRef ref,
  TransactionView view,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => const DeleteTransactionDialog(),
  );
  if (confirmed != true || !context.mounted) {
    return;
  }

  final result = await ref.read(deleteTransactionProvider)(view.transaction.id);
  if (!context.mounted) {
    return;
  }
  final failure = result.failureOrNull;
  if (failure != null) {
    _showMessage(context, transactionFailureMessage(failure));
    return;
  }

  final deleted = result.valueOrNull;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text(AppStrings.transactionDeletedMessage),
        action: SnackBarAction(
          label: AppStrings.undoAction,
          onPressed: () => _undoDelete(context, ref, deleted),
        ),
      ),
    );
}

Future<String?> _submit(
  WidgetRef ref,
  TransactionView? existing,
  TransactionDraft draft,
) async {
  final result = existing == null
      ? await ref.read(addTransactionProvider)(
          type: draft.type,
          amount: draft.amount,
          date: draft.date,
          note: draft.note,
          incomeSourceId: draft.incomeSourceId,
          categoryId: draft.categoryId,
        )
      : await ref.read(updateTransactionProvider)(
          id: existing.transaction.id,
          type: draft.type,
          amount: draft.amount,
          date: draft.date,
          note: draft.note,
          incomeSourceId: draft.incomeSourceId,
          categoryId: draft.categoryId,
        );

  final failure = result.failureOrNull;
  return failure == null ? null : transactionFailureMessage(failure);
}

/// Recreates the deleted movement; the new row gets a new id.
Future<void> _undoDelete(
  BuildContext context,
  WidgetRef ref,
  Transaction? deleted,
) async {
  if (deleted == null) {
    return;
  }

  final result = await ref.read(addTransactionProvider)(
    type: deleted.type,
    amount: deleted.amount,
    date: deleted.date,
    note: deleted.note,
    incomeSourceId: deleted.incomeSourceId,
    categoryId: deleted.categoryId,
  );
  if (!context.mounted) {
    return;
  }
  final failure = result.failureOrNull;
  if (failure != null) {
    _showMessage(context, transactionFailureMessage(failure));
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
