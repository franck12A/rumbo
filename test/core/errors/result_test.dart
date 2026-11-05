import 'package:flutter_test/flutter_test.dart';
import 'package:rumbo/core/errors/failure.dart';
import 'package:rumbo/core/errors/result.dart';

void main() {
  group('Result', () {
    test('should be a success when built with Result.success', () {
      const result = Result<int>.success(42);

      expect(result, isA<Success<int>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('should be a failure when built with Result.failure', () {
      const result = Result<int>.failure(DatabaseFailure());

      expect(result, isA<Err<int>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
    });

    test('should expose the value when it is a success', () {
      const result = Result<String>.success('ok');

      expect(result.valueOrNull, 'ok');
      expect(result.failureOrNull, isNull);
    });

    test('should expose the failure when it is an error', () {
      const failure = ValidationFailure(field: 'amount');

      const result = Result<String>.failure(failure);

      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, same(failure));
    });

    test('should stay a success when the value itself is null', () {
      const result = Result<int?>.success(null);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('should build constants when the payload is constant', () {
      const result = Result<int>.success(7);

      expect(result.valueOrNull, 7);
    });

    test('should match its concrete variant when switching over it', () {
      const Result<int> success = Success(1);
      const Result<int> error = Err(NotFoundFailure());

      String describe(Result<int> result) => switch (result) {
        Success<int>() => 'success',
        Err<int>() => 'failure',
      };

      expect(describe(success), 'success');
      expect(describe(error), 'failure');
    });
  });
}
