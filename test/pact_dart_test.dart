import 'dart:convert';

import 'package:test/test.dart';
import 'package:pact_dart/pact_dart.dart';
import 'package:http/http.dart' as http;

void main() {
  test('An example contract', () async {
    final pact = PactMockService(
        'test-ffi-consumer', 'test-ffi-provider', 'pact description');

    final body = {'name': 'mary'};

    pact
        .given('a alligator name mary exists')
        .uponReceiving('a request for an alligator')
        .withRequest('GET', '/alligator')
        .willRespondWith(200, body: body);

    pact.run();

    final uri = Uri.parse('http://localhost:1235/alligator');
    final res = await http.get(uri);

    expect(jsonDecode(res.body).name, equals('mary'));

    pact.writePactFile();
  });
}
