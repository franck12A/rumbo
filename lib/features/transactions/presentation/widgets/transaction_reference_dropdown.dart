import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';

/// Dropdown that lists active sources or categories, plus the archived one the
/// transaction already used.
class TransactionReferenceDropdown extends StatelessWidget {
  const TransactionReferenceDropdown({
    required this.label,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    super.key,
  });

  final String label;
  final List<ReferenceInfo> options;
  final int? selectedId;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: selectedId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      hint: const Text(AppStrings.transactionReferenceHint),
      items: [
        for (final option in options)
          DropdownMenuItem<int>(
            value: option.id,
            child: Text(_labelFor(option)),
          ),
      ],
      onChanged: onChanged,
    );
  }

  static String _labelFor(ReferenceInfo reference) => reference.isArchived
      ? '${reference.name} ${AppStrings.transactionArchivedSuffix}'
      : reference.name;
}
