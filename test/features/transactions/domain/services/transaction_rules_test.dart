import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/services/transaction_rules.dart';

Failure? _validate({
  TransactionType type = TransactionType.income,
  Money amount = const Money.fromCents(1000),
  String? note,
  int? incomeSourceId = 1,
  int? categoryId,
}) => TransactionRules.validate(
  type: type,
  amount: amount,
  note: note,
  incomeSourceId: incomeSourceId,
  categoryId: categoryId,
);

String? _field(Failure? failure) =>
    failure is ValidationFailure ? failure.field : null;

void main() {
  group('note normalization', () {
    test('should trim the note and turn a blank one into null', () {
      expect(TransactionRules.normalizeNote('  Nota  '), 'Nota');
      expect(TransactionRules.normalizeNote('   '), isNull);
      expect(TransactionRules.normalizeNote(null), isNull);
    });
  });

  group('invariants', () {
    test('should accept an income with a source and no category', () {
      expect(_validate(), isNull);
    });

    test('should accept an expense with a category and no source', () {
      expect(
        _validate(
          type: TransactionType.expense,
          incomeSourceId: null,
          categoryId: 1,
        ),
        isNull,
      );
    });

    test('should reject a non positive amount', () {
      expect(_field(_validate(amount: Money.zero)), 'amount.notPositive');
      expect(
        _field(_validate(amount: const Money.fromCents(-100))),
        'amount.notPositive',
      );
    });

    test('should reject an income without a source', () {
      expect(_field(_validate(incomeSourceId: null)), 'source.required');
    });

    test('should reject an income that also has a category', () {
      expect(_field(_validate(categoryId: 1)), 'category.unexpected');
    });

    test('should reject an expense without a category', () {
      expect(
        _field(_validate(type: TransactionType.expense, incomeSourceId: null)),
        'category.required',
      );
    });

    test('should reject an expense that also has a source', () {
      expect(
        _field(_validate(type: TransactionType.expense, categoryId: 1)),
        'source.unexpected',
      );
    });

    test('should accept a note with exactly 200 characters', () {
      expect(_validate(note: 'a' * 200), isNull);
    });

    test('should reject a note longer than 200 characters', () {
      expect(_field(_validate(note: 'a' * 201)), 'note.tooLong');
    });
  });
}
