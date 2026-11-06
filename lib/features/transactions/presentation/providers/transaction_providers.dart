import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rumbo/app/di.dart';
import 'package:rumbo/features/transactions/domain/entities/month_summary.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/domain/usecases/add_transaction.dart';
import 'package:rumbo/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:rumbo/features/transactions/domain/usecases/get_month_summary.dart';
import 'package:rumbo/features/transactions/domain/usecases/update_transaction.dart';
import 'package:rumbo/features/transactions/domain/usecases/watch_transactions.dart';
import 'package:rumbo/features/transactions/presentation/providers/selected_month_provider.dart';

part 'transaction_providers.g.dart';

@Riverpod(keepAlive: true)
AddTransaction addTransaction(Ref ref) => AddTransaction(
  ref.watch(transactionRepositoryProvider),
  ref.watch(incomeSourceLookupProvider),
  ref.watch(categoryLookupProvider),
);

@Riverpod(keepAlive: true)
UpdateTransaction updateTransaction(Ref ref) => UpdateTransaction(
  ref.watch(transactionRepositoryProvider),
  ref.watch(incomeSourceLookupProvider),
  ref.watch(categoryLookupProvider),
);

@Riverpod(keepAlive: true)
DeleteTransaction deleteTransaction(Ref ref) =>
    DeleteTransaction(ref.watch(transactionRepositoryProvider));

@Riverpod(keepAlive: true)
WatchTransactions watchTransactions(Ref ref) =>
    WatchTransactions(ref.watch(transactionRepositoryProvider));

@Riverpod(keepAlive: true)
GetMonthSummary getMonthSummary(Ref ref) =>
    GetMonthSummary(ref.watch(transactionRepositoryProvider));

/// Movements of the selected month, newest first.
@riverpod
Stream<List<TransactionView>> monthTransactions(Ref ref) {
  final month = ref.watch(selectedMonthControllerProvider);
  return ref.watch(watchTransactionsProvider)(
    TransactionFilter(from: month.firstDay, to: month.lastDay),
  );
}

/// Totals and breakdowns of the selected month.
@riverpod
Future<MonthSummary> monthSummary(Ref ref) {
  final month = ref.watch(selectedMonthControllerProvider);
  return ref.watch(getMonthSummaryProvider)(
    year: month.year,
    month: month.month,
  );
}
