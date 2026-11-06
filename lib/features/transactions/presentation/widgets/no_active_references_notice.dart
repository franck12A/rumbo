import 'package:flutter/material.dart';

/// Explains that the form cannot be used yet and links to the screen where the
/// missing sources or categories can be created.
class NoActiveReferencesNotice extends StatelessWidget {
  const NoActiveReferencesNotice({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onGoTo,
    super.key,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onGoTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onGoTo, child: Text(actionLabel)),
          ),
        ],
      ),
    );
  }
}
