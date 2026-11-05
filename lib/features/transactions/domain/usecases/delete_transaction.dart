import 'package:rumbo/core/errors/result.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';

/// Deletes a movement and returns it, so the caller can offer an undo.
final class DeleteTransaction {
  const DeleteTransaction(this._repository);

  final TransactionRepository _repository;

  Future<Result<Transaction>> call(int id) => _repository.delete(id);
}
