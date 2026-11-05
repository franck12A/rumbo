import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/categories/domain/usecases/watch_archived_categories.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository;

void main() {
  test(
    'should emit the archived categories streamed by the repository',
    () async {
      final repository = _MockCategoryRepository();
      final category = Category(
        id: 1,
        name: 'Materiales',
        colorValue: 0xFF6A1B9A,
        createdAt: DateTime(2026),
        archivedAt: DateTime(2026, 2),
      );
      when(repository.watchArchived)
          .thenAnswer((_) => Stream.value([category]));

      final categories = await WatchArchivedCategories(repository)().first;

      expect(categories, [category]);
    },
  );
}
