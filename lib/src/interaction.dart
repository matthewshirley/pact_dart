import 'dart:convert';
import 'package:ffi/ffi.dart';

import 'package:pact_dart/src/bindings/types.dart';
import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/src/errors.dart';

class Interaction {
  late InteractionHandle interaction;

  Interaction(PactHandle handle, String description) {
    final nativeDescription = description.toNativeUtf8();
    interaction = bindings.pactffi_new_interaction(handle, nativeDescription);
  }

  Interaction given(String providerState, {Map<String, String>? params}) {
    if (providerState.isEmpty) {
      throw EmptyParameterError('providerState');
    }

    final cProviderState = providerState.toNativeUtf8();
    if (params != null && params.isNotEmpty) {
      params.forEach((key, value) {
        final cProviderState = providerState.toNativeUtf8();
        final cKey = key.toNativeUtf8();
        final cValue = value.toNativeUtf8();

        bindings.pactffi_given_with_param(
            interaction, cProviderState, cKey, cValue);
      });
    } else {
      bindings.pactffi_given(interaction, cProviderState);
    }

    return this;
  }

  Interaction andGiven(String providerState, {Map<String, String>? params}) {
    return given(providerState, params: params);
  }

  Interaction uponReceiving(String description) {
    if (description.isEmpty) {
      throw EmptyParameterError('description');
    }

    final cDescription = description.toNativeUtf8();
    bindings.pactffi_upon_receiving(interaction, cDescription);

    return this;
  }

  void _withHeaders(InteractionPart part, Map<String, String> headers) {
    headers.forEach((key, value) {
      final cPart = part.value;
      final cKey = key.toNativeUtf8();
      final cValue = value.toNativeUtf8();

      // TODO: `pactffi_with_header` and `pactffi_with_query_parameter` support an index field that
      // TODO: that is not support by this package, yet.
      bindings.pactffi_with_header(interaction, cPart, cKey, 0, cValue);
    });
  }

  void _withBody(InteractionPart part, String contentType, Map body) {
    final cContentType = contentType.toNativeUtf8();
    final cBody = jsonEncode(body).toNativeUtf8();

    bindings.pactffi_with_body(interaction, part.value, cContentType, cBody);
  }

  Interaction withRequest(String method, String path,
      {Map<String, String>? headers,
      Map<String, String>? query,
      dynamic body}) {
    if (method.isEmpty || path.isEmpty) {
      throw EmptyParametersError(['method', 'path']);
    }

    final cMethod = method.toNativeUtf8();
    final cPath = path.toNativeUtf8();
    bindings.pactffi_with_request(interaction, cMethod, cPath);

    if (headers != null) {
      _withHeaders(InteractionPart.Request, headers);
    }

    if (query != null) {
      query.forEach((key, value) {
        final cKey = key.toNativeUtf8();
        final cValue = value.toNativeUtf8();

        bindings.pactffi_with_query_parameter(interaction, cKey, 0, cValue);
      });
    }

    if (body != null) {
      _withBody(InteractionPart.Request, 'application/json',
          body); // TODO: Assumes all requests are JSON
    }

    return this;
  }

  Interaction willRespondWith(int status,
      {Map<String, String>? headers, Map? body}) {
    bindings.pactffi_response_status(interaction, status);

    if (headers != null) {
      _withHeaders(InteractionPart.Response, headers);
    }

    if (body != null) {
      _withBody(InteractionPart.Response, 'application/json',
          body); // TODO: Assumes all requests are JSON
    }

    return this;
  }
}
