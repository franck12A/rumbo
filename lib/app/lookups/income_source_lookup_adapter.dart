import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/transactions/domain/lookups/income_source_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';

/// Connects the transactions feature with the income sources repository.
///
/// It lives in the app composition layer so neither feature imports the other.
final class IncomeSourceLookupAdapter implements IncomeSourceLookup {
  const IncomeSourceLookupAdapter(this._repository);

  final IncomeSourceRepository _repository;

  @override
  Future<ReferenceInfo?> findById(int id) async {
    final source = (await _repository.getById(id)).valueOrNull;
    if (source == null) {
      return null;
    }
    return ReferenceInfo(
      id: source.id,
      name: source.name,
      colorValue: source.colorValue,
      isArchived: source.isArchived,
    );
  }
}
