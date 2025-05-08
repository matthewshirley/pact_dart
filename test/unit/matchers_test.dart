import 'package:pact_dart/src/errors.dart';
import 'package:pact_dart/src/matchers.dart';
import 'package:test/test.dart';

void main() {
  group('Term', () {
    test(
        'should conform to pact specification if `example` is matched by `regex`',
        () {
      const regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$';
      const value = 'betsy@example.com';
      final matcher = PactMatchers.Term(regex, value);

      expect(matcher['pact:matcher:type'], equals('regex'));
      expect(matcher['regex'], equals(regex));
      expect(matcher['value'], equals(value));
    });

    test('should throw error is `regex` or `example` is empty', () {
      expect(() => PactMatchers.Term('', ''), throwsA(isA<PactMatcherError>()));
      expect(() => PactMatchers.Term('', 'test'),
          throwsA(isA<PactMatcherError>()));
      expect(() => PactMatchers.Term(r'abc', ''),
          throwsA(isA<PactMatcherError>()));
    });

    test('should throw error if `example` is not matched by `regex', () {
      expect(
          () => PactMatchers.Term(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$',
              '555-555-5555'),
          throwsA(isA<PactMatcherError>()));
    });
  });

  group('SomethingLike', () {
    test('should conform to pact specification if `example` is passed', () {
      const example = 'test';
      final matcher = PactMatchers.SomethingLike(example);

      expect(matcher['pact:matcher:type'], equals('type'));
      expect(matcher['value'], equals(example));
    });

    test('should throw error is `example` is func', () {
      expect(() => PactMatchers.SomethingLike(() => 'test'),
          throwsA(isA<PactMatcherError>()));
    });
  });

  group('EachLike', () {
    test('should conform to pact specification if paramters are valid', () {
      final example = ['test'];
      const min = 1;
      const max = 5;
      final matcher = PactMatchers.EachLike(example, min: min, max: max);

      expect(matcher['pact:matcher:type'], equals('type'));
      expect(matcher['value'], equals(example));
      expect(matcher['min'], equals(min));
      expect(matcher['max'], equals(max));
    });

    test('should throw error is `min` lower than zero', () {
      expect(() => PactMatchers.EachLike(['test'], min: -1),
          throwsA(isA<PactMatcherError>()));
    });

    test('should throw error is `min` is greater than `max', () {
      expect(() => PactMatchers.EachLike(['test'], min: 10, max: 2),
          throwsA(isA<PactMatcherError>()));
    });
  });

  group('EachLike', () {
    test('should throw error is `value` is func', () {
      expect(() => PactMatchers.Includes(() => 'test'),
          throwsA(isA<PactMatcherError>()));
    });
  });
}
