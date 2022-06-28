import 'dart:async';
import 'dart:convert';
import 'package:ffi/ffi.dart';

import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/src/bindings/types.dart';
import 'package:pact_dart/src/errors.dart';

class Message {
  late MessageHandle message;

  Message(MessagePactHandle handle, String description) {
    final cDescription = description.toNativeUtf8();
    message = bindings.pactffi_new_message(handle, cDescription);
  }

  Message given(String providerState, {Map<String, String>? params}) {
    if (providerState.isEmpty) {
      throw EmptyParameterError('providerState');
    }

    final cProviderState = providerState.toNativeUtf8();
    if (params != null && params.isNotEmpty) {
      params.forEach((key, value) {
        final cProviderState = providerState.toNativeUtf8();
        final cKey = key.toNativeUtf8();
        final cValue = value.toNativeUtf8();

        bindings.pactffi_message_given_with_param(
            message, cProviderState, cKey, cValue);
      });
    } else {
      bindings.pactffi_message_given(message, cProviderState);
    }

    return this;
  }

  Message andGiven(String providerState, {Map<String, String>? params}) {
    return given(providerState, params: params);
  }

  Message expectsToReceive(String description) {
    if (description.isEmpty) {
      throw EmptyParameterError('description');
    }

    final cDescription = description.toNativeUtf8();
    bindings.pactffi_message_expects_to_receive(message, cDescription);

    return this;
  }

  /// Note: The given `body` is converted to JSON via [jsonEncode].
  Message withContent(dynamic body) {
    final cContentType = 'application/json'.toNativeUtf8();
    final cBody = jsonEncode(body).toNativeUtf8();
    bindings.pactffi_message_with_contents(message, cContentType, cBody, -1);

    return this;
  }

  Message withMetadata(Map<String, String> metadata) {
    metadata.forEach((key, value) {
      final cKey = key.toNativeUtf8();
      final cValue = value.toNativeUtf8();
      bindings.pactffi_message_with_metadata(message, cKey, cValue);
    });

    return this;
  }

  /// You should call this method in your test to ensure, that your code
  /// can indeed handle the message specified by the message pact.
  ///
  /// Note: The message given to the `tryToHandleMethod` callback is a copy
  /// of the message given to [withContent] with all matchers stripped away.
  FutureOr<void> verify(
      FutureOr<void> Function(dynamic message, Map<String, String> metadata)
          tryToHandleMethod) {
    var json = bindings.pactffi_message_reify(message).toDartString();
    if (json.isEmpty) {
      throw StateError(
          'message has not been properly constructed yet, you need to call withContent first');
    }
    final reifiedMessage = jsonDecode(json) as Map<String, dynamic>;
    final body = reifiedMessage['contents'];
    final metadata = reifiedMessage['metadata'] as Map<String, dynamic>;
    return tryToHandleMethod(body, metadata.cast<String, String>());
  }
}
