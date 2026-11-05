import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/presentation/category_colors.dart';
import 'package:rumbo/features/categories/presentation/category_failure_messages.dart';
import 'package:rumbo/features/categories/presentation/providers/category_providers.dart';
import 'package:rumbo/features/categories/presentation/widgets/archive_category_dialog.dart';
import 'package:rumbo/features/categories/presentation/widgets/category_form_dialog.dart';

/// Dialog and snackbar flows of the categories screen, so the page itself
/// stays a pure layout widget.
Future<void> showCategoryFormDialog(
  BuildContext context,
  WidgetRef ref, {
  Category? category,
}) => showDialog<void>(
  context: context,
  builder: (dialogContext) => CategoryFormDialog(
    title: category == null
        ? AppStrings.categoryCreateTitle
        : AppStrings.categoryEditTitle,
    initialName: category?.name ?? '',
    initialColorValue: category?.colorValue ?? CategoryColors.defaultColorValue,
    onSubmit: (name, colorValue) => _submit(ref, category, name, colorValue),
  ),
);

Future<void> confirmAndArchiveCategory(
  BuildContext context,
  WidgetRef ref,
  Category category,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) =>
        ArchiveCategoryDialog(categoryName: category.name),
  );
  if (confirmed != true || !context.mounted) {
    return;
  }

  final result = await ref.read(archiveCategoryProvider)(category.id);
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
        content: const Text(AppStrings.categoryArchivedMessage),
        action: SnackBarAction(
          label: AppStrings.undoAction,
          onPressed: () => restoreArchivedCategory(context, ref, category),
        ),
      ),
    );
}

/// Restores an archived category, used by the "Archivadas" tab and "Deshacer".
Future<void> restoreArchivedCategory(
  BuildContext context,
  WidgetRef ref,
  Category category,
) async {
  final result = await ref.read(restoreCategoryProvider)(category.id);
  if (!context.mounted) {
    return;
  }
  final failure = result.failureOrNull;
  if (failure != null) {
    _showFailure(
      context,
      failure,
      message: categoryRestoreFailureMessage(failure),
    );
    return;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text(AppStrings.categoryRestoredMessage)),
    );
}

Future<String?> _submit(
  WidgetRef ref,
  Category? category,
  String name,
  int colorValue,
) async {
  final result = category == null
      ? await ref.read(createCategoryProvider)(
          name: name,
          colorValue: colorValue,
        )
      : await ref.read(updateCategoryProvider)(
          id: category.id,
          name: name,
          colorValue: colorValue,
        );

  final failure = result.failureOrNull;
  return failure == null ? null : categoryFailureMessage(failure);
}

void _showFailure(BuildContext context, Failure failure, {String? message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message ?? categoryFailureMessage(failure))),
  );
}
