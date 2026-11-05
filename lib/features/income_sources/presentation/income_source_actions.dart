import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/presentation/income_source_colors.dart';
import 'package:rumbo/features/income_sources/presentation/income_source_failure_messages.dart';
import 'package:rumbo/features/income_sources/presentation/providers/income_source_providers.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/archive_income_source_dialog.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_source_form_dialog.dart';

/// Dialog and snackbar flows of the income sources screen, so the page itself
/// stays a pure layout widget.
Future<void> showIncomeSourceFormDialog(
  BuildContext context,
  WidgetRef ref, {
  IncomeSource? source,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) => IncomeSourceFormDialog(
    title: source == null
        ? AppStrings.incomeSourceCreateTitle
        : AppStrings.incomeSourceEditTitle,
    initialName: source?.name ?? '',
    initialColorValue:
        source?.colorValue ?? IncomeSourceColors.defaultColorValue,
    onSubmit: (name, colorValue) => _submit(ref, source, name, colorValue),
  ),
);

Future<void> confirmAndArchiveIncomeSource(
  BuildContext context,
  WidgetRef ref,
  IncomeSource source,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) =>
        ArchiveIncomeSourceDialog(sourceName: source.name),
  );
  if (confirmed != true || !context.mounted) {
    return;
  }

  final result = await ref.read(archiveIncomeSourceProvider)(source.id);
  if (!context.mounted) {
    return;
  }
  final failure = result.failureOrNull;
  if (failure != null) {
    _showFailure(context, failure);
    return;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text(AppStrings.incomeSourceArchivedMessage),
        action: SnackBarAction(
          label: AppStrings.undoAction,
          onPressed: () => _restore(context, ref, source),
        ),
      ),
    );
}

Future<void> _restore(
  BuildContext context,
  WidgetRef ref,
  IncomeSource source,
) async {
  final result = await ref.read(restoreIncomeSourceProvider)(source.id);
  if (!context.mounted) {
    return;
  }
  final failure = result.failureOrNull;
  if (failure != null) {
    _showFailure(context, failure);
  }
}

Future<String?> _submit(
  WidgetRef ref,
  IncomeSource? source,
  String name,
  int colorValue,
) async {
  final result = source == null
      ? await ref.read(createIncomeSourceProvider)(
          name: name,
          colorValue: colorValue,
        )
      : await ref.read(updateIncomeSourceProvider)(
          id: source.id,
          name: name,
          colorValue: colorValue,
        );

  final failure = result.failureOrNull;
  return failure == null ? null : incomeSourceFailureMessage(failure);
}

void _showFailure(BuildContext context, Failure failure) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(incomeSourceFailureMessage(failure))));
}
