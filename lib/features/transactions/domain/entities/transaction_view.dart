import 'package:meta/meta.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';

/// A transaction plus the names and colors of its source or category.
///
/// The reference is read even when archived, so the history keeps showing the
/// name it had when the movement was recorded.
@immutable
final class TransactionView {
  const TransactionView({
    required this.transaction,
    this.source,
    this.category,
  });

  final Transaction transaction;
  final ReferenceInfo? source;
  final ReferenceInfo? category;
}
