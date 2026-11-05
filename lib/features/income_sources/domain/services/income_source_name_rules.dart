import 'package:rumbo/core/errors/failure.dart';

/// Name rules shared by the create and update use cases.
abstract final class IncomeSourceNameRules {
  static const maxLength = 40;

  /// Removes the surrounding whitespace the user may have typed.
  static String normalize(String raw) => raw.trim();

  /// Returns the failure that forbids [normalizedName], or `null` if it is ok.
  static Failure? validate(String normalizedName) {
    if (normalizedName.isEmpty) {
      return const ValidationFailure(
        field: 'name.empty',
        message: 'Income source name must not be empty',
      );
    }
    if (normalizedName.runes.length > maxLength) {
      return const ValidationFailure(
        field: 'name.tooLong',
        message: 'Income source name is longer than $maxLength characters',
      );
    }
    return null;
  }

  /// Case-insensitive comparison used to keep active names unique.
  static bool hasSameName(String first, String second) =>
      first.toLowerCase() == second.toLowerCase();
}
