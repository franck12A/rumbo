import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

/// Translates a domain failure into the copy shown on the transactions UI.
String transactionFailureMessage(Failure failure) => switch (failure) {
  ValidationFailure(field: 'amount.notPositive') =>
    AppStrings.transactionAmountNotPositiveError,
  ValidationFailure(field: 'note.tooLong') =>
    AppStrings.transactionNoteTooLongError,
  ValidationFailure(field: 'source.required') =>
    AppStrings.transactionSourceRequiredError,
  ValidationFailure(field: 'source.unexpected') =>
    AppStrings.transactionSourceUnexpectedError,
  ValidationFailure(field: 'source.notFound') =>
    AppStrings.transactionSourceNotFoundError,
  ValidationFailure(field: 'source.archived') =>
    AppStrings.transactionSourceArchivedError,
  ValidationFailure(field: 'category.required') =>
    AppStrings.transactionCategoryRequiredError,
  ValidationFailure(field: 'category.unexpected') =>
    AppStrings.transactionCategoryUnexpectedError,
  ValidationFailure(field: 'category.notFound') =>
    AppStrings.transactionCategoryNotFoundError,
  ValidationFailure(field: 'category.archived') =>
    AppStrings.transactionCategoryArchivedError,
  NotFoundFailure() => AppStrings.transactionNotFoundError,
  _ => AppStrings.transactionsGenericError,
};
