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

  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      other.from == from &&
      other.to == to &&
      other.type == type &&
      other.incomeSourceId == incomeSourceId &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(from, to, type, incomeSourceId, categoryId);
}
