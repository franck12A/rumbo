import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';

/// Streams the transaction history for the list screen.
final class WatchTransactions {
  const WatchTransactions(this._repository);

  final TransactionRepository _repository;

  Stream<List<TransactionView>> call(TransactionFilter filter) =>
      _repository.watchFiltered(filter);
}
