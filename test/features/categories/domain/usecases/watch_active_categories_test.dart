import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/categories/domain/usecases/watch_active_categories.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository;

void main() {
  test(
    'should emit the active categories streamed by the repository',
    () async {
      final repository = _MockCategoryRepository();
      final category = Category(
        id: 1,
        name: 'Materiales',
        colorValue: 0xFF6A1B9A,
        createdAt: DateTime(2026),
      );
      when(repository.watchActive).thenAnswer((_) => Stream.value([category]));

      final categories = await WatchActiveCategories(repository)().first;

      expect(categories, [category]);
    },
  );
}
