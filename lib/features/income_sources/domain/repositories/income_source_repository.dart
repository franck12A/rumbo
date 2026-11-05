import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';

/// Persistence boundary for income sources, implemented in `data/`.
abstract interface class IncomeSourceRepository {
  /// Emits the active sources, ordered by name, every time they change.
  Stream<List<IncomeSource>> watchActive();

  Future<Result<IncomeSource>> getById(int id);

  Future<Result<IncomeSource>> create({
    required String name,
    required int colorValue,
  });

  Future<Result<IncomeSource>> update({
    required int id,
    required String name,
    required int colorValue,
  });

  Future<Result<IncomeSource>> archive(int id);

  Future<Result<IncomeSource>> restore(int id);
}
