import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/transactions/domain/lookups/category_lookup.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';

/// Connects the transactions feature with the categories repository.
///
/// It lives in the app composition layer so neither feature imports the other.
final class CategoryLookupAdapter implements CategoryLookup {
  const CategoryLookupAdapter(this._repository);

  final CategoryRepository _repository;

  @override
  Future<ReferenceInfo?> findById(int id) async {
    final category = (await _repository.getById(id)).valueOrNull;
    if (category == null) {
      return null;
    }
    return ReferenceInfo(
      id: category.id,
      name: category.name,
      colorValue: category.colorValue,
      isArchived: category.isArchived,
    );
  }
}
