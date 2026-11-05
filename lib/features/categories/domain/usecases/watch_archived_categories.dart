import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';

/// Streams the archived categories for the "Archivadas" tab.
final class WatchArchivedCategories {
  const WatchArchivedCategories(this._repository);

  final CategoryRepository _repository;

  Stream<List<Category>> call() => _repository.watchArchived();
}
