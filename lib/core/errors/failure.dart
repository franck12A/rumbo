/// Typed failure raised by the data layer and mapped by the presentation layer.
///
/// [message] is meant for logs and debugging, not for showing directly to
/// users.
sealed class Failure {
  const Failure({this.message, this.cause});

  final String? message;
  final Object? cause;

  /// Stable label used by [toString], since `runtimeType` can be minified.
  String get _label => switch (this) {
    DatabaseFailure() => 'DatabaseFailure',
    ValidationFailure() => 'ValidationFailure',
    NotFoundFailure() => 'NotFoundFailure',
  };

  @override
  String toString() {
    final description = message;
    return description == null ? _label : '$_label: $description';
  }
}

/// The database could not be reached or a query failed.
final class DatabaseFailure extends Failure {
  const DatabaseFailure({super.message, super.cause});
}

/// Input data does not satisfy the domain rules.
final class ValidationFailure extends Failure {
  const ValidationFailure({this.field, super.message, super.cause});

  /// Name of the offending field, when the failure comes from form validation.
  final String? field;
}

/// The requested entity does not exist.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({this.resource, super.message, super.cause});

  /// Name of the entity that could not be found.
  final String? resource;
}
