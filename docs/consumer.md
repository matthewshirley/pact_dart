# Consumer Tests

## Contract Testing Process (HTTP)

Pact is a consumer-driven contract testing tool, which is a fancy way of saying that the API `Consumer` writes a test to set out its assumptions and needs of its API `Provider`(s). By unit testing our API client with Pact, it will produce a `contract` that we can share to our `Provider` to confirm these assumptions and prevent breaking changes.

The process looks like this:

![diagram](./diagrams/summary.png)

1. The consumer writes a unit test of its behaviour using a Mock provided by Pact
2. Pact writes the interactions into a contract file (as a JSON document)
3. The consumer publishes the contract to a broker (or shares the file in some other way)
4. Pact retrieves the contracts and replays the requests against a locally running provider
5. The provider should stub out its dependencies during a Pact test, to ensure tests are fast and more deterministic.

In this document, we will cover steps 1-3.

## Writing a Consumer test

In this example, we are going to be testing our Product API client, responsible for communicating with the ProductAPI over HTTP. It currently has a single method getProduct(id) that will return a product.


### Example


```dart
import 'package:pact_dart/pact_dart.dart';

final pact = PactMockService('ProductAPIConsumer','ProductAPI');

pact
    .newInteraction()
    .given('A Product with ID 10 exists')
    .uponReceiving('A request for Product 10')
    .withRequest('GET', '/product/10')
    .willRespondWith(200, body: {
        'id': PactMatchers.EqualTo('10'),
        'name': PactMatchers.SomethingLike('All Dressed Chips'),
        'description': PactMatchers.SomethingLike('A masterpiece.'),
        'price': PactMatchers.DecimalLike(19.99)    
    });

pact.run(secure: false);

final productRepository = ProductRepository();
final product = await productRepository.getProduct('10');

expect(product.id, equals('10'));

pact.writePactFile();
pact.reset();

```

### Matching

In addition to matching on exact values, there are a number of useful matching functions
in the `matching` package that can increase the expressiveness of your tests and reduce brittle
test cases.

Rather than use hard-coded values which must then be present on the Provider side,
you can use regular expressions and type matches on objects and arrays to validate the
structure of your APIs.

Matchers can be used on the `Body`, `Headers`, `Path` and `Query` fields of the request,
and the `Body` and `Headers` on the response.

_NOTE: Some matchers are only compatible with the V3 interface, and must not be used with a V2 Pact. Your test will panic if this is attempted_

| Matcher                        | Min. Compatibility | Description                                                                                                                                                                                   |
| ------------------------------ | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `SomethingLike(content)`       | V2                 | Tells Pact that the value itself is not important, as long as the element _type_ (valid JSON number, string, object etc.) itself matches.                                                     |
| `Term(matcher, regex)`         | V2                 | Tells Pact that the value should match using a given regular expression, using `example` in mock responses. `example` must be a string.                                                       |
| `EachLike(content, min, max?)` | V2                 | Tells Pact that the value should be an array type, consisting of elements like those passed in. `min` must be >= 1. `content` may be any valid JSON value: e.g. strings, numbers and objects. |
| `EqualTo(content)`             | V3                 | Matchers cascade, equality resets the matching process back to exact values                                                                                                                   |
| `Includes(content)`            | V3                 | Checks if the given string is contained by the actual value                                                                                                                                   |
| `IntegerLike(int)`             | V3                 | Match all numbers that are integers (both ints and longs)                                                                                                                                     |
| `DecimalLike(decimal)`         | V3                 | Match all real numbers (floating point and decimal)                                                                                                                                           |

#### Match common formats

| method    | Min. Compatibility | description                       |
| --------- | ------------------ | --------------------------------- |
| `uuid()`  | V2                 | Match strings containing UUIDs    |
| `email()` | V2                 | Match strings containing an email |

### Managing Test Data (using Provider States)

Each interaction in a pact should be verified in isolation, with no context maintained from the previous interactions. Tests that depend on the outcome of previous tests are brittle and hard to manage.
Provider states is the feature that allows you to test a request that requires data to exist on the provider.

Read more about [provider states](https://docs.pact.io/getting_started/provider_states/)

There are several ways to define a provider state:

1. Using the `given(state)` method passing in a plain string.
2. Using the `given(state, param: params)` method, passing in a string description and a hash of parameters to be used by the provider during verification.

For V3 tests, these methods may be called multiple times, resulting in more than 1 state for a given interaction. You may also use the `andGiven` method for a more readable syntax.