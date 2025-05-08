import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pact_dart/pact_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Query Parameter Matchers Integration', () {
    late PactMockService pact;
    final port = 1235;
    final host = 'localhost';
    final assertCallbacks = <Future<void> Function()>[];

    setUpAll(() {
      pact = PactMockService(
        'QueryMatcherIntegrationConsumer',
        'QueryMatcherIntegrationProvider',
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

    test('Can match query parameters using various matchers', () async {
      // Setup the interaction with query parameter matchers
      pact
          .newInteraction(description: 'GET /api/search with query parameters')
          .given('GET /api/search service is available')
          .withRequest('GET', '/api/search', query: {
        // Simple value
        'simple': 'value',
        // Multiple values for a single parameter
        'ids': PactMatchers.QueryMultiValue(['1', '2', '3']),
        // Regex matching for a single value
        'code': PactMatchers.QueryRegex('ABC123', r'^[A-Z]{3}\d{3}$'),
        // Type matching (integer)
        'limit': PactMatchers.QuerySomethingLike(10),
      }).willRespondWith(200,
              headers: {'Content-Type': 'application/json'},
              body: {'result': 'success', 'matched': true});

      // Assert
      assertCallbacks.add(() async {
        // Make a request that should match the interaction
        final url =
            'http://$host:$port/api/search?simple=value&ids=1&ids=2&ids=3&code=ABC123&limit=25';
        final response = await http.get(Uri.parse(url));

        // Check the response
        expect(response.statusCode, equals(200));
        expect(jsonDecode(response.body),
            equals({'result': 'success', 'matched': true}));
      });
    });

    test('Can match query parameters with different types', () async {
      // Setup the interaction with query parameter matchers
      pact
          .newInteraction(
              description: 'GET /api/products with query parameters')
          .given('GET /api/products service is available')
          .withRequest('GET', '/api/products', query: {
        // Type matching (integer)
        'id': PactMatchers.QuerySomethingLike(123),
        // Type matching (decimal)
        'price': PactMatchers.QuerySomethingLike(19.99),
        // Type matching (boolean)
        'available': PactMatchers.QuerySomethingLike(true),
        // Array of strings
        'tags': PactMatchers.QueryEachLike('tag'),
      }).willRespondWith(200,
              headers: {'Content-Type': 'application/json'},
              body: {'result': 'success', 'matched': true});

      assertCallbacks.add(() async {
        // Make a request that should match the interaction
        final url =
            'http://$host:$port/api/products?id=456&price=29.99&available=false&tags=red&tags=large';
        final response = await http.get(Uri.parse(url));

        // Check the response
        expect(response.statusCode, equals(200));
        expect(jsonDecode(response.body),
            equals({'result': 'success', 'matched': true}));
      });
    });

    test('Can match regex patterns in query parameters', () async {
      // Setup the interaction with regex query parameter matcher
      pact
          .newInteraction(description: 'GET /api/users with query parameters')
          .given('GET /api/users service is available')
          .withRequest('GET', '/api/users', query: {
        // Email regex
        'email': PactMatchers.QueryRegex('user@example.com',
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
        // ID regex
        'id': PactMatchers.QueryRegex('usr-123', r'^usr-\d{3}$'),
        // Multiple regex values
        'roles': PactMatchers.QueryMultiRegex(
            ['role-admin', 'role-user'], r'^role-[a-z]+$'),
      }).willRespondWith(200,
              headers: {'Content-Type': 'application/json'},
              body: {'result': 'success', 'matched': true});

      assertCallbacks.add(() async {
        // Make a request that should match the interaction
        final url =
            'http://$host:$port/api/users?email=test@domain.com&id=usr-456&roles=role-editor&roles=role-viewer';
        final response = await http.get(Uri.parse(url));

        // Check the response
        expect(response.statusCode, equals(200));
        expect(jsonDecode(response.body),
            equals({'result': 'success', 'matched': true}));
      });
    });
  });
}
