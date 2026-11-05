import 'package:freezed_annotation/freezed_annotation.dart';

part 'income_source.freezed.dart';

/// Where the money comes from, e.g. "Restaurante".
///
/// Sources are never deleted: archiving keeps the history of the transactions
/// that point to them.
@freezed
abstract class IncomeSource with _$IncomeSource {
  const factory IncomeSource({
    required int id,
    required String name,
    required int colorValue,
    required DateTime createdAt,
    DateTime? archivedAt,
  }) = _IncomeSource;

  const IncomeSource._();

  bool get isArchived => archivedAt != null;
}
