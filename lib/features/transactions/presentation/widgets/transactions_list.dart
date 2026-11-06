import 'package:flutter/material.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/presentation/transaction_formatters.dart';
import 'package:rumbo/features/transactions/presentation/widgets/transaction_tile.dart';

/// Movements grouped by day, keeping the newest day first.
class TransactionsList extends StatelessWidget {
  const TransactionsList({
    required this.views,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<TransactionView> views;
  final ValueChanged<TransactionView> onEdit;
  final ValueChanged<TransactionView> onDelete;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    CalendarDate? currentDate;

    for (final view in views) {
      final date = view.transaction.date;
      if (date != currentDate) {
        currentDate = date;
        children
          ..add(const SizedBox(height: 8))
          ..add(_DayHeader(date: date));
      }
      children
        ..add(const SizedBox(height: 8))
        ..add(
          TransactionTile(
            view: view,
            onEdit: () => onEdit(view),
            onDelete: () => onDelete(view),
          ),
        );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: children,
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date});

  final CalendarDate date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      TransactionFormatters.dayHeader(date),
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
