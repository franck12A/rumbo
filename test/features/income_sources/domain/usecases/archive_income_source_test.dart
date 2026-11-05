import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/usecases/archive_income_source.dart';

class _MockIncomeSourceRepository extends Mock
    implements IncomeSourceRepository;

void main() {
  late _MockIncomeSourceRepository repository;
  late ArchiveIncomeSource archiveIncomeSource;

  setUp(() {
    repository = _MockIncomeSourceRepository();
    archiveIncomeSource = ArchiveIncomeSource(repository);
  });

  test(
    'should return the archived source when the repository succeeds',
    () async {
      final archived = IncomeSource(
        id: 1,
        name: 'Restaurante',
        colorValue: 0xFF2E7D32,
        createdAt: DateTime(2026),
        archivedAt: DateTime(2026, 2),
      );
      when(() => repository.archive(1))
          .thenAnswer((_) async => Success(archived));

      final result = await archiveIncomeSource(1);

      expect(result.valueOrNull?.isArchived, isTrue);
      verify(() => repository.archive(1)).called(1);
    },
  );

  test(
    'should return the not found failure when the source does not exist',
    () async {
      when(() => repository.archive(9))
          .thenAnswer((_) async => const Err(NotFoundFailure()));

      final result = await archiveIncomeSource(9);

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );
}
