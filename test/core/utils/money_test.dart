import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/utils/money.dart';

void main() {
  group('Money.fromDecimalString', () {
    test('should parse whole pesos when the input has no separators', () {
      expect(Money.fromDecimalString('10000').cents, 1000000);
    });

    test(
      'should parse an es_AR amount when it has thousand and decimal marks',
      () {
        expect(Money.fromDecimalString('10.000,50').cents, 1000050);
      },
    );

    test('should parse the thousand separator when there are no decimals', () {
      expect(Money.fromDecimalString('10.000').cents, 1000000);
    });

    test('should parse an amount with one decimal digit', () {
      expect(Money.fromDecimalString('10.000,5').cents, 1000050);
    });

    test('should parse a negative amount', () {
      expect(Money.fromDecimalString('-1.234,56').cents, -123456);
    });

    test('should trim surrounding whitespace', () {
      expect(Money.fromDecimalString('  1.500,00 ').cents, 150000);
    });

    for (final invalid in [
      '',
      '   ',
      'abc',
      '10,000.50',
      '10.00.000',
      '10.000,505',
      '.500',
      '10,',
      r'$ 10.000,00',
      '1 000',
    ]) {
      test('should throw when the input is "$invalid"', () {
        expect(() => Money.fromDecimalString(invalid), throwsFormatException);
      });
    }
  });

  group('arithmetic', () {
    test('should add two amounts when both are positive', () {
      const ten = Money.fromCents(1000);
      const five = Money.fromCents(500);

      expect(ten + five, const Money.fromCents(1500));
    });

    test('should subtract an amount when the result stays positive', () {
      const ten = Money.fromCents(1000);
      const five = Money.fromCents(500);

      expect(ten - five, const Money.fromCents(500));
    });

    test('should keep the sign when the subtraction goes below zero', () {
      const five = Money.fromCents(500);

      expect(five - const Money.fromCents(1000), const Money.fromCents(-500));
    });

    test('should negate an amount when applying unary minus', () {
      expect(-const Money.fromCents(750), const Money.fromCents(-750));
    });

    test(
      'should return a positive amount when taking abs of a negative one',
      () {
        expect(const Money.fromCents(-750).abs(), const Money.fromCents(750));
      },
    );

    test('should keep zero as abs of zero', () {
      expect(Money.zero.abs(), Money.zero);
    });
  });

  group('comparison', () {
    test('should order amounts by their cents', () {
      const five = Money.fromCents(500);
      const ten = Money.fromCents(1000);

      expect(five < ten, isTrue);
      expect(five <= ten, isTrue);
      expect(ten > five, isTrue);
      expect(ten >= five, isTrue);
      expect(five.compareTo(ten), lessThan(0));
    });

    test('should be equal when both have the same cents', () {
      expect(const Money.fromCents(1234), const Money.fromCents(1234));
    });

    test('should have the same hash code when both have the same cents', () {
      expect(
        const Money.fromCents(1234).hashCode,
        const Money.fromCents(1234).hashCode,
      );
    });

    test('should not be equal when cents differ', () {
      expect(const Money.fromCents(1234), isNot(const Money.fromCents(1235)));
    });

    test('should report positivity and negativity', () {
      expect(const Money.fromCents(1).isPositive, isTrue);
      expect(const Money.fromCents(-1).isPositive, isFalse);
      expect(const Money.fromCents(-1).isNegative, isTrue);
      expect(Money.zero.isZero, isTrue);
      expect(const Money.fromCents(1).isZero, isFalse);
    });
  });

  group('format', () {
    test('should format thousands and decimals in es_AR', () {
      expect(const Money.fromCents(1000000).format(), r'$ 10.000,00');
    });

    test('should format zero with two decimals', () {
      expect(Money.zero.format(), r'$ 0,00');
    });

    test('should pad the cents when they are a single digit', () {
      expect(const Money.fromCents(1000005).format(), r'$ 10.000,05');
    });

    test('should format negative amounts with the sign after the symbol', () {
      expect(const Money.fromCents(-123456).format(), r'$ -1.234,56');
    });
  });
}
