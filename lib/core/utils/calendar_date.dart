import 'package:meta/meta.dart';

/// A calendar day without time or timezone.
///
/// Transaction dates are stored as `yyyymmdd` integers so range queries never
/// depend on the device timezone. Only `fromDateTime` and `toDateTime` touch
/// [DateTime], for boundaries with the rest of the framework.
@immutable
final class CalendarDate implements Comparable<CalendarDate> {
  CalendarDate({required this.year, required this.month, required this.day}) {
    if (year < 1 || year > 9999) {
      throw ArgumentError.value(
        year,
        'year',
        'Year must be between 1 and 9999',
      );
    }
    _checkMonth(month);
    final lastDay = daysInMonth(year, month);
    if (day < 1 || day > lastDay) {
      throw ArgumentError.value(
        day,
        'day',
        'Day must be between 1 and $lastDay for $year-$month',
      );
    }
  }

  /// Reads the `yyyymmdd` representation used by the database.
  factory CalendarDate.fromInt(int value) => CalendarDate(
    year: value ~/ 10000,
    month: value ~/ 100 % 100,
    day: value % 100,
  );

  /// Reads the calendar day of [dateTime], ignoring its time and timezone.
  factory CalendarDate.fromDateTime(DateTime dateTime) => CalendarDate(
    year: dateTime.year,
    month: dateTime.month,
    day: dateTime.day,
  );

  factory CalendarDate.firstOfMonth({required int year, required int month}) =>
      CalendarDate(year: year, month: month, day: 1);

  factory CalendarDate.lastOfMonth({required int year, required int month}) =>
      CalendarDate(year: year, month: month, day: daysInMonth(year, month));

  static bool isLeapYear(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  static int daysInMonth(int year, int month) {
    _checkMonth(month);
    return switch (month) {
      2 => isLeapYear(year) ? 29 : 28,
      4 || 6 || 9 || 11 => 30,
      _ => 31,
    };
  }

  static void _checkMonth(int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(
        month,
        'month',
        'Month must be between 1 and 12',
      );
    }
  }

  final int year;
  final int month;
  final int day;

  /// `yyyymmdd` value, e.g. `20261105` for November 5th, 2026.
  int get value => year * 10000 + month * 100 + day;

  bool isBefore(CalendarDate other) => compareTo(other) < 0;

  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  /// Midnight of this day in the local timezone.
  DateTime toDateTime() => DateTime(year, month, day);

  @override
  int compareTo(CalendarDate other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
