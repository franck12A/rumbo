import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

/// Translates a domain failure into the copy shown on the income sources UI.
String incomeSourceFailureMessage(Failure failure) => switch (failure) {
  ValidationFailure(field: 'name.empty') =>
    AppStrings.incomeSourceNameEmptyError,
  ValidationFailure(field: 'name.tooLong') =>
    AppStrings.incomeSourceNameTooLongError,
  ValidationFailure(field: 'name.duplicate') =>
    AppStrings.incomeSourceNameDuplicateError,
  _ => AppStrings.incomeSourcesGenericError,
};

/// Copy used when a restore is rejected because an active source owns the name.
String incomeSourceRestoreFailureMessage(Failure failure) => switch (failure) {
  ValidationFailure(field: 'name.duplicate') =>
    AppStrings.incomeSourceRestoreDuplicateError,
  _ => incomeSourceFailureMessage(failure),
};
