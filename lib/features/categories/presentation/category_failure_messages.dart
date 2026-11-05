import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';

/// Translates a domain failure into the copy shown on the categories UI.
String categoryFailureMessage(Failure failure) => switch (failure) {
  ValidationFailure(field: 'name.empty') => AppStrings.categoryNameEmptyError,
  ValidationFailure(field: 'name.tooLong') =>
    AppStrings.categoryNameTooLongError,
  ValidationFailure(field: 'name.duplicate') =>
    AppStrings.categoryNameDuplicateError,
  _ => AppStrings.categoriesGenericError,
};

/// Copy used when a restore is rejected because an active category owns the
/// name.
String categoryRestoreFailureMessage(Failure failure) => switch (failure) {
  ValidationFailure(field: 'name.duplicate') =>
    AppStrings.categoryRestoreDuplicateError,
  _ => categoryFailureMessage(failure),
};
