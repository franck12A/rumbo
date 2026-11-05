import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';

/// Reads a category's state without depending on the categories feature.
/// Returns `null` when the id does not exist.
abstract interface class CategoryLookup {
  Future<ReferenceInfo?> findById(int id);
}
