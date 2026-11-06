import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rumbo/app/reference_options_provider.dart';
import 'package:rumbo/core/l10n/strings_es_ar.dart';
import 'package:rumbo/core/utils/calendar_date.dart';
import 'package:rumbo/core/utils/money.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_type.dart';
import 'package:rumbo/features/transactions/domain/entities/transaction_view.dart';
import 'package:rumbo/features/transactions/domain/lookups/reference_info.dart';
import 'package:rumbo/features/transactions/presentation/transaction_draft.dart';
import 'package:rumbo/features/transactions/presentation/transaction_formatters.dart';
import 'package:rumbo/features/transactions/presentation/widgets/no_active_references_notice.dart';
import 'package:rumbo/features/transactions/presentation/widgets/transaction_reference_dropdown.dart';

/// Create/edit form. It only collects the draft: the use case validates it and
/// returns the message to show when the input is rejected.
class TransactionFormDialog extends ConsumerStatefulWidget {
  const TransactionFormDialog({
    required this.initialType,
    required this.onSubmit,
    required this.onOpenIncomeSources,
    required this.onOpenCategories,
    this.view,
    super.key,
  });

  final TransactionType initialType;
  final TransactionView? view;
  final Future<String?> Function(TransactionDraft draft) onSubmit;
  final VoidCallback onOpenIncomeSources;
  final VoidCallback onOpenCategories;

  @override
  ConsumerState<TransactionFormDialog> createState() =>
      _TransactionFormDialogState();
}

class _TransactionFormDialogState extends ConsumerState<TransactionFormDialog> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionType _type;
  late CalendarDate _date;
  int? _incomeSourceId;
  int? _categoryId;
  String? _amountError;
  String? _formError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.view?.transaction;
    _type = widget.initialType;
    _amountController = TextEditingController(
      text: transaction == null
          ? ''
          : TransactionFormatters.amountInput(transaction.amount),
    );
    _noteController = TextEditingController(text: transaction?.note ?? '');
    _date = transaction?.date ?? CalendarDate.fromDateTime(DateTime.now());
    _incomeSourceId = transaction?.incomeSourceId;
    _categoryId = transaction?.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _changeType(Set<TransactionType> selection) {
    final type = selection.first;
    if (type == _type) {
      return;
    }
    setState(() {
      _type = type;
      // The reference belongs to the previous type, so it cannot be kept.
      _incomeSourceId = null;
      _categoryId = null;
      _formError = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.toDateTime(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: AppStrings.transactionDateLabel,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _date = CalendarDate.fromDateTime(picked));
  }

  Money? _readAmount() {
    try {
      final amount = Money.fromDecimalString(_amountController.text);
      if (!amount.isPositive) {
        setState(() {
          _amountError = AppStrings.transactionAmountNotPositiveError;
        });
        return null;
      }
      return amount;
    } on FormatException {
      setState(() => _amountError = AppStrings.transactionAmountInvalidError);
      return null;
    }
  }

  Future<void> _submit() async {
    setState(() {
      _amountError = null;
      _formError = null;
    });
    final amount = _readAmount();
    if (amount == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    final errorMessage = await widget.onSubmit(
      TransactionDraft(
        type: _type,
        amount: amount,
        date: _date,
        note: _noteController.text,
        incomeSourceId: _incomeSourceId,
        categoryId: _categoryId,
      ),
    );
    if (!mounted) {
      return;
    }
    if (errorMessage != null) {
      setState(() {
        _isSubmitting = false;
        _formError = errorMessage;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  List<ReferenceInfo> _optionsFor(
    ReferenceInfo? current,
    List<ReferenceInfo> active,
  ) {
    if (current == null || active.any((option) => option.id == current.id)) {
      return active;
    }
    return [...active, current];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourcesState = ref.watch(activeIncomeSourceOptionsProvider);
    final categoriesState = ref.watch(activeCategoryOptionsProvider);
    final isLoading = sourcesState.isLoading || categoriesState.isLoading;
    final activeSources = sourcesState.asData?.value ?? const <ReferenceInfo>[];
    final activeCategories =
        categoriesState.asData?.value ?? const <ReferenceInfo>[];
    final isIncome = _type == TransactionType.income;
    final options = isIncome
        ? _optionsFor(widget.view?.source, activeSources)
        : _optionsFor(widget.view?.category, activeCategories);

    return AlertDialog(
      title: Text(
        widget.view == null
            ? AppStrings.transactionCreateTitle
            : AppStrings.transactionEditTitle,
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(AppStrings.transactionTypeIncome),
                    icon: Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(AppStrings.transactionTypeExpense),
                    icon: Icon(Icons.arrow_upward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: _isSubmitting ? null : _changeType,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                enabled: !_isSubmitting,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: AppStrings.transactionAmountLabel,
                  hintText: AppStrings.transactionAmountHint,
                  errorText: _amountError,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _pickDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        AppStrings.transactionDateValue(
                          TransactionFormatters.dayHeader(_date),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const LinearProgressIndicator()
              else if (options.isEmpty)
                NoActiveReferencesNotice(
                  title: isIncome
                      ? AppStrings.transactionNoIncomeSourcesTitle
                      : AppStrings.transactionNoCategoriesTitle,
                  body: isIncome
                      ? AppStrings.transactionNoIncomeSourcesBody
                      : AppStrings.transactionNoCategoriesBody,
                  actionLabel: isIncome
                      ? AppStrings.transactionGoToIncomeSources
                      : AppStrings.transactionGoToCategories,
                  onGoTo: isIncome
                      ? widget.onOpenIncomeSources
                      : widget.onOpenCategories,
                )
              else
                TransactionReferenceDropdown(
                  key: ValueKey(_type),
                  label: isIncome
                      ? AppStrings.transactionSourceLabel
                      : AppStrings.transactionCategoryLabel,
                  options: options,
                  selectedId: isIncome ? _incomeSourceId : _categoryId,
                  onChanged: _isSubmitting
                      ? null
                      : (id) => setState(() {
                          if (isIncome) {
                            _incomeSourceId = id;
                          } else {
                            _categoryId = id;
                          }
                        }),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                enabled: !_isSubmitting,
                maxLength: 200,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: AppStrings.transactionNoteLabel,
                ),
              ),
              if (_formError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formError!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancelAction),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: const Text(AppStrings.saveAction),
        ),
      ],
    );
  }
}
