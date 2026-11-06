import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/app/reference_options_provider.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';
import 'package:rumbo/features/transactions/presentation/transaction_draft.dart';
import 'package:rumbo/features/transactions/presentation/widgets/transaction_form_dialog.dart';

const _restaurante = ReferenceInfo(
  id: 1,
  name: 'Restaurante',
  colorValue: 0xFF2E7D32,
  isArchived: false,
);

const _comida = ReferenceInfo(
  id: 2,
  name: 'Comida',
  colorValue: 0xFFEF6C00,
  isArchived: false,
);

TransactionView _incomeView({int sourceId = 1, ReferenceInfo? source}) =>
    TransactionView(
      transaction: Transaction(
        id: 1,
        type: TransactionType.income,
        amount: const Money.fromCents(1000000),
        date: CalendarDate(year: 2026, month: 11, day: 5),
        note: 'Venta',
        incomeSourceId: sourceId,
        createdAt: DateTime.utc(2026, 11, 5, 12),
      ),
      source: source ?? _restaurante,
    );

Widget _buildDialog({
  List<ReferenceInfo> sources = const [],
  List<ReferenceInfo> categories = const [],
  TransactionType initialType = TransactionType.income,
  TransactionView? view,
  Future<String?> Function(TransactionDraft draft)? onSubmit,
}) => ProviderScope(
  overrides: [
    activeIncomeSourceOptionsProvider.overrideWith(
      (ref) => Stream.value(sources),
    ),
    activeCategoryOptionsProvider.overrideWith(
      (ref) => Stream.value(categories),
    ),
  ],
  child: MaterialApp(
    home: Scaffold(
      body: TransactionFormDialog(
        initialType: initialType,
        view: view,
        onSubmit: onSubmit ?? (draft) async => null,
        onOpenIncomeSources: () {},
        onOpenCategories: () {},
      ),
    ),
  ),
);

Future<void> _tapSave(WidgetTester tester) async {
  await tester.tap(find.text(AppStrings.saveAction));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('should reject an amount that is not a valid number', (
    tester,
  ) async {
    var submitted = false;

    await tester.pumpWidget(
      _buildDialog(
        sources: const [_restaurante],
        onSubmit: (draft) async {
          submitted = true;
          return null;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'abc');
    await _tapSave(tester);

    expect(find.text(AppStrings.transactionAmountInvalidError), findsOneWidget);
    expect(submitted, isFalse);
  });

  testWidgets('should reject a zero amount', (tester) async {
    var submitted = false;

    await tester.pumpWidget(
      _buildDialog(
        sources: const [_restaurante],
        onSubmit: (draft) async {
          submitted = true;
          return null;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '0');
    await _tapSave(tester);

    expect(
      find.text(AppStrings.transactionAmountNotPositiveError),
      findsOneWidget,
    );
    expect(submitted, isFalse);
  });

  testWidgets('should clear the selected reference when the type changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildDialog(
        sources: const [_restaurante],
        categories: const [_comida],
        view: _incomeView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Restaurante'), findsOneWidget);

    await tester.tap(find.text(AppStrings.transactionTypeExpense));
    await tester.pumpAndSettle();

    expect(find.text('Restaurante'), findsNothing);
    expect(find.text(AppStrings.transactionReferenceHint), findsOneWidget);
  });

  testWidgets('should keep an archived reference when editing', (tester) async {
    const archived = ReferenceInfo(
      id: 5,
      name: 'Vieja',
      colorValue: 0xFF546E7A,
      isArchived: true,
    );

    await tester.pumpWidget(
      _buildDialog(view: _incomeView(sourceId: 5, source: archived)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Vieja ${AppStrings.transactionArchivedSuffix}'),
      findsOneWidget,
    );
    expect(find.text(AppStrings.transactionNoIncomeSourcesTitle), findsNothing);
  });

  testWidgets(
    'should show a notice with a shortcut when there are no active sources',
    (tester) async {
      await tester.pumpWidget(_buildDialog());
      await tester.pumpAndSettle();

      expect(
        find.text(AppStrings.transactionNoIncomeSourcesTitle),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.transactionGoToIncomeSources),
        findsOneWidget,
      );
      expect(find.byType(SegmentedButton<TransactionType>), findsOneWidget);
    },
  );
}
