import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/usecases/watch_archived_income_sources.dart';

class _MockIncomeSourceRepository extends Mock
    implements IncomeSourceRepository;

void main() {
  test('should emit the archived sources streamed by the repository', () async {
    final repository = _MockIncomeSourceRepository();
    final source = IncomeSource(
      id: 1,
      name: 'Restaurante',
      colorValue: 0xFF2E7D32,
      createdAt: DateTime(2026),
      archivedAt: DateTime(2026, 2),
    );
    when(repository.watchArchived).thenAnswer((_) => Stream.value([source]));

    final sources = await WatchArchivedIncomeSources(repository)().first;

    expect(sources, [source]);
  });
}
