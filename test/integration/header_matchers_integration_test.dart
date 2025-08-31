import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pact_dart/pact_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Header Matchers Integration', () {
    late PactMockService pact;
    const port = 1235;
    const host = 'localhost';
    final assertCallbacks = <Future<void> Function()>[];

    setUpAll(() {
      pact = PactMockService(
        'HeaderMatcherIntegrationConsumer',
        'HeaderMatcherIntegrationProvider',
        logLevelEnv: 'trace',
      );
    });

    tearDownAll(() async {
      pact.run(secure: false);
      for (final callback in assertCallbacks) {
        await callback();
      }
      expect(pact.hasMatchedInteractions(), isTrue);
      pact.writePactFile(overwrite: true);
      pact.reset();
    });

    test('Can match headers using various matchers', () async {
      // Setup the interaction with header matchers
      pact
          .newInteraction(description: 'GET /api/search with headers')
          .given('GET /api/search service is available')
          .withRequest('GET', '/api/search', headers: {
        // Simple value
        'simple': 'value',
        // Multiple values for a single parameter
        'ids': PactMatchers.QueryMultiValue(['1', '2', '3']),
        // Regex matching for a single value
        'code': PactMatchers.Term(r'^[A-Z]{3}\d{3}$', 'ABC123'),
        // Type matching (integer)
        'limit': PactMatchers.SomethingLike(10),
      }).willRespondWith(200,
              headers: {'Content-Type': 'application/json'},
              body: {'result': 'success', 'matched': true});

      // Assert
      assertCallbacks.add(() async {
        // Make a request that should match the interaction
        const url = 'http://$host:$port/api/search';
        final response = await http.get(Uri.parse(url), headers: {
          'simple': 'value',
          'ids': '1,2,3',
          'code': 'XYZ789',
          'limit': '50',
        });

        // Check the response
        expect(response.statusCode, equals(200));
        expect(jsonDecode(response.body),
            equals({'result': 'success', 'matched': true}));
      });
    });

    test('Can match headers with different types', () async {
      // Setup the interaction with header matchers
      pact
          .newInteraction(description: 'GET /api/products with headers')
          .given('GET /api/products service is available')
          .withRequest('GET', '/api/products', headers: {
        // Type matching (integer)
        'id': PactMatchers.SomethingLike(123),
        // Type matching (decimal)
        'price': PactMatchers.SomethingLike(19.99),
        // Type matching (boolean)
        'available': PactMatchers.SomethingLike(true),
        // Array of strings
        'tags': PactMatchers.EachLike('tag'),
      }).willRespondWith(200,
              headers: {'Content-Type': 'application/json'},
              body: {'result': 'success', 'matched': true});

      assertCallbacks.add(() async {
        // Make a request that should match the interaction
        const url = 'http://$host:$port/api/products';
        final response = await http.get(Uri.parse(url), headers: {
          'id': '456',
          'price': '29.99',
          'available': 'false',
          'tags': 'red,large',
        });

        // Check the response
        expect(response.statusCode, equals(200));
        expect(jsonDecode(response.body),
            equals({'result': 'success', 'matched': true}));
      });
    });

    test('Can match regex patterns in headers', () async {
      // Setup the interaction with regex header matcher
      pact
          .newInteraction(description: 'GET /api/users with headers')
          .given('GET /api/users service is available')
          .withRequest('GET', '/api/users', headers: {
        // Email regex
        'email': PactMatchers.Term(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            'user@example.com'),
        // ID regex
        'id': PactMatchers.Term(r'^usr-\d{3}$', 'usr-123'),
        // Multiple regex values
        'roles': PactMatchers.QueryMultiRegex(
            ['role-admin', 'role-user'], r'^role-[a-z]+$'),
      }).willRespondWith(200,
              headers: {'Content-Type': 'application/json'},
              body: {'result': 'success', 'matched': true});

      assertCallbacks.add(() async {
        // Make a request that should match the interaction
        const url = 'http://$host:$port/api/users';
        final response = await http.get(Uri.parse(url), headers: {
          'email': 'test@domain.com',
          'id': 'usr-456',
          'roles': 'role-editor,role-viewer',
        });

        // Check the response
        expect(response.statusCode, equals(200));
        expect(jsonDecode(response.body),
            equals({'result': 'success', 'matched': true}));
      });
    });
  });
}
