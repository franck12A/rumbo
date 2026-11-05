import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// Spending category, e.g. "Transporte".
///
/// Categories are never deleted: archiving keeps the history of the
/// transactions that point to them.
@freezed
abstract class Category with _$Category {
  const factory Category({
    required int id,
    required String name,
    required int colorValue,
    required DateTime createdAt,
    DateTime? archivedAt,
  }) = _Category;

  const Category._();

  bool get isArchived => archivedAt != null;
}
