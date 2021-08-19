import 'dart:convert';

import 'package:test/test.dart';
import 'package:pact_dart/pact_dart.dart';
import 'package:http/http.dart' as http;

void main() {
  late PactMockService pact;

  setUp(() {
    pact = PactMockService('test-ffi-consumer', 'test-ffi-provider');
  });

  tearDown(() {
    pact.reset();
  });

  group('withRequest', () {
    test('should match request with query param', () async {
      pact
          .newInteraction('query paramter test')
          .withRequest('GET', '/alligator', query: {'hungry': 'true'});

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligator?hungry=true');
      await http.get(uri);

      expect(pact.hasMatchedInteractions(), equals(true),
          reason: 'Pact did not match a request with a query parameter');
    });

    test('should match request with headers', () async {
      pact.newInteraction('header paramter test').withRequest(
          'GET', '/alligator',
          headers: {'X-ALLIGATOR-LAST-FED': 'Yesterday'});

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligator');
      await http.get(uri, headers: {'X-ALLIGATOR-LAST-FED': 'Yesterday'});

      expect(pact.hasMatchedInteractions(), equals(true),
          reason: 'Pact did not match a request with a header');
    });

    test('should match request with body', () async {
      pact
          .newInteraction('body test')
          .withRequest('POST', '/alligator', body: {'name': 'Betsy'});

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligator');
      await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': 'Betsy'}));

      expect(pact.hasMatchedInteractions(), equals(true),
          reason: 'Pact did not match a request with a body');
    });
  });

  group('willRespondWith', () {
    test('should respond to request', () async {
      pact
          .newInteraction('request test')
          .withRequest('POST', '/alligator')
          .willRespondWith(200);

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligator');
      final res = await http.post(uri);

      expect(res.statusCode, equals(200),
          reason: 'Pact did not respond with expected status');
    });

    test('should respond with body', () async {
      pact
          .newInteraction('body test')
          .withRequest('POST', '/alligator')
          .willRespondWith(200, body: {'name': 'Betsy Jr.'});

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligator');
      final res = await http.post(uri);

      expect(jsonDecode(res.body)['name'], equals('Betsy Jr.'),
          reason: 'Pact did not respond with expected body');
    });

    test('should respond with header', () async {
      pact
          .newInteraction('header test')
          .withRequest('POST', '/alligator')
          .willRespondWith(200, headers: {'X-ALLIGATOR-IS-HUNGRY': 'No'});

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligator');
      final res = await http.post(uri);

      expect(res.headers, contains('x-alligator-is-hungry'));
      expect(res.headers['x-alligator-is-hungry'], equals('No'),
          reason: 'Pact did not respond with expected header');
    });
  });

  group('e2e', () {
    test('An example contract', () async {
      final pact = PactMockService('test-ffi-consumer', 'test-ffi-provider');

      final body = {
        'name': 'mary',
      };

      pact
          .newInteraction('interaction description')
          .given('a alligator name mary exists')
          .uponReceiving('a request for an alligator')
          .withRequest('POST', '/alligator', headers: {
        'Content-Type': 'application/json',
        'test-header': 'test-header-value',
        'header-2': 'hello'
      }, query: {
        'testing': 'true'
      }, body: {
        'test-matcher': {
          'pact:matcher:type': 'type',
          'value': {'testing': 'crocodile'}
        }
      }).willRespondWith(200, body: body, headers: {
        'pact-test-case': 'yes',
      });

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligator?testing=true');
      final res = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'test-header': 'test-header-value',
            'header-2': 'hello'
          },
          body: jsonEncode({
            'test-matcher': {'testing': 'alligator'}
          }));

      expect(res.headers['pact-test-case'], equals('yes'));
      expect(jsonDecode(res.body)['name'], equals('mary'));

      print(res.body);

      pact.writePactFile(overwrite: true);
    });
  });
}
