import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/categories/domain/usecases/create_category.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository;

const _color = 0xFF6A1B9A;

Category _category({
  int id = 1,
  String name = 'Materiales',
  int colorValue = _color,
}) => Category(
  id: id,
  name: name,
  colorValue: colorValue,
  createdAt: DateTime(2026),
);

void main() {
  late _MockCategoryRepository repository;
  late CreateCategory createCategory;

  setUp(() {
    repository = _MockCategoryRepository();
    createCategory = CreateCategory(repository);
  });

  void stubActive(List<Category> categories) {
    when(() => repository.watchActive())
        .thenAnswer((_) => Stream.value(categories));
  }

  test(
    'should create the category with a trimmed name when the input is valid',
    () async {
      stubActive(const []);
      when(() => repository.create(name: 'Materiales', colorValue: _color))
          .thenAnswer((_) async => Success(_category()));

      final result = await createCategory(
        name: '  Materiales  ',
        colorValue: _color,
      );

      expect(result.valueOrNull?.name, 'Materiales');
      verify(() => repository.create(name: 'Materiales', colorValue: _color))
          .called(1);
    },
  );

  test('should accept a name with exactly 40 characters', () async {
    stubActive(const []);
    final name = 'a' * 40;
    when(() => repository.create(name: name, colorValue: _color))
        .thenAnswer((_) async => Success(_category(name: name)));

    final result = await createCategory(name: name, colorValue: _color);

    expect(result.isSuccess, isTrue);
  });

  test('should fail when the name is empty', () async {
    stubActive(const []);

    final result = await createCategory(name: '   ', colorValue: _color);

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

    final result = await createCategory(name: 'a' * 41, colorValue: _color);

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
    'should fail when an active category has the same name in another case',
    () async {
      stubActive([_category()]);

      final result = await createCategory(
        name: 'mATERIAlES',
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
    when(() => repository.create(name: 'Materiales', colorValue: _color))
        .thenAnswer((_) async => const Err(failure));

    final result = await createCategory(name: 'Materiales', colorValue: _color);

    expect(result.failureOrNull, same(failure));
  });
}
