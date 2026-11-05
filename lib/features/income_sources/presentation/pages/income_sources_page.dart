import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/income_sources/presentation/income_source_actions.dart';
import 'package:rumbo/features/income_sources/presentation/providers/income_source_providers.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_source_tile.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_sources_empty_state.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_sources_error_state.dart';

/// List of active income sources with create, edit and archive actions.
class IncomeSourcesPage extends ConsumerWidget {
  const IncomeSourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(activeIncomeSourcesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.incomeSourcesTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: () => showIncomeSourceFormDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.incomeSourcesAdd),
            ),
          ),
        ],
      ),
      body: sources.when(
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
      ),
    );
  }
}
