import 'dart:convert';
import 'dart:typed_data';

import 'package:pact_dart/pact_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    late MessageConsumer consumer;
    late Message message;

    setUp(() {
      consumer = MessageConsumer('test-consumer', 'test-provider');
      message = consumer.newMessage(description: 'test message');
    });

    group('given', () {
      test('should throw error if provider state is empty', () {
        expect(() => message.given(''), throwsA(isA<EmptyParameterError>()));
      });

      test('should set provider state', () {
        final result = message.given('user exists');
        expect(result, isA<Message>());
      });
    });

    group('andGiven', () {
      test('should add additional provider state', () {
        message.given('user exists').andGiven('user is active');
        expect(consumer.messages.length, equals(1));
      });
    });

    group('givenWithParameter', () {
      test('should throw error if provider state is empty', () {
        expect(() => message.givenWithParameter('', params: {'key': 'value'}),
            throwsA(isA<EmptyParameterError>()));
      });

      test('should set provider state with parameters', () {
        final result =
            message.givenWithParameter('user exists', params: {'id': '123'});
        expect(result, isA<Message>());
      });
    });

    group('expectsToReceive', () {
      test('should set description', () {
        final result = message.expectsToReceive('a user event');
        expect(result, isA<Message>());
      });
    });

    group('withRequestJSONContents', () {
      test('should set JSON content', () {
        final result = message.withRequestJSONContents({
          'id': '123',
          'name': 'Alice',
        });
        expect(result, isA<Message>());
      });
    });

    group('withRequestBinaryContents', () {
      test('should set binary content', () {
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        final result = message.withRequestBinaryContents(bytes);
        expect(result, isA<Message>());
      });

      test('should accept empty bytes', () {
        final bytes = Uint8List(0);
        final result = message.withRequestBinaryContents(bytes);
        expect(result, isA<Message>());
      });

      test('should accept string encoded as bytes', () {
        final bytes = Uint8List.fromList(utf8.encode('Hello World'));
        final result = message.withRequestBinaryContents(bytes);
        expect(result, isA<Message>());
      });
    });

    group('withRequestMetadata', () {
      test('should set metadata', () {
        final result =
            message.withRequestMetadata({'content-type': 'application/json'});
        expect(result, isA<Message>());
      });

      test('should accept multiple metadata entries', () {
        final result = message.withRequestMetadata({
          'content-type': 'application/json',
          'kafka-topic': 'user-events',
        });
        expect(result, isA<Message>());
      });
    });
  });
}
