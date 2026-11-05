import 'package:flutter/material.dart';
import 'package:rumbo/features/income_sources/presentation/income_source_colors.dart';

/// Row of color options used when creating or editing an income source.
class IncomeSourceColorPicker extends StatelessWidget {
  const IncomeSourceColorPicker({
    required this.selectedColorValue,
    required this.onSelected,
    super.key,
  });

  final int selectedColorValue;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final onSelected = this.onSelected;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final color in IncomeSourceColors.palette)
          _ColorOption(
            color: color,
            isSelected: color.toARGB32() == selectedColorValue,
            onTap: onSelected == null
                ? null
                : () => onSelected(color.toARGB32()),
          ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2,
                )
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}
