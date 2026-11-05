import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/usecases/watch_active_income_sources.dart';

class _MockIncomeSourceRepository extends Mock
    implements IncomeSourceRepository;

void main() {
  late _MockIncomeSourceRepository repository;
  late WatchActiveIncomeSources watchActiveIncomeSources;

  setUp(() {
    repository = _MockIncomeSourceRepository();
    watchActiveIncomeSources = WatchActiveIncomeSources(repository);
  });

  test('should emit the active sources streamed by the repository', () async {
    final sources = [
      IncomeSource(
        id: 1,
        name: 'Restaurante',
        colorValue: 0xFF2E7D32,
        createdAt: DateTime(2026),
      ),
    ];
    when(() => repository.watchActive())
        .thenAnswer((_) => Stream.value(sources));

    await expectLater(watchActiveIncomeSources(), emits(sources));
    verify(() => repository.watchActive()).called(1);
  });
}
