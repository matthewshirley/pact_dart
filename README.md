# pact_dart

⚠️ WIP Package - API is not yet confirmed ⚠️

This library provides a Dart DSL for generating Pact contracts. It implements [Pact Specification v3](https://github.com/pact-foundation/pact-specification/tree/version-3) by taking advantage of the pact_ffi library.

### Example

```dart
import 'package:pact_dart/pact_dart.dart';

final pact = PactMockService('test-ffi-consumer','test-ffi-provider');

pact
    .newInteraction('request for betsy')
    .given('a alligator named betsy exists')
    .uponReceiving('a request for an alligator')
    .withRequest('GET', '/alligator')
    .willRespondWith(200, body: body: { 'name': 'Betsy' }});

pact.run(secure: false);

final uri = Uri.parse('http://localhost:1235/alligator');
final res = await http.get(uri);

expect(jsonDecode(res.body)['name'], equals('Betsy'));

pact.writePactFile(overwrite: true);
```
