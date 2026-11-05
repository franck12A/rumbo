import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';

/// Streams the active income sources for the list screen.
final class WatchActiveIncomeSources {
  const WatchActiveIncomeSources(this._repository);

  final IncomeSourceRepository _repository;

  Stream<List<IncomeSource>> call() => _repository.watchActive();
}
