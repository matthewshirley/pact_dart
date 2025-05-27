import 'package:pact_dart/pact_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Query Parameter Matchers', () {
    test('QueryRegex generates correct matcher JSON', () {
      final matcher = PactMatchers.QueryRegex('ABC123', r'^[A-Z]{3}\d{3}$');

      expect(matcher['pact:matcher:type'], equals('regex'));
      expect(matcher['value'], equals('ABC123'));
      expect(matcher['regex'], equals(r'^[A-Z]{3}\d{3}$'));
    });

    test('QueryMultiValue generates correct matcher JSON', () {
      final matcher = PactMatchers.QueryMultiValue(['1', '2', '3']);

      expect(matcher['value'], equals(['1', '2', '3']));
      expect(matcher.containsKey('pact:matcher:type'), isFalse);
    });

    test('QueryMultiRegex generates correct matcher JSON', () {
      final matcher =
          PactMatchers.QueryMultiRegex(['type1', 'type2'], r'^type\d+$');

      expect(matcher['pact:matcher:type'], equals('regex'));
      expect(matcher['value'], equals(['type1', 'type2']));
      expect(matcher['regex'], equals(r'^type\d+$'));
    });

    test('QuerySomethingLike with integer generates correct matcher JSON', () {
      final matcher = PactMatchers.QuerySomethingLike(10);

      expect(matcher['pact:matcher:type'], equals('integer'));
      expect(matcher['value'], equals(10));
    });

    test('QuerySomethingLike with decimal generates correct matcher JSON', () {
      final matcher = PactMatchers.QuerySomethingLike(10.5);

      expect(matcher['pact:matcher:type'], equals('decimal'));
      expect(matcher['value'], equals(10.5));
    });

    test('QuerySomethingLike with string generates correct matcher JSON', () {
      final matcher = PactMatchers.QuerySomethingLike('test');

      expect(matcher['pact:matcher:type'], equals('type'));
      expect(matcher['value'], equals('test'));
    });

    test('QuerySomethingLike with boolean generates correct matcher JSON', () {
      final matcher = PactMatchers.QuerySomethingLike(true);

      expect(matcher['pact:matcher:type'], equals('type'));
      expect(matcher['value'], equals(true));
    });

    test('QueryEachLike generates correct matcher JSON', () {
      final matcher = PactMatchers.QueryEachLike('item', min: 2, max: 5);

      expect(matcher['pact:matcher:type'], equals('type'));
      expect(matcher['value'], equals('item'));
      expect(matcher['min'], equals(2));
      expect(matcher['max'], equals(5));
    });

    test('QueryEachLike with default min value', () {
      final matcher = PactMatchers.QueryEachLike('item');

      expect(matcher['min'], equals(1));
      expect(matcher.containsKey('max'), isTrue);
      expect(matcher['max'], isNull);
    });

    // Skip the integration test that requires a real PactHandle
    // We'll test this integration in a separate integration test
  });
}
