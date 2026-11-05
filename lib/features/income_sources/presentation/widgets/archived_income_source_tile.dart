import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/presentation/income_source_colors.dart';

/// One archived income source, with the action that brings it back.
class ArchivedIncomeSourceTile extends StatelessWidget {
  const ArchivedIncomeSourceTile({
    required this.source,
    required this.onRestore,
    super.key,
  });

  final IncomeSource source;
  final VoidCallback onRestore;

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
        trailing: TextButton.icon(
          onPressed: onRestore,
          icon: const Icon(Icons.unarchive_outlined),
          label: const Text(AppStrings.restoreAction),
        ),
      ),
    );
  }
}
