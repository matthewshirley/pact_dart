# pact_dart

[![ci](https://github.com/matthewshirley/pact_dart/actions/workflows/ci.yml/badge.svg)](https://github.com/matthewshirley/pact_dart/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/matthewshirley/pact_dart/branch/main/graph/badge.svg?token=N7495X6QCL)](https://codecov.io/gh/matthewshirley/pact_dart)

[Pact][pact-docs] is a contract testing tool to help you replace expensive and brittle end-to-end integration tests with fast, reliable and easy to debug unit tests. This framework provides a Dart DSL for generating Pact contracts. It implements [Pact Specification v3][pact-specification-v3] using the `Pact FFI Library`.

## Documentation

This readme offers an basic introduction to the library. View more documentation on Pact at https://docs.pact.io/.

- [Installation](#installation)
- [Basic Usage](#usage)
- [Consumer Documentation](./doc/consumer.md)

## Need Help

- [Join](<(http://slack.pact.io)>) our community [slack workspace](http://pact-foundation.slack.com/).
- Stack Overflow: https://stackoverflow.com/questions/tagged/pact
- Say 👋 on Twitter: [@pact_up]

## Installation

```shell
# install pact_dart as a dev dependency
dart pub add --dev pact_dart

# download and install the required libraries
dart run pact_dart:install

# 🚀 now write some tests!
```

<details><summary>Flutter Instructions</summary>

### Flutter Installation

```bash
# install pact_dart as a dev dependency
flutter pub add --dev pact_dart

# download and install the required libraries
flutter pub run pact_dart:install

# 🚀 now write some tests!
```

</details>

<details><summary>Manual Installation Instructions</summary>

### Modify Library Location

By default, the `Pact FFI Library` is installed to `/usr/local/lib` on macOS and Linux. However, you can use the `PACT_DART_LIB_DOWNLOAD_PATH` environment variable to modify the installation path.

```
PACT_DART_LIB_DOWNLOAD_PATH=/app/my-other-location dart run pact_dart:install
```

### Manual Installation

Download the latest `Pact FFI Library` [libraries] for your OS, and install onto a standard library search path (for example, we suggest: `/usr/local/lib` on OSX/Linux):

Ensure you have the correct extension for your OS:

- For Mac OSX: `.dylib`
- For Linux: `.so`
- For Windows: `.dll`

```sh
wget https://github.com/pact-foundation/pact-reference/releases/download/libpact_ffi-v0.0.2/libpact_ffi-osx-x86_64.dylib.gz
gunzip libpact_ffi-osx-x86_64.dylib.gz
mv libpact_ffi-osx-x86_64.dylib /usr/local/lib/libpact_ffi.dylib
```

</details>

## Usage

### Writing a Consumer test

Pact is a consumer-driven contract testing tool, which is a fancy way of saying that the API `Consumer` writes a test to set out its assumptions and needs of its API `Provider`(s). By unit testing our API client with Pact, it will produce a `contract` that we can share to our `Provider` to confirm these assumptions and prevent breaking changes.

In this example, we are testing the users repository that communicates with the `/users` resource of a HTTP service. The repository has a single method `fetchAll()` that will return a list of users.

```dart
import 'package:pact_dart/pact_dart.dart';

final pact = PactMockService('FlutterConsumer','APIService');

pact
    .newInteraction()
    .given('a user exists', params: {'first_name': 'Betsy', 'last_name': 'Tester'})
    .andGiven('')
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

final loginRepository = UsersRepository();
final users = await loginRepository.fetchAll();

expect(users.count, equals(20));
expect(users[0].first_name, equals('Betsy'));
expect(users[0].last_name, equals('Tester'));

pact.writePactFile();
pact.reset();
```

### Query Parameter Matchers

```dart
pact
    .newInteraction()
    .given(
        'a user exists',
        params: {
            'first_name': PactMatchers.QuerySomethingLike('Betsy'),
            'last_name': PactMatchers.QuerySomethingLike('Tester'),
            'id': PactMatchers.QuerySomethingLike(1),
            'email': PactMatchers.QueryRegex('betsy@example.com',
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          })
    .andGiven('')
    .uponReceiving('a request for all users')
    .withRequest('GET', '/users')
    .willRespondWith(200, body: {
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
```

## Compatibility

<details><summary>Feature Compatibility</summary>

| Feature                                                                | Supported |
| ---------------------------------------------------------------------- | --------- |
| HTTP Pacts                                                             | ✅         |
| Asychronous message pacts                                              | ❌         |
| Regular expression matching                                            | ✅         |
| Type based matching ("like")                                           | ✅         |
| Flexible array length ("each like")                                    | ✅         |
| Verify a pact that uses the Pact specification v3 format               | ✅         |
| Pact specification v3 matchers                                         | 🔨         |
| Pact specification v3 generators                                       | ❌         |
| Multiple provider states (pact creation)                               | ✅         |
| Multiple provider states (pact verification)                           | ❌         |
| Publish pacts to Pact Broker                                           | ❌         |
| Tag consumer version in Pact Broker when publishing pact               | ❌         |
| Dynamically fetch pacts for provider from Pact Broker for verification | ❌         |
| Dynamically fetch pacts for provider with specified tags               | ❌         |
| Automatically tag consumer/provider with name of git branch            | ❌         |
| Use 'pacts for verification' Pact Broker API                           | ❌         |
| Pending pacts                                                          | ❌         |
| WIP pacts                                                              | ❌         |
| JSON test results output                                               | ❌         |
| XML test results output                                                | ❌         |
| Markdown test results output                                           | ❌         |
| Run a single interaction when verifying a pact                         | ❌         |
| Injecting values from provider state callbacks                         | ❌         |
| Date/Time expressions with generators                                  | ❌         |

- ✅ -- Implemented
- 🔨 -- Partially implemented
- ❌ -- Not implemented

</details>

[pact-docs]: https://docs.pact.io
[pact-specification-v3]: https://github.com/pact-foundation/pact-specification/tree/version-3
[slack]: https://slack.pact.io
[pact website]: https://docs.pact.io/
[slack channel]: https://pact-foundation.slack.com
[@pact_up]: https://twitter.com/pact_up
