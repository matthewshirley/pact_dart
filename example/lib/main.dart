import 'package:http/http.dart' as http;
import 'package:pact_dart/pact_dart.dart';
import 'package:test/test.dart';

void main() {
  group('HTTP consumer example', () {
    late PactMockService pact;

    setUp(() {
      pact = PactMockService('HTTP consumer', 'Some API');
    });

    tearDown(() {
      return pact.reset();
    });

    test('get users', () async {
      pact
          .newInteraction()
          .given("a user exists",
              params: {'first_name': 'Betsy', 'last_name': 'Tester'})
          .uponReceiving('a request for all users')
          .withRequest('GET', '/users')
          .willRespondWith(200, body: {
            // Matchers are used here as we care about the types and structure of the response and not the exact values.
            'page': PactMatchers.SomethingLike(1),
            'per_page': PactMatchers.SomethingLike(20),
            'total': PactMatchers.IntegerLike(20),
            'total_pages': PactMatchers.SomethingLike(3),
            'data': PactMatchers.EachLike([
              {
                'id': PactMatchers.uuid('f3a9cf4a-92d7-4aae-a945-63a6440b528b'),
                'first_name': PactMatchers.SomethingLike('Betsy'),
                'last_name': PactMatchers.SomethingLike('Tester'),
                'salary': PactMatchers.DecimalLike(125000.00)
              }
            ])
          });

      pact.run(secure: false);

      await http.get(Uri.parse('http://${pact.host}:${pact.port}/users'));

      pact.writePactFile();
    });
  });

  group('message consumer example', () {
    test('payment rejected', () async {
      final pact = MessagesPact('message consumer', 'message provider');
      await pact
          .newMessage()
          .given("a user exists", params: {'id': 'user_id'})
          .andGiven('payment is rejected')
          .expectsToReceive('payment rejected message')
          .withContent({
            'type': 'payment rejected',
            'payment_id':
                PactMatchers.uuid('f3a9cf4a-92d7-4aae-a945-63a6440b528b'),
          })
          .withMetadata({'foo': 'bar'})
          .verify((message, metadata) {
            expect(
                message,
                equals({
                  'type': 'payment rejected',
                  'payment_id': 'f3a9cf4a-92d7-4aae-a945-63a6440b528b'
                }));
            expect(
                metadata,
                equals({
                  'contentType': 'application/json',
                  'foo': 'bar',
                }));
          });

      pact.writePactFile();
    });
  });
}
