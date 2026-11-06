import 'package:drift/drift.dart';

/// Drift table behind the savings goals feature.
///
/// The CHECK constraints mirror the domain invariants, so a corrupted client
/// cannot store a goal the use cases would reject.
@TableIndex(name: 'savings_goals_target_date', columns: {#targetDate})
@UseRowClass(SavingsGoalRow)
class SavingsGoals extends Table {
  static const _nonEmptyNameCheck = 'CHECK (length(name) > 0)';
  static const _positiveTargetCheck = 'CHECK (target_amount_cents > 0)';
  static const _nonNegativeSavedCheck = 'CHECK (current_amount_cents >= 0)';
  static const _progressCheck =
      'CHECK (current_amount_cents <= target_amount_cents)';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(max: 60)();

  TextColumn get description => text().nullable()();

  IntColumn get targetAmountCents => integer()();

  IntColumn get currentAmountCents => integer()();

  /// Deadline as `yyyymmdd`, so it is compared as a plain integer.
  IntColumn get targetDate => integer().nullable()();

  IntColumn get colorValue => integer()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => const [
    _nonEmptyNameCheck,
    _positiveTargetCheck,
    _nonNegativeSavedCheck,
    _progressCheck,
  ];
}

/// One stored savings goal, exactly as drift reads it.
class SavingsGoalRow {
  const SavingsGoalRow({
    required this.id,
    required this.name,
    required this.description,
    required this.targetAmountCents,
    required this.currentAmountCents,
    required this.targetDate,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String? description;
  final int targetAmountCents;
  final int currentAmountCents;
  final int? targetDate;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
}
