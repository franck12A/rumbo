import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/categories/domain/usecases/restore_category.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository;

Category _category({
  int id = 1,
  String name = 'Materiales',
  bool archived = true,
}) => Category(
  id: id,
  name: name,
  colorValue: 0xFF6A1B9A,
  createdAt: DateTime(2026),
  archivedAt: archived ? DateTime(2026, 2) : null,
);

void main() {
  late _MockCategoryRepository repository;
  late RestoreCategory restoreCategory;

  setUp(() {
    repository = _MockCategoryRepository();
    restoreCategory = RestoreCategory(repository);
  });

  void stubActive(List<Category> categories) {
    when(() => repository.watchActive())
        .thenAnswer((_) => Stream.value(categories));
  }

  test('should return the restored category when the name is free', () async {
    stubActive(const []);
    when(() => repository.getById(1))
        .thenAnswer((_) async => Success(_category()));
    when(() => repository.restore(1))
        .thenAnswer((_) async => Success(_category(archived: false)));

    final result = await restoreCategory(1);

    expect(result.valueOrNull?.isArchived, isFalse);
    verify(() => repository.restore(1)).called(1);
  });

  test(
    'should return the not found failure when the category does not exist',
    () async {
      when(() => repository.getById(9))
          .thenAnswer((_) async => const Err(NotFoundFailure()));

      final result = await restoreCategory(9);

      expect(result.failureOrNull, isA<NotFoundFailure>());
      verifyNever(() => repository.restore(9));
    },
  );

  test(
    'should reject the restore when an active category uses the name',
    () async {
      stubActive([_category(id: 2, name: 'materiales', archived: false)]);
      when(() => repository.getById(1))
          .thenAnswer((_) async => Success(_category()));

      final result = await restoreCategory(1);

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
