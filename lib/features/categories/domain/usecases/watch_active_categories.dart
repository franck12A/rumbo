import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';

/// Streams the active categories for the list screen.
final class WatchActiveCategories {
  const WatchActiveCategories(this._repository);

  final CategoryRepository _repository;

  Stream<List<Category>> call() => _repository.watchActive();
}
