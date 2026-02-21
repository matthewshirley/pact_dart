import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:pact_dart/gen/library.dart';
import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/src/ffi/uint8list.dart';
import 'package:pact_dart/src/utils/logging.dart';
import 'package:pact_dart/src/interaction_handler.dart';

/// Represents a single message interaction in a Message Pact.
class Message extends InteractionHandler<Message> {
  Message(int pact, String description) : super(create(pact, description));

  static int create(int pact, String description) {
    final cDescription = description.toNativeUtf8().cast<Char>();

    try {
      return bindings.pactffi_new_message_interaction(pact, cDescription);
    } finally {
      calloc.free(cDescription);
    }
  }

  /// Sets the description for the message interaction.
  Message expectsToReceive(String description) {
    final cDescription = description.toNativeUtf8().cast<Char>();

    try {
      bindings.pactffi_message_expects_to_receive(handle, cDescription);
    } finally {
      calloc.free(cDescription);
    }

    return this;
  }

  /// Adds metadata to the message request.
  ///
  /// Metadata is used to convey information about the message, such as
  /// content type, queue/topic names, or other protocol-specific data.
  Message withRequestMetadata(Map<String, String> valueOrMatcher) {
    valueOrMatcher.forEach((key, value) {
      final cKey = key.toNativeUtf8().cast<Char>();
      final cValue = value.toNativeUtf8().cast<Char>();

      try {
        bindings.pactffi_with_metadata(
            handle, cKey, cValue, InteractionPart.InteractionPart_Request);
      } finally {
        calloc.free(cKey);
        calloc.free(cValue);
      }
    });

    return this;
  }

  /// Adds metadata to the message response.
  ///
  /// Used for synchronous message interactions (request/response pattern).
  /// For asynchronous messages, use [withRequestMetadata] instead.
  Message withResponseMetadata(Map<String, String> valueOrMatcher) {
    valueOrMatcher.forEach((key, value) {
      final cKey = key.toNativeUtf8().cast<Char>();
      final cValue = value.toNativeUtf8().cast<Char>();

      try {
        bindings.pactffi_with_metadata(
            handle, cKey, cValue, InteractionPart.InteractionPart_Response);
      } finally {
        calloc.free(cKey);
        calloc.free(cValue);
      }
    });

    return this;
  }

  Message _withContents(
      InteractionPart part, String contentType, dynamic content) {
    final cHeader = contentType.toNativeUtf8().cast<Char>();
    final cBody = content.toString().toNativeUtf8().cast<Char>();

    try {
      final res = bindings.pactffi_with_body(handle, part, cHeader, cBody);
      log.fine("[DEBUG] response from pactffi_with_body: $res");
    } finally {
      calloc.free(cHeader);
      calloc.free(cBody);
    }

    return this;
  }

  /// Sets the contents of the message body as JSON.
  ///
  /// The body is JSON-encoded and the content type is set to `application/json`.
  /// Supports Pact matchers embedded in the body structure.
  Message withRequestJSONContents(Map<String, dynamic> body) {
    final jsonString = jsonEncode(body);

    return _withContents(InteractionPart.InteractionPart_Request,
        "application/json", jsonString);
  }

  /// Sets the contents of the message response body as JSON.
  ///
  /// Used for synchronous message interactions (request/response pattern).
  /// For asynchronous messages, use [withRequestJSONContents] instead.
  Message withResponseJSONContents(Map<String, dynamic> body) {
    final jsonString = jsonEncode(body);

    return _withContents(InteractionPart.InteractionPart_Response,
        "application/json", jsonString);
  }

  /// Sets the contents of the message body as binary data.
  ///
  /// Binary data will be base64 encoded when serialized to the pact file.
  /// The content type is set to `application/octet-stream`.
  Message withRequestBinaryContents(Uint8List bytes) {
    final header = "application/octet-stream";
    final cHeader = header.toNativeUtf8().cast<Char>();
    final ptr = bytes.allocatePointer();

    try {
      final res = bindings.pactffi_with_binary_file(handle,
          InteractionPart.InteractionPart_Request, cHeader, ptr, bytes.length);

      if (res != true) {
        throw Exception("Failed to set binary contents");
      }
    } finally {
      calloc.free(cHeader);
      calloc.free(ptr);
    }
    return this;
  }

  /// Sets the contents of the message response body as binary data.
  ///
  /// Used for synchronous message interactions (request/response pattern).
  /// For asynchronous messages, use [withRequestBinaryContents] instead.
  Message withResponseBinaryContents(Uint8List bytes) {
    final header = "application/octet-stream";
    final cHeader = header.toNativeUtf8().cast<Char>();
    final ptr = bytes.allocatePointer();

    try {
      final res = bindings.pactffi_with_binary_file(handle,
          InteractionPart.InteractionPart_Response, cHeader, ptr, bytes.length);

      if (res != true) {
        throw Exception("Failed to set binary contents");
      }
    } finally {
      calloc.free(cHeader);
      calloc.free(ptr);
    }
    return this;
  }
}
