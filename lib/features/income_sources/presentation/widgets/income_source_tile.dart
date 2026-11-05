import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/presentation/income_source_colors.dart';

/// One income source in the list, with its edit and archive actions.
class IncomeSourceTile extends StatelessWidget {
  const IncomeSourceTile({
    required this.source,
    required this.onEdit,
    required this.onArchive,
    super.key,
  });

  final IncomeSource source;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: IncomeSourceColors.of(source.colorValue),
        ),
        title: Text(source.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: AppStrings.incomeSourceEditTooltip,
            ),
            IconButton(
              onPressed: onArchive,
              icon: const Icon(Icons.archive_outlined),
              tooltip: AppStrings.incomeSourceArchiveTooltip,
            ),
          ],
        ),
      ),
    );
  }
}
