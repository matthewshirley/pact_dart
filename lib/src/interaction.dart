import 'dart:convert';
import 'package:ffi/ffi.dart';

import 'package:pact_dart/src/errors.dart';
import 'package:pact_dart/src/bindings/types.dart';
import 'package:pact_dart/src/bindings/bindings.dart';

class Interaction {
  late InteractionHandle interaction;

  Interaction(PactHandle handle, String description) {
    interaction =
        bindings.pactffi_new_interaction(handle, description.toNativeUtf8());
  }

  Interaction given(String providerState) {
    if (providerState.isEmpty) {
      throw Error();
    }

    bindings.pactffi_given(interaction, providerState.toNativeUtf8());

    return this;
  }

  Interaction uponReceiving(String description) {
    if (description.isEmpty) {
      throw Error();
    }

    bindings.pactffi_upon_receiving(interaction, description.toNativeUtf8());

    return this;
  }

  Interaction withRequest(String method, String path,
      {Map? headers, Map? query, Map? body}) {
    if (method.isEmpty || path.isEmpty) {
      throw Error();
    }

    bindings.pactffi_with_request(
        interaction, method.toNativeUtf8(), path.toNativeUtf8());

    if (headers != null) {
      throw NotImplemented(
          'Interaction.withRequest := `headers` is not fully implemented');
    }

    if (query != null) {
      throw NotImplemented(
          'Interaction.withRequest := `headers` is not fully implemented');
    }

    if (body != null) {
      bindings.pactffi_with_body(
          interaction,
          InteractionPart.Request.value,
          'application/json'.toNativeUtf8(),
          jsonEncode(body)
              .toNativeUtf8()); // TODO: It could be bad using jsonEncode.
    }

    return this;
  }

  Interaction willRespondWith(int status, {Map? headers, Map? body}) {
    bindings.pactffi_response_status(interaction, status);

    if (headers != null) {
      throw NotImplemented(
          'Interaction.willRespondWith := `headers` is not fully implemented');
    }

    if (body != null) {
      bindings.pactffi_with_body(
          interaction,
          InteractionPart.Response.value,
          'application/json'.toNativeUtf8(),
          jsonEncode(body)
              .toNativeUtf8()); // TODO: It could be bad using jsonEncode.
    }

    return this;
  }
}
