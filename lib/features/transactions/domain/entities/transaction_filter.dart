import 'package:meta/meta.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';

/// Optional criteria used to narrow the transaction history.
///
/// [from] and [to] are inclusive.
@immutable
final class TransactionFilter {
  const TransactionFilter({
    this.from,
    this.to,
    this.type,
    this.incomeSourceId,
    this.categoryId,
  });

  final CalendarDate? from;
  final CalendarDate? to;
  final TransactionType? type;
  final int? incomeSourceId;
  final int? categoryId;
}
