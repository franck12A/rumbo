import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';
import 'package:rumbo/features/income_sources/domain/usecases/create_income_source.dart';

class _MockIncomeSourceRepository extends Mock
    implements IncomeSourceRepository;

const _color = 0xFF2E7D32;

IncomeSource _source({
  int id = 1,
  String name = 'Restaurante',
  int colorValue = _color,
}) => IncomeSource(
  id: id,
  name: name,
  colorValue: colorValue,
  createdAt: DateTime(2026),
);

void main() {
  late _MockIncomeSourceRepository repository;
  late CreateIncomeSource createIncomeSource;

  setUp(() {
    repository = _MockIncomeSourceRepository();
    createIncomeSource = CreateIncomeSource(repository);
  });

  void stubActive(List<IncomeSource> sources) {
    when(() => repository.watchActive())
        .thenAnswer((_) => Stream.value(sources));
  }

  test(
    'should create the source with a trimmed name when the input is valid',
    () async {
      stubActive(const []);
      when(() => repository.create(name: 'Restaurante', colorValue: _color))
          .thenAnswer((_) async => Success(_source()));

      final result = await createIncomeSource(
        name: '  Restaurante  ',
        colorValue: _color,
      );

      expect(result.valueOrNull?.name, 'Restaurante');
      verify(() => repository.create(name: 'Restaurante', colorValue: _color))
          .called(1);
    },
  );

  test('should accept a name with exactly 40 characters', () async {
    stubActive(const []);
    final name = 'a' * 40;
    when(() => repository.create(name: name, colorValue: _color))
        .thenAnswer((_) async => Success(_source(name: name)));

    final result = await createIncomeSource(name: name, colorValue: _color);

    expect(result.isSuccess, isTrue);
  });

  test('should fail when the name is empty', () async {
    stubActive(const []);

    final result = await createIncomeSource(name: '   ', colorValue: _color);

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'name.empty',
      ),
    );
    verifyNever(
      () => repository.create(
        name: any(named: 'name'),
        colorValue: any(named: 'colorValue'),
      ),
    );
  });

  test('should fail when the name is longer than 40 characters', () async {
    stubActive(const []);

    final result = await createIncomeSource(name: 'a' * 41, colorValue: _color);

    expect(
      result.failureOrNull,
      isA<ValidationFailure>().having(
        (failure) => failure.field,
        'field',
        'name.tooLong',
      ),
    );
    verifyNever(
      () => repository.create(
        name: any(named: 'name'),
        colorValue: any(named: 'colorValue'),
      ),
    );
  });

  test(
    'should fail when an active source has the same name in another case',
    () async {
      stubActive([_source()]);

      final result = await createIncomeSource(
        name: 'reSTAUrantE',
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
    },
  );

  test('should return the repository failure when the insert fails', () async {
    stubActive(const []);
    const failure = DatabaseFailure(message: 'insert failed');
    when(() => repository.create(name: 'Restaurante', colorValue: _color))
        .thenAnswer((_) async => const Err(failure));

    final result = await createIncomeSource(
      name: 'Restaurante',
      colorValue: _color,
    );

    expect(result.failureOrNull, same(failure));
  });
}
