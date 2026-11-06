import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/features/transactions/presentation/providers/selected_month_provider.dart';

class _FixedSelectedMonth extends SelectedMonthController {
  _FixedSelectedMonth(this.initial);

  final SelectedMonth initial;

  @override
  SelectedMonth build() => initial;
}

ProviderContainer _containerWith(SelectedMonth month) {
  final container = ProviderContainer(
    overrides: [
      selectedMonthControllerProvider.overrideWith(
        () => _FixedSelectedMonth(month),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('should start at the current month', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final now = DateTime.now();

    expect(
      container.read(selectedMonthControllerProvider),
      SelectedMonth(year: now.year, month: now.month),
    );
  });

  test('should move to the previous month when it is not January', () {
    final container = _containerWith(
      const SelectedMonth(year: 2026, month: 11),
    );

    container
        .read(selectedMonthControllerProvider.notifier)
        .goToPreviousMonth();

    expect(
      container.read(selectedMonthControllerProvider),
      const SelectedMonth(year: 2026, month: 10),
    );
  });

  test('should cross to December of the previous year from January', () {
    final container = _containerWith(const SelectedMonth(year: 2026, month: 1));

    container
        .read(selectedMonthControllerProvider.notifier)
        .goToPreviousMonth();

    expect(
      container.read(selectedMonthControllerProvider),
      const SelectedMonth(year: 2025, month: 12),
    );
  });

  test('should move to the next month when it is not December', () {
    final container = _containerWith(
      const SelectedMonth(year: 2026, month: 11),
    );

    container.read(selectedMonthControllerProvider.notifier).goToNextMonth();

    expect(
      container.read(selectedMonthControllerProvider),
      const SelectedMonth(year: 2026, month: 12),
    );
  });

  test('should cross to January of the next year from December', () {
    final container = _containerWith(
      const SelectedMonth(year: 2026, month: 12),
    );

    container.read(selectedMonthControllerProvider.notifier).goToNextMonth();

    expect(
      container.read(selectedMonthControllerProvider),
      const SelectedMonth(year: 2027, month: 1),
    );
  });

  test('should go back to the current month', () {
    final container = _containerWith(const SelectedMonth(year: 2020, month: 3));

    container.read(selectedMonthControllerProvider.notifier).goToCurrentMonth();

    final now = DateTime.now();
    expect(
      container.read(selectedMonthControllerProvider),
      SelectedMonth(year: now.year, month: now.month),
    );
  });

  test('should compute the first and last day of the month', () {
    const month = SelectedMonth(year: 2024, month: 2);

    expect(month.firstDay.value, 20240201);
    expect(month.lastDay.value, 20240229);
  });
}
