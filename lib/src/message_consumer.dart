import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/src/errors.dart';
import 'package:pact_dart/src/message.dart';

/// Creates and manages message pact contracts for consumer testing.
///
/// Message pacts are used for testing event-driven systems where communication
/// happens via message queues (Kafka, RabbitMQ, SQS, Kinesis, etc.) rather than HTTP.
///
/// The consumer is the system that **receives** messages from a queue/broker.
/// Provider verification ensures the producer sends messages that match consumer expectations.
class MessageConsumer {
  late int handle;

  List<Message> messages = [];

  /// Creates a new Message Pact model.
  MessageConsumer(String consumer, String provider) {
    final cConsumer = consumer.toNativeUtf8().cast<Char>();
    final cProvider = provider.toNativeUtf8().cast<Char>();

    try {
      handle = bindings.pactffi_new_message_pact(cConsumer, cProvider);
    } finally {
      calloc.free(cConsumer);
      calloc.free(cProvider);
    }
  }

  /// Creates a new message interaction for the current contract.
  Message newMessage({String description = ''}) {
    final message = Message(handle, description);
    messages.add(message);

    return message;
  }

  /// Verifies the consumer can handle all defined messages and writes the pact file.
  Future<void> verify<T>({
    required Future<void> Function(Map<String, dynamic> content) handler,
    String directory = 'contracts',
    bool overwrite = false,
  }) async {
    for (final message in messages) {
      final cReified = bindings.pactffi_message_reify(message.handle);
      final json = cReified.cast<Utf8>().toDartString();

      final content = jsonDecode(json) as Map<String, dynamic>;
      await handler(content);

      bindings.pactffi_free_string(cReified);
    }

    writePactFile(directory: directory, overwrite: overwrite);
  }

  /// Writes the message pact file to disk.
  void writePactFile({
    String directory = 'contracts',
    bool overwrite = false,
  }) {
    final cDir = directory.toNativeUtf8().cast<Char>();
    try {
      final result = bindings.pactffi_write_message_pact_file(
        handle,
        cDir,
        overwrite,
      );

      if (result != 0) {
        throw PactWriteError(result);
      }
    } finally {
      calloc.free(cDir);
    }
  }
}
