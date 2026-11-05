import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/categories/domain/entities/category.dart';
import 'package:rumbo/features/categories/domain/repositories/category_repository.dart';
import 'package:rumbo/features/categories/domain/usecases/archive_category.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository;

Category _category({DateTime? archivedAt}) => Category(
  id: 1,
  name: 'Materiales',
  colorValue: 0xFF6A1B9A,
  createdAt: DateTime(2026),
  archivedAt: archivedAt,
);

void main() {
  late _MockCategoryRepository repository;
  late ArchiveCategory archiveCategory;

  setUp(() {
    repository = _MockCategoryRepository();
    archiveCategory = ArchiveCategory(repository);
  });

  test(
    'should return the archived category when the repository succeeds',
    () async {
      when(() => repository.archive(1)).thenAnswer(
        (_) async => Success(_category(archivedAt: DateTime(2026, 2))),
      );

      final result = await archiveCategory(1);

      expect(result.valueOrNull?.isArchived, isTrue);
      verify(() => repository.archive(1)).called(1);
    },
  );

  test(
    'should return the not found failure when the category does not exist',
    () async {
      when(() => repository.archive(9))
          .thenAnswer((_) async => const Err(NotFoundFailure()));

      final result = await archiveCategory(9);

      expect(result.failureOrNull, isA<NotFoundFailure>());
    },
  );
}
