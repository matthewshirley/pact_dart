import 'package:pact_dart/pact_dart.dart';
import 'package:pact_dart/src/errors.dart';
import 'package:test/test.dart';

void main() {
  group('PactMockService', () {
    late PactMockService service;

    setUp(() {
      service = PactMockService('123', '123');
    });

    group('errors', () {
      test('should throw an error if mock service is ran with no interactions',
          () {
        expect(() => service.run(), throwsA(isA<NoInteractionsError>()));
      });
    });
  });
}
