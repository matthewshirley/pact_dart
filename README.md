# pact_dart

[![ci](https://github.com/matthewshirley/pact_dart/actions/workflows/ci.yml/badge.svg)](https://github.com/matthewshirley/pact_dart/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/matthewshirley/pact_dart/branch/main/graph/badge.svg?token=N7495X6QCL)](https://codecov.io/gh/matthewshirley/pact_dart)

⚠️ WIP Package - API is not yet confirmed ⚠️

This library provides a Dart DSL for generating Pact contracts. It implements [Pact Specification v3](https://github.com/pact-foundation/pact-specification/tree/version-3) by taking advantage of the pact_ffi library.

### Installation

Simply, install the package using `pub`:

```bash
dart pub add pact_dart
```

Currently, the `libpact_ffi` dependency is included for x86_64 macOS, Linux and Windows.

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

### Matching

`pact_dart` supports request/response (matching techniques)[https://docs.pact.io/getting_started/matching/] as defined in the [Pact Specification v3](https://github.com/pact-foundation/pact-specification/tree/version-3).

```dart
pact
    .newInteraction('create an alligator')
    .uponReceiving('a request to create an alligator named betsy')
    .withRequest('POST', '/alligator', body: {
        'alligator': {
        'name': PactMatchers.EqualTo('Betsy'),
        'isHungry': PactMatchers.SomethingLike(true),
        'countOfTeeth': PactMatchers.IntegerLike(80),
        'countOfHumansScared': PactMatchers.DecimalLike(12.5),
        'favouriteFood': PactMatchers.Includes('Pineapple'),
        'status': PactMatchers.Null(),
        'email': PactMatchers.Term(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$', 'betsy@example.com'),
        'friends': PactMatchers.EachLike(['Beth'], min: 1, max: 5)
        }
    }).willRespondWith(201);

    final uri = Uri.parse('http://localhost:1235/alligator');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
              'alligator': {
                  'name': 'Betsy',
                  'isHungry': false,
                  'countOfTeeth': 78,
                  'countOfHumansScared': 100.5,
                  'favouriteFood': ['Pineapple', 'Kibble', 'Human'],
                  'status': null,
                  'email': 'betsylovers@example.com',
                  'friends': ['Beth', 'Susan', 'Graham', 'Michael', 'Chloe']
                }
            }
        )
    );
```

### Feature support

| Feature                                                                | Supported |
| ---------------------------------------------------------------------- | --------- |
| HTTP Pacts                                                             | 🔨        |
| Asychronous message pacts                                              | ❌        |
| Regular expression matching                                            | ✅        |
| Type based matching ("like")                                           | ✅        |
| Flexible array length ("each like")                                    | ✅        |
| Verify a pact that uses the Pact specification v3 format               | ✅        |
| Pact specification v3 matchers                                         | 🔨        |
| Pact specification v3 generators                                       | ❌        |
| Multiple provider states (pact creation)                               | ❌        |
| Multiple provider states (pact verification)                           | ❌        |
| Publish pacts to Pact Broker                                           | ❌        |
| Tag consumer version in Pact Broker when publishing pact               | ❌        |
| Dynamically fetch pacts for provider from Pact Broker for verification | ❌        |
| Dynamically fetch pacts for provider with specified tags               | ❌        |
| Automatically tag consumer/provider with name of git branch            | ❌        |
| Use 'pacts for verification' Pact Broker API                           | ❌        |
| Pending pacts                                                          | ❌        |
| WIP pacts                                                              | ❌        |
| JSON test results output                                               | ❌        |
| XML test results output                                                | ❌        |
| Markdown test results output                                           | ❌        |
| Run a single interaction when verifying a pact                         | ❌        |
| Injecting values from provider state callbacks                         | ❌        |
| Date/Time expressions with generators                                  | ❌        |

- ✅ -- Implemented
- 🔨 -- Partially implemented
- ❌ -- Not implemented
