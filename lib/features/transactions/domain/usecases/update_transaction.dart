import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/lookups/category_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/income_source_lookup.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:rumbo/features/transactions/domain/services/reference_availability.dart';
import 'package:rumbo/features/transactions/domain/services/transaction_rules.dart';

/// Edits a movement, keeping archived references it already used usable.
final class UpdateTransaction {
  const UpdateTransaction(
    this._repository,
    this._incomeSources,
    this._categories,
  );

  final TransactionRepository _repository;
  final IncomeSourceLookup _incomeSources;
  final CategoryLookup _categories;

  Future<Result<Transaction>> call({
    required int id,
    required TransactionType type,
    required Money amount,
    required CalendarDate date,
    String? note,
    int? incomeSourceId,
    int? categoryId,
  }) async {
    final normalizedNote = TransactionRules.normalizeNote(note);
    final validation = TransactionRules.validate(
      type: type,
      amount: amount,
      note: normalizedNote,
      incomeSourceId: incomeSourceId,
      categoryId: categoryId,
    );
    if (validation != null) {
      return Err(validation);
    }

    final found = await _repository.getById(id);
    final Transaction existing;
    switch (found) {
      case Err(:final failure):
        return Err(failure);
      case Success(:final value):
        existing = value.transaction;
    }

    final referenceFailure = await ensureReferenceIsUsable(
      incomeSources: _incomeSources,
      categories: _categories,
      type: type,
      incomeSourceId: incomeSourceId,
      categoryId: categoryId,
      // The transaction may keep a reference that was archived after it was
      // recorded; selecting a different archived one is still rejected.
      archivedAllowedIncomeSourceId: existing.incomeSourceId,
      archivedAllowedCategoryId: existing.categoryId,
    );
    if (referenceFailure != null) {
      return Err(referenceFailure);
    }

    return await _repository.update(
      id: id,
      type: type,
      amount: amount,
      date: date,
      note: normalizedNote,
      incomeSourceId: incomeSourceId,
      categoryId: categoryId,
    );
  }
}
