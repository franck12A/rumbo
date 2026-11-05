import 'package:meta/meta.dart';

/// The minimum data transactions need about an income source or category.
///
/// It lives in the transactions domain so the feature never imports another
/// feature's classes; `app/di.dart` wires the implementations.
@immutable
final class ReferenceInfo {
  const ReferenceInfo({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.isArchived,
  });

  final int id;
  final String name;
  final int colorValue;
  final bool isArchived;
}
