import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rumbo/app/di.dart';
import 'package:rumbo/features/income_sources/domain/entities/income_source.dart';
import 'package:rumbo/features/income_sources/domain/usecases/archive_income_source.dart';
import 'package:rumbo/features/income_sources/domain/usecases/create_income_source.dart';
import 'package:rumbo/features/income_sources/domain/usecases/restore_income_source.dart';
import 'package:rumbo/features/income_sources/domain/usecases/update_income_source.dart';
import 'package:rumbo/features/income_sources/domain/usecases/watch_active_income_sources.dart';

part 'income_source_providers.g.dart';

@Riverpod(keepAlive: true)
CreateIncomeSource createIncomeSource(Ref ref) =>
    CreateIncomeSource(ref.watch(incomeSourceRepositoryProvider));

@Riverpod(keepAlive: true)
UpdateIncomeSource updateIncomeSource(Ref ref) =>
    UpdateIncomeSource(ref.watch(incomeSourceRepositoryProvider));

@Riverpod(keepAlive: true)
ArchiveIncomeSource archiveIncomeSource(Ref ref) =>
    ArchiveIncomeSource(ref.watch(incomeSourceRepositoryProvider));

@Riverpod(keepAlive: true)
RestoreIncomeSource restoreIncomeSource(Ref ref) =>
    RestoreIncomeSource(ref.watch(incomeSourceRepositoryProvider));

@Riverpod(keepAlive: true)
WatchActiveIncomeSources watchActiveIncomeSources(Ref ref) =>
    WatchActiveIncomeSources(ref.watch(incomeSourceRepositoryProvider));

/// Active sources shown on the list screen; rebuilds on every database change.
@riverpod
Stream<List<IncomeSource>> activeIncomeSources(Ref ref) =>
    ref.watch(watchActiveIncomeSourcesProvider)();
