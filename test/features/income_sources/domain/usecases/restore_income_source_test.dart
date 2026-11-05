import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/usecases/restore_income_source.dart';

class _MockIncomeSourceRepository extends Mock
    implements IncomeSourceRepository;

IncomeSource _source({
  int id = 1,
  String name = 'Restaurante',
  bool archived = true,
}) => IncomeSource(
  id: id,
  name: name,
  colorValue: 0xFF2E7D32,
  createdAt: DateTime(2026),
  archivedAt: archived ? DateTime(2026, 2) : null,
);

void main() {
  late _MockIncomeSourceRepository repository;
  late RestoreIncomeSource restoreIncomeSource;

  setUp(() {
    repository = _MockIncomeSourceRepository();
    restoreIncomeSource = RestoreIncomeSource(repository);
  });

  void stubActive(List<IncomeSource> sources) {
    when(() => repository.watchActive())
        .thenAnswer((_) => Stream.value(sources));
  }

  test('should return the restored source when the name is free', () async {
    stubActive(const []);
    when(() => repository.getById(1))
        .thenAnswer((_) async => Success(_source()));
    when(() => repository.restore(1))
        .thenAnswer((_) async => Success(_source(archived: false)));

    final result = await restoreIncomeSource(1);

    expect(result.valueOrNull?.isArchived, isFalse);
    verify(() => repository.restore(1)).called(1);
  });

  test(
    'should return the not found failure when the source does not exist',
    () async {
      when(() => repository.getById(9))
          .thenAnswer((_) async => const Err(NotFoundFailure()));

      final result = await restoreIncomeSource(9);

      expect(result.failureOrNull, isA<NotFoundFailure>());
      verifyNever(() => repository.restore(9));
    },
  );

  test(
    'should reject the restore when an active source uses the name',
    () async {
      stubActive([_source(id: 2, name: 'restaurante', archived: false)]);
      when(() => repository.getById(1))
          .thenAnswer((_) async => Success(_source()));

      final result = await restoreIncomeSource(1);

      expect(
        result.failureOrNull,
        isA<ValidationFailure>().having(
          (failure) => failure.field,
          'field',
          'name.duplicate',
        ),
      );
      verifyNever(() => repository.restore(1));
    },
  );
}
