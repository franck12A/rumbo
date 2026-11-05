import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';

/// Reads an income source's state without depending on the income sources
/// feature. Returns `null` when the id does not exist.
abstract interface class IncomeSourceLookup {
  Future<ReferenceInfo?> findById(int id);
}
