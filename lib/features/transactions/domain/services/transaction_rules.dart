import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';

/// Invariants every transaction must satisfy, shared by add and update.
abstract final class TransactionRules {
  static const maxNoteLength = 200;

  /// Trims the note and turns a blank one into `null`.
  static String? normalizeNote(String? raw) {
    final trimmed = raw?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Returns the failure that forbids the draft, or `null` if it is valid.
  static Failure? validate({
    required TransactionType type,
    required Money amount,
    required String? note,
    required int? incomeSourceId,
    required int? categoryId,
  }) {
    if (!amount.isPositive) {
      return const ValidationFailure(
        field: 'amount.notPositive',
        message: 'Transaction amount must be greater than zero',
      );
    }
    if (note != null && note.runes.length > maxNoteLength) {
      return const ValidationFailure(
        field: 'note.tooLong',
        message: 'Transaction note is longer than $maxNoteLength characters',
      );
    }

    switch (type) {
      case TransactionType.income:
        if (incomeSourceId == null) {
          return const ValidationFailure(
            field: 'source.required',
            message: 'An income transaction requires an income source',
          );
        }
        if (categoryId != null) {
          return const ValidationFailure(
            field: 'category.unexpected',
            message: 'An income transaction cannot have a category',
          );
        }
      case TransactionType.expense:
        if (categoryId == null) {
          return const ValidationFailure(
            field: 'category.required',
            message: 'An expense transaction requires a category',
          );
        }
        if (incomeSourceId != null) {
          return const ValidationFailure(
            field: 'source.unexpected',
            message: 'An expense transaction cannot have an income source',
          );
        }
    }

    return null;
  }
}
