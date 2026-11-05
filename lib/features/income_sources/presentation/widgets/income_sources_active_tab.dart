import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/features/income_sources/presentation/income_source_actions.dart';
import 'package:rumbo/features/income_sources/presentation/providers/income_source_providers.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_source_tile.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_sources_empty_state.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_sources_error_state.dart';

/// Active tab of the income sources screen.
class IncomeSourcesActiveTab extends ConsumerWidget {
  const IncomeSourcesActiveTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(activeIncomeSourcesProvider);

    return sources.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => IncomeSourcesErrorState(
        onRetry: () => ref.invalidate(activeIncomeSourcesProvider),
      ),
      data: (sources) {
        if (sources.isEmpty) {
          return const IncomeSourcesEmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sources.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final source = sources[index];
            return IncomeSourceTile(
              source: source,
              onEdit: () =>
                  showIncomeSourceFormDialog(context, ref, source: source),
              onArchive: () =>
                  confirmAndArchiveIncomeSource(context, ref, source),
            );
          },
        );
      },
    );
  }
}
