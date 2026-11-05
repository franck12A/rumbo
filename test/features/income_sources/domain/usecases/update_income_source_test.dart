import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/usecases/update_income_source.dart';

class _MockIncomeSourceRepository extends Mock
    implements IncomeSourceRepository;

const _color = 0xFF2E7D32;

IncomeSource _source({int id = 1, String name = 'Restaurante'}) => IncomeSource(
  id: id,
  name: name,
  colorValue: _color,
  createdAt: DateTime(2026),
);

void main() {
  late _MockIncomeSourceRepository repository;
  late UpdateIncomeSource updateIncomeSource;

  setUp(() {
    repository = _MockIncomeSourceRepository();
    updateIncomeSource = UpdateIncomeSource(repository);
  });

  void stubActive(List<IncomeSource> sources) {
    when(() => repository.watchActive())
        .thenAnswer((_) => Stream.value(sources));
  }

  test(
    'should update the source with a trimmed name when it is valid',
    () async {
      stubActive([_source()]);
      when(
        () => repository.update(id: 1, name: 'Restaurante', colorValue: _color),
      ).thenAnswer((_) async => Success(_source()));

      final result = await updateIncomeSource(
        id: 1,
        name: ' Restaurante ',
        colorValue: _color,
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => repository.update(id: 1, name: 'Restaurante', colorValue: _color),
      ).called(1);
    },
  );

  test('should allow keeping its own name when the id matches', () async {
    stubActive([_source(), _source(id: 2, name: 'Pelotas')]);
    when(
      () => repository.update(id: 1, name: 'Restaurante', colorValue: _color),
    ).thenAnswer((_) async => Success(_source()));

    final result = await updateIncomeSource(
      id: 1,
      name: 'Restaurante',
      colorValue: _color,
    );

    expect(result.isSuccess, isTrue);
  });

  test('should fail when the name is empty', () async {
    stubActive([_source()]);

    final result = await updateIncomeSource(
      id: 1,
      name: ' ',
      colorValue: _color,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'name.empty',
      ),
    );
  });

  test('should fail when the name is longer than 40 characters', () async {
    stubActive([_source()]);

    final result = await updateIncomeSource(
      id: 1,
      name: 'a' * 41,
      colorValue: _color,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'name.tooLong',
      ),
    );
  });

  test('should fail when another active source has the same name', () async {
    stubActive([_source(), _source(id: 2, name: 'Pelotas')]);

    final result = await updateIncomeSource(
      id: 1,
      name: 'pelotas',
      colorValue: _color,
    );

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'name.duplicate',
      ),
    );
    verifyNever(
      () => repository.update(
        id: any(named: 'id'),
        name: any(named: 'name'),
        colorValue: any(named: 'colorValue'),
      ),
    );
  });

  test(
    'should return the repository failure when the source does not exist',
    () async {
      stubActive(const []);
      when(
        () => repository.update(id: 9, name: 'Restaurante', colorValue: _color),
      ).thenAnswer((_) async => const Err(NotFoundFailure()));

      final result = await updateIncomeSource(
        id: 9,
        name: 'Restaurante',
        colorValue: _color,
      );

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );
}
