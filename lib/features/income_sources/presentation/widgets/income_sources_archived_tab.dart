import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/features/income_sources/presentation/income_source_actions.dart';
import 'package:rumbo/features/income_sources/presentation/providers/income_source_providers.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/archived_income_source_tile.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_sources_archived_empty_state.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_sources_error_state.dart';

/// Archived tab of the income sources screen, with the restore action.
class IncomeSourcesArchivedTab extends ConsumerWidget {
  const IncomeSourcesArchivedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(archivedIncomeSourcesProvider);

    return sources.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => IncomeSourcesErrorState(
        onRetry: () => ref.invalidate(archivedIncomeSourcesProvider),
      ),
      data: (sources) {
        if (sources.isEmpty) {
          return const IncomeSourcesArchivedEmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sources.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final source = sources[index];
            return ArchivedIncomeSourceTile(
              source: source,
              onRestore: () =>
                  restoreArchivedIncomeSource(context, ref, source),
            );
          },
        );
      },
    );
  }
}
