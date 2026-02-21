import 'package:pact_dart/pact_dart.dart';

void main() async {
  final consumer = MessageConsumer('user-consumer', 'user-service');

  consumer
      .newMessage(description: 'user created event')
      .given('user exists')
      .withRequestJSONContents({
    'id': '123',
    'name': 'Alice',
    'email': 'alice@example.com',
  }).withRequestMetadata({'content-type': 'application/json'});

  await consumer.verify(handler: (message) async {
    print(message);
    print(message['contents']);
  });
}
