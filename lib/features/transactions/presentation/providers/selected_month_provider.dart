import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rumbo/core/utils/calendar_date.dart';

part 'selected_month_provider.g.dart';

/// A year and month pair selected on the transactions screen.
@immutable
final class SelectedMonth {
  const SelectedMonth({required this.year, required this.month});

  factory SelectedMonth.fromDateTime(DateTime dateTime) =>
      SelectedMonth(year: dateTime.year, month: dateTime.month);

  final int year;
  final int month;

  CalendarDate get firstDay =>
      CalendarDate.firstOfMonth(year: year, month: month);

  CalendarDate get lastDay =>
      CalendarDate.lastOfMonth(year: year, month: month);

  SelectedMonth get previous => month == 1
      ? SelectedMonth(year: year - 1, month: 12)
      : SelectedMonth(year: year, month: month - 1);

  SelectedMonth get next => month == 12
      ? SelectedMonth(year: year + 1, month: 1)
      : SelectedMonth(year: year, month: month + 1);

  bool isSameAs(SelectedMonth other) =>
      other.year == year && other.month == month;

  @override
  bool operator ==(Object other) =>
      other is SelectedMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => '$year-$month';
}

/// Month shown on the transactions screen; starts at the current month.
@riverpod
class SelectedMonthController extends _$SelectedMonthController {
  @override
  SelectedMonth build() => SelectedMonth.fromDateTime(DateTime.now());

  void goToPreviousMonth() => state = state.previous;

  void goToNextMonth() => state = state.next;

  void goToCurrentMonth() => state = SelectedMonth.fromDateTime(DateTime.now());
}
