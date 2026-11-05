import 'package:flutter/material.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/categories/presentation/widgets/category_color_picker.dart';

/// Create/edit form. It only collects the draft: the use case validates it and
/// returns the message to show when the input is rejected.
class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({
    required this.title,
    required this.initialName,
    required this.initialColorValue,
    required this.onSubmit,
    super.key,
  });

  final String title;
  final String initialName;
  final int initialColorValue;
  final Future<String?> Function(String name, int colorValue) onSubmit;

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  late final TextEditingController _nameController;
  late int _colorValue;
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _colorValue = widget.initialColorValue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final errorMessage = await widget.onSubmit(
      _nameController.text,
      _colorValue,
    );
    if (!mounted) {
      return;
    }
    if (errorMessage != null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = errorMessage;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  void _cancel() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              enabled: !_isSubmitting,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: AppStrings.categoryNameLabel,
                hintText: AppStrings.categoryNameHint,
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.categoryColorLabel,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            CategoryColorPicker(
              selectedColorValue: _colorValue,
              onSelected: _isSubmitting
                  ? null
                  : (colorValue) => setState(() => _colorValue = colorValue),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : _cancel,
          child: const Text(AppStrings.cancelAction),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: const Text(AppStrings.saveAction),
        ),
      ],
    );
  }
}
