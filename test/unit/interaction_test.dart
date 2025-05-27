import 'package:pact_dart/pact_dart.dart';
import 'package:test/test.dart';

void main() {
  group('errors', () {
    late Interaction interaction;

    setUpAll(() {
      final service = PactMockService('123', '123');
      interaction = Interaction(service.handle, 'test handle');
    });

    group('withRequest', () {
      test('should throw error if path or method is empty', () {
        expect(() => interaction.withRequest('', ''),
            throwsA(isA<EmptyParametersError>()));
      });
    });

    group('given', () {
      test('should throw error if state is empty', () {
        expect(
            () => interaction.given(''), throwsA(isA<EmptyParameterError>()));
      });
    });

    group('uponReceiving', () {
      test('should throw error if description is empty', () {
        expect(() => interaction.uponReceiving(''),
            throwsA(isA<EmptyParameterError>()));
      });
    });
  });
}
