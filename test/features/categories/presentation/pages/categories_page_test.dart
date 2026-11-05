import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/app/di.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/categories/presentation/pages/categories_page.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository;

Category _category(int id, String name, {DateTime? archivedAt}) => Category(
  id: id,
  name: name,
  colorValue: 0xFF6A1B9A,
  createdAt: DateTime(2026),
  archivedAt: archivedAt,
);

Widget _buildApp(CategoryRepository repository) => ProviderScope(
  overrides: [categoryRepositoryProvider.overrideWithValue(repository)],
  child: const MaterialApp(home: CategoriesPage()),
);

void main() {
  testWidgets(
    'should show the empty state when there are no active categories',
    (tester) async {
      final repository = _MockCategoryRepository();
      when(repository.watchActive).thenAnswer((_) => Stream.value(const []));
      when(repository.watchArchived).thenAnswer((_) => Stream.value(const []));

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.categoriesEmptyTitle), findsOneWidget);
      expect(find.text(AppStrings.categoriesAdd), findsOneWidget);
    },
  );

  testWidgets('should list the active categories when there are stored ones', (
    tester,
  ) async {
    final repository = _MockCategoryRepository();
    when(repository.watchActive).thenAnswer(
      (_) => Stream.value([_category(1, 'Materiales'), _category(2, 'Comida')]),
    );
    when(repository.watchArchived).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Materiales'), findsOneWidget);
    expect(find.text('Comida'), findsOneWidget);
    expect(find.text(AppStrings.categoriesEmptyTitle), findsNothing);
  });

  testWidgets(
    'should show archived categories with a restore action in the tab',
    (tester) async {
      final repository = _MockCategoryRepository();
      when(repository.watchActive).thenAnswer((_) => Stream.value(const []));
      when(repository.watchArchived).thenAnswer(
        (_) => Stream.value([
          _category(1, 'Viejos', archivedAt: DateTime(2026, 2)),
        ]),
      );

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.archivedTabLabel));
      await tester.pumpAndSettle();

      expect(find.text('Viejos'), findsOneWidget);
      expect(find.text(AppStrings.restoreAction), findsOneWidget);
    },
  );
}
