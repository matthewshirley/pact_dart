import 'package:pact_dart/pact_dart.dart';
import 'package:pact_dart/src/errors.dart';
import 'package:pact_dart/src/interaction.dart';
import 'package:test/test.dart';

void main() {
  group('errors', () {
    late Interaction interaction;

    setUpAll(() {
      final service = PactMockService('123', '123');
      interaction = Interaction(service.handle, 'test handle');
    });

    group('EmptyParameterError', () {
      test('should contain parameter name in error message', () {
        final message = EmptyParameterError('test-parameter').toString();

        assert(message.contains('test-parameter'));
      });
    });

    group('EmptyParametersError', () {
      test('should contain parameter name in error message', () {
        final message =
            EmptyParametersError(['test-parameter-1', 'test-parameter-2'])
                .toString();

        assert(message.contains('test-parameter-1 or test-parameter-2'));
      });
    });

    group('PactCreateMockServerError', () {
      test('should include pact error code and message', () {
        final message = PactCreateMockServerError(-3).toString();

        assert(message.contains('-3'));
        assert(message.contains('The mock server could not be started'));
      });
    });

    group('PactWriteError', () {
      test('should include pact error code and message', () {
        final message = PactWriteError(3).toString();

        assert(message.contains('3'));
        assert(message
            .contains('A mock server with the provided port was not found'));
      });
    });
  });
}
