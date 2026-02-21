import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pact_dart/pact_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MessageConsumer', () {
    late MessageConsumer consumer;

    setUp(() {
      consumer =
          MessageConsumer('test-message-consumer', 'test-message-provider');
    });

    tearDown(() {
      final pactFile =
          File('./contracts/test-message-consumer-test-message-provider.json');
      if (pactFile.existsSync()) {
        pactFile.deleteSync();
      }
    });

    group('JSON messages', () {
      test('should create message with JSON contents', () async {
        consumer
            .newMessage(description: 'user created event')
            .given('user exists')
            .withRequestJSONContents({
          'id': '123',
          'name': 'Alice',
          'email': 'alice@example.com',
        }).withRequestMetadata({'content-type': 'application/json'});

        await consumer.verify(
          handler: (message) async {
            final contents = message['contents'];
            final body = contents is String
                ? jsonDecode(contents) as Map<String, dynamic>
                : contents as Map<String, dynamic>;

            expect(body['id'], equals('123'));
            expect(body['name'], equals('Alice'));
            expect(body['email'], equals('alice@example.com'));
          },
          overwrite: true,
        );

        final pactFile = File(
            './contracts/test-message-consumer-test-message-provider.json');
        expect(pactFile.existsSync(), isTrue);
      });

      test('should create message with provider state parameters', () async {
        consumer
            .newMessage(description: 'order shipped event')
            .givenWithParameter('order exists',
                params: {'orderId': 'order-123'}).withRequestJSONContents({
          'orderId': 'order-123',
          'status': 'shipped',
        });

        await consumer.verify(
          handler: (message) async {
            expect(message['contents'], isNotNull);
          },
          overwrite: true,
        );

        final pactFile = File(
            './contracts/test-message-consumer-test-message-provider.json');
        final pact =
            jsonDecode(await pactFile.readAsString()) as Map<String, dynamic>;
        final messages = pact['messages'] as List;

        expect(messages.length, equals(1));
        final providerStates = messages[0]['providerStates'] as List;
        expect(providerStates[0]['name'], equals('order exists'));
        expect(providerStates[0]['params']['orderId'], equals('order-123'));
      });

      test('should handle multiple provider states', () async {
        consumer
            .newMessage(description: 'notification sent')
            .given('user is active')
            .andGiven('notifications enabled')
            .withRequestJSONContents({'type': 'email', 'sent': true});

        await consumer.verify(
          handler: (message) async {
            expect(message['contents'], isNotNull);
          },
          overwrite: true,
        );

        final pactFile = File(
            './contracts/test-message-consumer-test-message-provider.json');
        final pact =
            jsonDecode(await pactFile.readAsString()) as Map<String, dynamic>;
        final messages = pact['messages'] as List;
        final providerStates = messages[0]['providerStates'] as List;

        expect(providerStates.length, equals(2));
        expect(providerStates[0]['name'], equals('user is active'));
        expect(providerStates[1]['name'], equals('notifications enabled'));
      });
    });

    group('Binary messages', () {
      test('should create message with binary contents', () async {
        final binaryData = Uint8List.fromList(
            [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

        consumer
            .newMessage(description: 'image upload')
            .given('image storage available')
            .withRequestBinaryContents(binaryData)
            .withRequestMetadata({'content-type': 'application/octet-stream'});

        await consumer.verify(
          handler: (message) async {
            final base64Contents = message['contents'] as String;
            final decoded = base64Decode(base64Contents);

            expect(decoded.length, equals(8));
            expect(decoded[0], equals(0x89));
          },
          overwrite: true,
        );

        final pactFile = File(
            './contracts/test-message-consumer-test-message-provider.json');
        expect(pactFile.existsSync(), isTrue);
      });

      test('should handle string encoded as binary', () async {
        final text = 'Hello, Pact!';
        final bytes = Uint8List.fromList(utf8.encode(text));

        consumer
            .newMessage(description: 'text message')
            .withRequestBinaryContents(bytes);

        await consumer.verify(
          handler: (message) async {
            final base64Contents = message['contents'] as String;
            final decoded = utf8.decode(base64Decode(base64Contents));

            expect(decoded, equals(text));
          },
          overwrite: true,
        );
      });
    });

    group('metadata', () {
      test('should include metadata in pact file', () async {
        consumer
            .newMessage(description: 'kafka message')
            .withRequestJSONContents(
                {'event': 'user_signup'}).withRequestMetadata({
          'content-type': 'application/json',
          'kafka-topic': 'user-events',
          'kafka-partition': '0',
        });

        await consumer.verify(
          handler: (message) async {
            expect(message['contents'], isNotNull);
          },
          overwrite: true,
        );

        final pactFile = File(
            './contracts/test-message-consumer-test-message-provider.json');
        final pact =
            jsonDecode(await pactFile.readAsString()) as Map<String, dynamic>;
        final messages = pact['messages'] as List;
        final metadata = messages[0]['metadata'] as Map<String, dynamic>;

        expect(metadata['content-type'], equals('application/json'));
        expect(metadata['kafka-topic'], equals('user-events'));
        expect(metadata['kafka-partition'].toString(), equals('0'));
      });
    });

    group('multiple messages', () {
      test('should create multiple messages in one pact', () async {
        consumer
            .newMessage(description: 'user created')
            .withRequestJSONContents({'type': 'created', 'userId': '1'});

        consumer
            .newMessage(description: 'user updated')
            .withRequestJSONContents({'type': 'updated', 'userId': '1'});

        await consumer.verify(
          handler: (message) async {
            expect(message['contents'], isNotNull);
          },
          overwrite: true,
        );

        final pactFile = File(
            './contracts/test-message-consumer-test-message-provider.json');
        final pact =
            jsonDecode(await pactFile.readAsString()) as Map<String, dynamic>;
        final messages = pact['messages'] as List;

        expect(messages.length, equals(2));
        expect(messages[0]['description'], equals('user created'));
        expect(messages[1]['description'], equals('user updated'));
      });
    });

    group('handler verification', () {
      test('should fail verification if handler throws', () async {
        consumer
            .newMessage(description: 'bad message')
            .withRequestJSONContents({'invalid': true});

        expect(
          consumer.verify(
            handler: (message) async {
              throw Exception('Handler failed');
            },
            overwrite: true,
          ),
          throwsException,
        );
      });

      test('should pass verification if handler succeeds', () async {
        consumer
            .newMessage(description: 'good message')
            .withRequestJSONContents({'valid': true});

        await consumer.verify(
          handler: (message) async {
            // Handler succeeds
          },
          overwrite: true,
        );

        final pactFile = File(
            './contracts/test-message-consumer-test-message-provider.json');
        expect(pactFile.existsSync(), isTrue);
      });
    });
  });
}
