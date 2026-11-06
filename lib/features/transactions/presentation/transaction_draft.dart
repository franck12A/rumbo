import 'package:meta/meta.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';

/// What the form collects before a use case validates it.
@immutable
final class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.amount,
    required this.date,
    this.note,
    this.incomeSourceId,
    this.categoryId,
  });

  final TransactionType type;
  final Money amount;
  final CalendarDate date;
  final String? note;
  final int? incomeSourceId;
  final int? categoryId;
}
