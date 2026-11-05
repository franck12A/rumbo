import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/usecases/restore_income_source.dart';

class _MockIncomeSourceRepository extends Mock
    implements IncomeSourceRepository;

void main() {
  late _MockIncomeSourceRepository repository;
  late RestoreIncomeSource restoreIncomeSource;

  setUp(() {
    repository = _MockIncomeSourceRepository();
    restoreIncomeSource = RestoreIncomeSource(repository);
  });

  test(
    'should return the restored source when the repository succeeds',
    () async {
      final restored = IncomeSource(
        id: 1,
        name: 'Restaurante',
        colorValue: 0xFF2E7D32,
        createdAt: DateTime(2026),
      );
      when(() => repository.restore(1))
          .thenAnswer((_) async => Success(restored));

      final result = await restoreIncomeSource(1);

      expect(result.valueOrNull?.isArchived, isFalse);
      verify(() => repository.restore(1)).called(1);
    },
  );

  test(
    'should return the not found failure when the source does not exist',
    () async {
      when(() => repository.restore(9))
          .thenAnswer((_) async => const Err(NotFoundFailure()));

      final result = await restoreIncomeSource(9);

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );
}
