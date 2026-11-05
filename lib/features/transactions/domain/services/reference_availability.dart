import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/lookups/category_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/income_source_lookup.dart';

/// Checks that the referenced source or category exists and is usable.
///
/// An archived reference is only accepted when it is the one the transaction
/// already used ([archivedAllowedIncomeSourceId] / [archivedAllowedCategoryId]),
/// which keeps history editable without allowing new movements against
/// archived items.
Future<Failure?> ensureReferenceIsUsable({
  required IncomeSourceLookup incomeSources,
  required CategoryLookup categories,
  required TransactionType type,
  required int? incomeSourceId,
  required int? categoryId,
  int? archivedAllowedIncomeSourceId,
  int? archivedAllowedCategoryId,
}) async {
  switch (type) {
    case TransactionType.income:
      final id = incomeSourceId;
      if (id == null) {
        return null;
      }
      final source = await incomeSources.findById(id);
      if (source == null) {
        return const ValidationFailure(
          field: 'source.notFound',
          message: 'The income source does not exist',
        );
      }
      if (source.isArchived && id != archivedAllowedIncomeSourceId) {
        return const ValidationFailure(
          field: 'source.archived',
          message: 'The income source is archived',
        );
      }
    case TransactionType.expense:
      final id = categoryId;
      if (id == null) {
        return null;
      }
      final category = await categories.findById(id);
      if (category == null) {
        return const ValidationFailure(
          field: 'category.notFound',
          message: 'The category does not exist',
        );
      }
      if (category.isArchived && id != archivedAllowedCategoryId) {
        return const ValidationFailure(
          field: 'category.archived',
          message: 'The category is archived',
        );
      }
  }

  return null;
}
