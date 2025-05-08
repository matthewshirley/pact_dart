import 'package:pact_dart/pact_dart.dart';

void main() {
  // Create a Pact between the consumer and provider
  final pact = PactMockService('QueryMatcherConsumer', 'QueryMatcherProvider');

  // Create a new interaction
  pact
      .newInteraction(description: 'a request to search with query matchers')
      // Set up the provider state
      .given('search service is running')
      // Configure the request
      .withRequest('GET', '/api/search', query: {
    // Simple value
    'simple': 'value',
    // Multiple values for a single parameter
    'ids': PactMatchers.QueryMultiValue(['1', '2', '3']),
    // Regex matching for a single value
    'code': PactMatchers.QueryRegex('ABC123', '^[A-Z]{3}\\d{3}\$'),
    // Regex matching for all values in a list
    'types': PactMatchers.QueryMultiRegex(['type1', 'type2'], '^type\\d+\$'),
    // Type matching with type inference (integer)
    'limit': PactMatchers.QuerySomethingLike(10),
    // Type matching with type inference (decimal)
    'price': PactMatchers.QuerySomethingLike(19.99),
    // Type matching with type inference (boolean)
    'available': PactMatchers.QuerySomethingLike(true),
    // Match array of values of the same type
    'tags': PactMatchers.QueryEachLike("tag", min: 2),
  })
      // Configure the response
      .willRespondWith(200, headers: {
    'Content-Type': 'application/json'
  }, body: {
    'results': [
      {'id': 1, 'name': 'Item 1'},
      {'id': 2, 'name': 'Item 2'},
    ],
    'metadata': {'total': 2, 'query': 'value'}
  });

  try {
    // Start the mock server
    pact.run();

    // Here you would write the code to make the HTTP request
    // to the mock server and validate the response
    print('Mock server running at ${pact.addr}');

    // Write the pact file if all tests pass
    pact.writePactFile();
  } finally {
    // Clean up the mock server
    pact.reset();
  }
}
