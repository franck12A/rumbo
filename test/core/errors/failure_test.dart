import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/errors/failure.dart';

void main() {
  group('Failure', () {
    test('should expose message and cause when they are provided', () {
      final cause = StateError('boom');
      final failure = DatabaseFailure(message: 'query failed', cause: cause);

      expect(failure.message, 'query failed');
      expect(failure.cause, same(cause));
    });

    test('should leave message and cause empty when they are omitted', () {
      const failure = DatabaseFailure();

      expect(failure.message, isNull);
      expect(failure.cause, isNull);
    });

    test('should keep the field when it is a validation failure', () {
      const failure = ValidationFailure(field: 'amount');

      expect(failure, isA<Failure>());
      expect(failure.field, 'amount');
    });

    test('should keep the resource when it is a not found failure', () {
      const failure = NotFoundFailure(resource: 'Goal');

      expect(failure, isA<Failure>());
      expect(failure.resource, 'Goal');
    });

    test('should include type and message in toString', () {
      const failure = DatabaseFailure(message: 'query failed');

      expect(failure.toString(), 'DatabaseFailure: query failed');
    });

    test(
      'should include only the type in toString when message is omitted',
      () {
        expect(const NotFoundFailure().toString(), 'NotFoundFailure');
        expect(const ValidationFailure().toString(), 'ValidationFailure');
      },
    );

    test('should keep its own type when each variant is created', () {
      expect(const DatabaseFailure(), isA<DatabaseFailure>());
      expect(const ValidationFailure(), isA<ValidationFailure>());
      expect(const NotFoundFailure(), isA<NotFoundFailure>());
      expect(const DatabaseFailure(), isNot(isA<ValidationFailure>()));
    });
  });
}
