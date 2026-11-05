import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/repositories/income_source_repository.dart';

/// Streams the archived income sources for the "Archivadas" tab.
final class WatchArchivedIncomeSources {
  const WatchArchivedIncomeSources(this._repository);

  final IncomeSourceRepository _repository;

  Stream<List<IncomeSource>> call() => _repository.watchArchived();
}
