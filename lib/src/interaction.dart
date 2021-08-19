import 'dart:convert';
import 'package:ffi/ffi.dart';
import 'package:logger/logger.dart';

import 'package:pact_dart/src/bindings/types.dart';
import 'package:pact_dart/src/bindings/bindings.dart';

var logger = Logger();

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
      {Map<String, String>? headers,
      Map<String, String>? query,
      dynamic? body}) {
    if (method.isEmpty || path.isEmpty) {
      throw Error();
    }

    bindings.pactffi_with_request(
        interaction, method.toNativeUtf8(), path.toNativeUtf8());

    // TODO: `pactffi_with_header` and `pactffi_with_query_parameter` support an index field that
    // TODO: that is not support by this package, yet.
    if (headers != null) {
      headers.forEach((key, value) {
        logger.i('Interaction: Setting $key header on request');

        bindings.pactffi_with_header(interaction, InteractionPart.Request.value,
            key.toNativeUtf8(), 0, value.toNativeUtf8());
      });
    }

    if (query != null) {
      query.forEach((key, value) {
        logger.i('Interaction: Setting $key query parameter on request');

        bindings.pactffi_with_query_parameter(
            interaction, key.toNativeUtf8(), 0, value.toNativeUtf8());
      });
    }

    if (body != null) {
      bindings.pactffi_with_body(
          interaction,
          InteractionPart.Request.value,
          'application/json'
              .toNativeUtf8(), // TODO: Assumes all requests are JSON
          jsonEncode(body).toNativeUtf8());
    }

    return this;
  }

  Interaction willRespondWith(int status,
      {Map<String, String>? headers, Map? body}) {
    bindings.pactffi_response_status(interaction, status);

    if (headers != null) {
      headers.forEach((key, value) {
        bindings.pactffi_with_header(
            interaction,
            InteractionPart.Response.value,
            key.toNativeUtf8(),
            0,
            value.toNativeUtf8());
      });
    }

    if (body != null) {
      bindings.pactffi_with_body(
          interaction,
          InteractionPart.Response.value,
          'application/json'
              .toNativeUtf8(), // TODO: Assumes all requests are JSON
          jsonEncode(body).toNativeUtf8());
    }

    return this;
  }
}
