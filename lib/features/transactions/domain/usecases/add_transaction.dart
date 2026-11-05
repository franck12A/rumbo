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

/// Records a new movement once the invariants and the reference state pass.
final class AddTransaction {
  const AddTransaction(this._repository, this._incomeSources, this._categories);

  final TransactionRepository _repository;
  final IncomeSourceLookup _incomeSources;
  final CategoryLookup _categories;

  Future<Result<Transaction>> call({
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

    final referenceFailure = await ensureReferenceIsUsable(
      incomeSources: _incomeSources,
      categories: _categories,
      type: type,
      incomeSourceId: incomeSourceId,
      categoryId: categoryId,
    );
    if (referenceFailure != null) {
      return Err(referenceFailure);
    }

    return await _repository.create(
      type: type,
      amount: amount,
      date: date,
      note: normalizedNote,
      incomeSourceId: incomeSourceId,
      categoryId: categoryId,
    );
  }
}
