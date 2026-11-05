import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_filter.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';
import 'package:rumbo/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:rumbo/features/transactions/domain/usecases/watch_transactions.dart';

class _MockTransactionRepository extends Mock implements TransactionRepository;

void main() {
  test(
    'should emit the views streamed by the repository for the filter',
    () async {
      final repository = _MockTransactionRepository();
      final filter = TransactionFilter(
        from: CalendarDate(year: 2026, month: 11, day: 1),
        type: TransactionType.income,
      );
      final view = TransactionView(
        transaction: Transaction(
          id: 1,
          type: TransactionType.income,
          amount: const Money.fromCents(150000),
          date: CalendarDate(year: 2026, month: 11, day: 5),
          incomeSourceId: 1,
          createdAt: DateTime.utc(2026, 11, 5, 12),
        ),
        source: const ReferenceInfo(
          id: 1,
          name: 'Restaurante',
          colorValue: 0xFFEF6C00,
          isArchived: false,
        ),
      );
      when(() => repository.watchFiltered(filter))
          .thenAnswer((_) => Stream.value([view]));

      final views = await WatchTransactions(repository)(filter).first;

      expect(views, [view]);
      verify(() => repository.watchFiltered(filter)).called(1);
    },
  );
}
