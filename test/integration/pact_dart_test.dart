import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pact_dart/pact_dart.dart';
import 'package:test/test.dart';

void main() {
  late PactMockService pact;

  setUp(() {
    pact = PactMockService('test-ffi-consumer', 'test-ffi-provider');
  });

  tearDown(() {
    pact.reset();
  });

  group('given', () {
    test('should create multiple provider states', () async {
      final expectedStates = [
        {'name': 'there is an alligator named betsy'},
        {'name': 'the alligators were recently fed'}
      ];

      pact
          .newInteraction()
          .given('there is an alligator named betsy')
          .andGiven('the alligators were recently fed')
          .withRequest('GET', '/alligators')
          .willRespondWith(200);

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligators');
      await http.get(uri);

      pact.writePactFile(overwrite: true);

      final Map contract = jsonDecode(
          await File('./contracts/test-ffi-consumer-test-ffi-provider.json')
              .readAsString());

      final List interactions = contract['interactions'];
      assert(interactions.length == 1);

      final List providerStates = interactions.first['providerStates'];
      assert(providerStates.length == 2);
      assert(providerStates.toString() == expectedStates.toString());
    });

    test('should add state params', () async {
      pact
          .newInteraction()
          .givenWithParameter('there is an alligator',
              params: {'name': 'Betsy', 'hungry': 'true'})
          .withRequest('GET', '/alligators')
          .willRespondWith(200);

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligators');
      await http.get(uri);

      pact.writePactFile(overwrite: true);

      final Map contract = jsonDecode(
          await File('./contracts/test-ffi-consumer-test-ffi-provider.json')
              .readAsString());

      final List interactions = contract['interactions'];
      assert(interactions.length == 1);

      final List providerStates = interactions.first['providerStates'];
      assert(providerStates.length == 1);

      final Map params = providerStates[0]['params'];
      assert(params.length == 2);

      assert(params.containsKey('name'));
      assert(params.containsKey('hungry'));

      assert(params['name'] == 'Betsy');
      assert(params['hungry'] == true);
    });
  });

  group('withRequest', () {
    test('should match request with query param', () async {
      pact
          .newInteraction()
          .withRequest('GET', '/alligator', query: {'hungry': 'true'});

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligator?hungry=true');
      await http.get(uri);

      expect(pact.hasMatchedInteractions(), equals(true),
          reason: 'Pact did not match a request with a query parameter');
    });

    test('should match request with headers', () async {
      pact.newInteraction().withRequest('GET', '/alligator',
          headers: {'X-ALLIGATOR-LAST-FED': 'Yesterday'});

      pact.run(secure: false);

      final uri = Uri.parse('http://localhost:1235/alligator');
      await http.get(uri, headers: {'X-ALLIGATOR-LAST-FED': 'Yesterday'});

      expect(pact.hasMatchedInteractions(), equals(true),
          reason: 'Pact did not match a request with a header');
    });

    test('should match request with body', () async {
      pact
          .newInteraction()
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
          .newInteraction()
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
          .newInteraction()
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
          .newInteraction()
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
}
