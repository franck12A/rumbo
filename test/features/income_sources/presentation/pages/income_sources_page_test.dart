import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/app/di.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/income_sources/presentation/pages/income_sources_page.dart';

class _MockIncomeSourceRepository extends Mock
    implements IncomeSourceRepository;

IncomeSource _source(int id, String name, {DateTime? archivedAt}) =>
    IncomeSource(
      id: id,
      name: name,
      colorValue: 0xFF2E7D32,
      createdAt: DateTime(2026),
      archivedAt: archivedAt,
    );

Widget _buildApp(IncomeSourceRepository repository) => ProviderScope(
  overrides: [incomeSourceRepositoryProvider.overrideWithValue(repository)],
  child: const MaterialApp(home: IncomeSourcesPage()),
);

void main() {
  testWidgets('should show the empty state when there are no active sources', (
    tester,
  ) async {
    final repository = _MockIncomeSourceRepository();
    when(repository.watchActive).thenAnswer((_) => Stream.value(const []));
    when(repository.watchArchived).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.incomeSourcesEmptyTitle), findsOneWidget);
    expect(find.text(AppStrings.incomeSourcesAdd), findsOneWidget);
  });

  testWidgets('should list the active sources when there are stored ones', (
    tester,
  ) async {
    final repository = _MockIncomeSourceRepository();
    when(repository.watchActive).thenAnswer(
      (_) => Stream.value([
        _source(1, 'Restaurante'),
        _source(2, 'Reparación de pelotas'),
      ]),
    );
    when(repository.watchArchived).thenAnswer((_) => Stream.value(const []));

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Restaurante'), findsOneWidget);
    expect(find.text('Reparación de pelotas'), findsOneWidget);
    expect(find.text(AppStrings.incomeSourcesEmptyTitle), findsNothing);
  });

  testWidgets('should show archived sources with a restore action in the tab', (
    tester,
  ) async {
    final repository = _MockIncomeSourceRepository();
    when(repository.watchActive).thenAnswer((_) => Stream.value(const []));
    when(repository.watchArchived).thenAnswer(
      (_) =>
          Stream.value([_source(1, 'Kiosco', archivedAt: DateTime(2026, 2))]),
    );

    await tester.pumpWidget(_buildApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.archivedTabLabel));
    await tester.pumpAndSettle();

    expect(find.text('Kiosco'), findsOneWidget);
    expect(find.text(AppStrings.restoreAction), findsOneWidget);
  });
}
