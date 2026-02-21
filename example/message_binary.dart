import 'dart:convert';
import 'package:pact_dart/pact_dart.dart';

void main() async {
  final consumer = MessageConsumer('binary-consumer', 'binary-service');
  final data = "Hello World";
  final bytes = utf8.encode(data);

  consumer
      .newMessage(description: 'binary file upload')
      .given('file upload exists')
      .withRequestBinaryContents(bytes)
      .withRequestMetadata({'content-type': 'application/octet-stream'});

  await consumer.verify(handler: (message) async {
    print(message);
  });
}
