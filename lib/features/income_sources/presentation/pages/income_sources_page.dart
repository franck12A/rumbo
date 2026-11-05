import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/features/income_sources/presentation/income_source_actions.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_sources_active_tab.dart';
import 'package:rumbo/features/income_sources/presentation/widgets/income_sources_archived_tab.dart';

/// Income sources screen: active list plus the archived one.
class IncomeSourcesPage extends ConsumerWidget {
  const IncomeSourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(text: AppStrings.activeTabLabel),
              Tab(text: AppStrings.archivedTabLabel),
            ],
          ),
        ),
        body: const TabBarView(
          children: [IncomeSourcesActiveTab(), IncomeSourcesArchivedTab()],
        ),
      ),
    );
  }
}
