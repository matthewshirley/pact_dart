import 'dart:convert';

import 'package:pact_dart/src/matchers.dart';
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

  group('Matchers', () {
    group('EqualTo', () {
      test('should match when equal values is passed in request body',
          () async {
        final requestBody = {
          'alligator': {
            'name': PactMatchers.EqualTo('Betsy'),
            'isHungry': PactMatchers.EqualTo(true)
          }
        };

        pact
            .newInteraction('create an alligator')
            .uponReceiving('a request to create an alligator')
            .withRequest('POST', '/alligator', body: requestBody)
            .willRespondWith(201);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligator');
        final res = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'alligator': {'name': 'Betsy', 'isHungry': true}
            }));

        expect(res.statusCode, equals(201));
      });

      test(
          'should not match when equal values is not passed in the request body',
          () async {
        final requestBody = {
          'alligator': {
            'name': PactMatchers.EqualTo('Betsy'),
            'isHungry': PactMatchers.EqualTo(true)
          }
        };

        pact
            .newInteraction('create an alligator')
            .uponReceiving('a request to create an alligator')
            .withRequest('POST', '/alligator', body: requestBody)
            .willRespondWith(201);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligator');
        final res = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'alligator': {'name': 'Graham', 'isHungry': false}
            }));

        expect(res.statusCode, isNot(201));
      });
    });

    group('Term', () {
      test('should match when valid regex match is passed in request body',
          () async {
        final requestBody = {
          'contactEmail': PactMatchers.Term(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$',
              'betsy@example.com')
        };

        pact
            .newInteraction('update alligator contact email')
            .uponReceiving('a request to update the alligators contact email')
            .withRequest('PUT', '/alligator/1', body: requestBody)
            .willRespondWith(204);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligator/1');
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'contactEmail': 'betsylovers@example.com'}));

        expect(res.statusCode, equals(204));
      });

      test(
          'should not match when invalid regex match is passed in request body',
          () async {
        final requestBody = {
          'contactEmail': PactMatchers.Term(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$',
              'betsy@example.com')
        };

        pact
            .newInteraction('update alligator contact email')
            .uponReceiving('a request to update the alligators contact email')
            .withRequest('PUT', '/alligator/1', body: requestBody)
            .willRespondWith(204);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligator/1');
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'contactEmail': '555-555-5555'}));

        expect(res.statusCode, isNot(204));
      });
    });

    group('SomethingLike', () {
      test('should match when same types are used in the request body',
          () async {
        final requestBody = {
          'alligator': {
            'name': PactMatchers.SomethingLike('Betsy'),
            'isHungry': PactMatchers.SomethingLike(true)
          }
        };

        pact
            .newInteraction('create an alligator')
            .uponReceiving('a request to create an alligator')
            .withRequest('POST', '/alligator', body: requestBody)
            .willRespondWith(201);

        pact
            .newInteraction('create an alligator')
            .uponReceiving('a request to create an alligator named betsy')
            .withRequest('POST', '/alligator', body: {
          'alligator': {
            'name': PactMatchers.SomethingLike('Betsy'),
            'isHungry': PactMatchers.SomethingLike(true)
          }
        }).willRespondWith(201);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligator');
        final res = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'alligator': {'name': 'Graham', 'isHungry': false}
            }));

        expect(res.statusCode, equals(201),
            reason: 'Mock server failed to match SomethingLike matchers');
      });

      test('should not match if a different type is in the request body',
          () async {
        final pact = PactMockService('test-ffi-consumer', 'test-ffi-provider');

        final requestBody = {
          'alligator': {
            'name': PactMatchers.SomethingLike('Betsy'),
            'isHungry': PactMatchers.SomethingLike(true)
          }
        };

        pact
            .newInteraction('create an alligator')
            .uponReceiving('a request to create an alligator')
            .withRequest('GET', '/alligator', body: requestBody)
            .willRespondWith(201);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligator');
        final res = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'alligator': {'name': 123, 'isHungry': 'false'}
            }));

        expect(res.statusCode, isNot(201));
      });
    });

    group('EachLike', () {
      test(
          'should match when the same array element type is passed in the request body',
          () async {
        final requestBody = {
          'alligators': PactMatchers.EachLike([
            {
              'name': PactMatchers.SomethingLike('Betsy'),
              'isHungry': PactMatchers.SomethingLike(true)
            }
          ])
        };

        pact
            .newInteraction('create alligators')
            .uponReceiving('a request to create alligators')
            .withRequest('POST', '/alligators', body: requestBody)
            .willRespondWith(201);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators');
        final res = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'alligators': [
                {'name': 'Graham', 'isHungry': false}
              ]
            }));

        expect(res.statusCode, equals(201));
      });

      test(
          'should match if the min number of elements is passed in the request body',
          () async {
        final requestBody = {
          'alligators': PactMatchers.EachLike([
            {
              'name': PactMatchers.SomethingLike('Betsy'),
              'isHungry': PactMatchers.SomethingLike(true)
            }
          ], min: 2)
        };

        pact
            .newInteraction('create alligators')
            .uponReceiving('a request to create alligators')
            .withRequest('POST', '/alligators', body: requestBody)
            .willRespondWith(201);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators');
        final res = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'alligators': [
                {'name': 'Betsy', 'isHungry': true},
                {'name': 'Graham', 'isHungry': false}
              ]
            }));

        expect(res.statusCode, equals(201));
      });

      test(
          'should not match if min number of array elements is not passed in the request body',
          () async {
        final requestBody = {
          'alligators': PactMatchers.EachLike([
            {
              'name': PactMatchers.SomethingLike('Betsy'),
              'isHungry': PactMatchers.SomethingLike(true)
            }
          ], min: 2)
        };

        pact
            .newInteraction('create alligators')
            .uponReceiving('a request to create alligators')
            .withRequest('POST', '/alligators', body: requestBody)
            .willRespondWith(201);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators');
        final res = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'alligators': [
                {'name': 'Betsy', 'isHungry': true},
              ]
            }));

        expect(res.statusCode, isNot(201));
      });
      test(
          'should not match if max number of array elements is exceeded in request body',
          () async {
        final requestBody = {
          'alligators': PactMatchers.EachLike([
            {
              'name': PactMatchers.SomethingLike('Betsy'),
              'isHungry': PactMatchers.SomethingLike(true)
            }
          ], min: 1, max: 1)
        };

        pact
            .newInteraction('create alligators')
            .uponReceiving('a request to create alligators')
            .withRequest('POST', '/alligators', body: requestBody)
            .willRespondWith(201);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators');
        final res = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'alligators': [
                {'name': 'Betsy', 'isHungry': true},
                {'name': 'Graham', 'isHungry': false},
              ]
            }));

        expect(res.statusCode, isNot(201));
      });
    });

    group('IntegerLike', () {
      test('should match when integer is passed in request body', () async {
        final requestBody = {'numberOfTeeth': PactMatchers.IntegerLike(80)};

        pact
            .newInteraction('update alligator teeth count')
            .uponReceiving('a request to update betsy\'s number of teeth')
            .withRequest('PUT', '/alligators/1/teeth', body: requestBody)
            .willRespondWith(204);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators/1/teeth');
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'numberOfTeeth': 80}));

        expect(res.statusCode, equals(204));
      });

      test('should not match when integer is not passed in request body',
          () async {
        final requestBody = {'numberOfTeeth': PactMatchers.IntegerLike(80)};

        pact
            .newInteraction('update alligator teeth count')
            .uponReceiving('a request to update betsy\'s number of teeth')
            .withRequest('PUT', '/alligators/1/teeth', body: requestBody)
            .willRespondWith(204);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators/1/teeth');
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'numberOfTeeth': 80.1}));

        expect(res.statusCode, isNot(204));
      });
    });

    group('DecimalLike', () {
      test('should match when decimal is passed in request body', () async {
        final requestBody = {
          'numberOfAccidents': PactMatchers.DecimalLike(7.5)
        };

        pact
            .newInteraction('update alligator accident count')
            .uponReceiving('a request to update betsy\'s accident count')
            .withRequest('PUT', '/alligators/1/accidents', body: requestBody)
            .willRespondWith(204);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators/1/accidents');
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'numberOfAccidents': 20.5}));

        expect(res.statusCode, equals(204));
      });

      test('should not match when decimal is not passed in request body',
          () async {
        final requestBody = {
          'numberOfAccidents': PactMatchers.DecimalLike(7.5)
        };

        pact
            .newInteraction('update alligator accident count')
            .uponReceiving('a request to update betsy\'s accident count')
            .withRequest('PUT', '/alligators/1/accidents', body: requestBody)
            .willRespondWith(204);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators/1/accidents');
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'numberOfAccidents': 20}));

        expect(res.statusCode, isNot(204));
      });
    });

    group('Null', () {
      test('should match when null is passed in request body', () async {
        final requestBody = {'favouriteFood': PactMatchers.Null()};

        pact
            .newInteraction('update alligator favourite food')
            .uponReceiving('a request to update betsy\'s favourite food')
            .withRequest('PUT', '/alligators/1/metadata', body: requestBody)
            .willRespondWith(204);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators/1/metadata');
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'favouriteFood': null}));

        expect(res.statusCode, equals(204));
      });

      test('should not match when null is not passed in request body',
          () async {
        final requestBody = {'favouriteFood': PactMatchers.Null()};

        pact
            .newInteraction('update alligator favourite food')
            .uponReceiving('a request to update betsy\'s favourite food')
            .withRequest('PUT', '/alligators/1/metadata', body: requestBody)
            .willRespondWith(204);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators/1/metadata');
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'favouriteFood': ['Kibble']
            }));

        expect(res.statusCode, isNot(204));
      });
    });

    group('Includes', () {
      test('should match when certain text is passed in request body',
          () async {
        final requestBody = {
          'favouriteFood': PactMatchers.Includes('Pineapple')
        };

        pact
            .newInteraction('update alligator favourite food')
            .uponReceiving('a request to update betsy\'s favourite food')
            .withRequest('PUT', '/alligators/1/metadata', body: requestBody)
            .willRespondWith(204);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators/1/metadata');
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'favouriteFood': ['Kibble', 'Humans', 'Pineapple']
            }));

        expect(res.statusCode, equals(204));
      });

      test('should not match when certain text is not passed in request body',
          () async {
        final requestBody = {
          'favouriteFood': PactMatchers.Includes('Pineapple')
        };

        pact
            .newInteraction('update alligator favourite food')
            .uponReceiving('a request to update betsy\'s favourite food')
            .withRequest('PUT', '/alligators/1/metadata', body: requestBody)
            .willRespondWith(204);

        pact.run(secure: false);

        final uri = Uri.parse('http://localhost:1235/alligators/1/metadata');
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'favouriteFood': ['Kibble', 'Humans']
            }));

        expect(res.statusCode, isNot(204));
      });
    });
  });
}
