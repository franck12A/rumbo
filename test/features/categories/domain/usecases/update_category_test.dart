import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/categories/domain/usecases/update_category.dart';

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
  late UpdateCategory updateCategory;

  setUp(() {
    repository = _MockCategoryRepository();
    updateCategory = UpdateCategory(repository);
  });

  void stubActive(List<Category> categories) {
    when(() => repository.watchActive())
        .thenAnswer((_) => Stream.value(categories));
  }

  test(
    'should update the category with a trimmed name when it is valid',
    () async {
      stubActive([_category()]);
      when(
        () => repository.update(id: 1, name: 'Insumos', colorValue: 0xFF1565C0),
      ).thenAnswer(
        (_) async =>
            Success(_category(name: 'Insumos', colorValue: 0xFF1565C0)),
      );

      final result = await updateCategory(
        id: 1,
        name: '  Insumos  ',
        colorValue: 0xFF1565C0,
      );

      expect(result.valueOrNull?.name, 'Insumos');
      expect(result.valueOrNull?.colorValue, 0xFF1565C0);
    },
  );

  test('should allow keeping its own name when the id matches', () async {
    stubActive([_category()]);
    when(() => repository.update(id: 1, name: 'Materiales', colorValue: _color))
        .thenAnswer((_) async => Success(_category()));

    final result = await updateCategory(
      id: 1,
      name: 'Materiales',
      colorValue: _color,
    );

    expect(result.isSuccess, isTrue);
  });

  test('should fail when the name is empty', () async {
    final result = await updateCategory(id: 1, name: ' ', colorValue: _color);

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
    final result = await updateCategory(
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

  test('should fail when another active category has the same name', () async {
    stubActive([_category(), _category(id: 2, name: 'Comida')]);

    final result = await updateCategory(
      id: 1,
      name: 'comida',
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
  });

  test(
    'should return the repository failure when the category does not exist',
    () async {
      stubActive(const []);
      when(() => repository.update(id: 9, name: 'Insumos', colorValue: _color))
          .thenAnswer((_) async => const Err(NotFoundFailure()));

      final result = await updateCategory(
        id: 9,
        name: 'Insumos',
        colorValue: _color,
      );

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );
}
