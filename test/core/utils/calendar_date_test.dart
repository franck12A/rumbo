import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/utils/calendar_date.dart';

void main() {
  group('validation', () {
    test('should accept February 29 in a leap year', () {
      expect(CalendarDate(year: 2024, month: 2, day: 29).value, 20240229);
    });

    test('should reject February 29 in a non leap year', () {
      expect(
        () => CalendarDate(year: 2023, month: 2, day: 29),
        throwsArgumentError,
      );
    });

    test('should reject a month outside 1..12', () {
      expect(
        () => CalendarDate(year: 2026, month: 13, day: 1),
        throwsArgumentError,
      );
      expect(
        () => CalendarDate(year: 2026, month: 0, day: 1),
        throwsArgumentError,
      );
    });

    test('should reject day 0', () {
      expect(
        () => CalendarDate(year: 2026, month: 11, day: 0),
        throwsArgumentError,
      );
    });
  });

  group('ordering', () {
    test('should order October 31 before November 1', () {
      final october = CalendarDate(year: 2026, month: 10, day: 31);
      final november = CalendarDate(year: 2026, month: 11, day: 1);

      expect(october.isBefore(november), isTrue);
      expect(november.isAfter(october), isTrue);
      expect(october.compareTo(november), lessThan(0));
      expect(october == CalendarDate(year: 2026, month: 10, day: 31), isTrue);
    });

    test('should order across years', () {
      final december = CalendarDate(year: 2026, month: 12, day: 31);
      final january = CalendarDate(year: 2027, month: 1, day: 1);

      expect(december.isBefore(january), isTrue);
    });
  });

  group('month limits', () {
    test('should return the first and last day of a month', () {
      expect(CalendarDate.firstOfMonth(year: 2026, month: 2).day, 1);
      expect(CalendarDate.lastOfMonth(year: 2026, month: 2).day, 28);
      expect(CalendarDate.lastOfMonth(year: 2024, month: 2).day, 29);
      expect(CalendarDate.lastOfMonth(year: 2026, month: 4).day, 30);
      expect(CalendarDate.lastOfMonth(year: 2026, month: 12).day, 31);
    });
  });

  group('integer conversion', () {
    test('should convert to and from yyyymmdd', () {
      final date = CalendarDate(year: 2026, month: 11, day: 5);

      expect(date.value, 20261105);
      expect(CalendarDate.fromInt(20261105), date);
    });

    test('should round trip through DateTime ignoring the time', () {
      final date = CalendarDate.fromDateTime(DateTime(2026, 11, 5, 23, 59));

      expect(date.value, 20261105);
      expect(date.toDateTime(), DateTime(2026, 11, 5));
    });
  });
}
