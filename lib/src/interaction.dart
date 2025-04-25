import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:pact_dart/src/bindings/types.dart';
import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/src/errors.dart';
import 'package:pact_dart/src/utils/content_type.dart';

class Interaction {
  late InteractionHandle interaction;

  Interaction(PactHandle handle, String description) {
    final nativeDescription = description.toNativeUtf8();

    try {
      interaction = bindings.pactffi_new_interaction(handle, nativeDescription);
    } finally {
      calloc.free(nativeDescription);
    }
  }

  Interaction given(String providerState, {Map<String, String>? params}) {
    if (providerState.isEmpty) {
      throw EmptyParameterError('providerState');
    }

    final cProviderState = providerState.toNativeUtf8();
    try {
      if (params != null && params.isNotEmpty) {
        params.forEach((key, value) {
          final cKey = key.toNativeUtf8();
          final cValue = value.toNativeUtf8();

          try {
            bindings.pactffi_given_with_param(
                interaction, cProviderState, cKey, cValue);
          } finally {
            calloc.free(cKey);
            calloc.free(cValue);
          }
        });
      } else {
        bindings.pactffi_given(interaction, cProviderState);
      }
    } finally {
      calloc.free(cProviderState);
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
    try {
      bindings.pactffi_upon_receiving(interaction, cDescription);
    } finally {
      calloc.free(cDescription);
    }

    return this;
  }

  void _withHeaders(InteractionPart part, Map<String, String> headers) {
    headers.forEach((key, value) {
      final cPart = part.value;
      final cKey = key.toNativeUtf8();
      final cValue = value.toNativeUtf8();

      try {
        // TODO: `pactffi_with_header` and `pactffi_with_query_parameter` support an index field that
        // TODO: that is not support by this package, yet.
        bindings.pactffi_with_header(interaction, cPart, cKey, 0, cValue);
      } finally {
        calloc.free(cKey);
        calloc.free(cValue);
      }
    });
  }

  void _withBody<T>(InteractionPart part, T body, String? contentType) {
    Pointer<Utf8> cContentType;

    if (contentType != null) {
      cContentType = contentType.toNativeUtf8();
    } else {
      cContentType = getContentType(body).toNativeUtf8();
    }

    final cBody = jsonEncode(body).toNativeUtf8();

    try {
      bindings.pactffi_with_body(interaction, part.value, cContentType, cBody);
    } finally {
      calloc.free(cContentType);
      calloc.free(cBody);
    }
  }

  Interaction withRequest<T>(String method, String path,
      {Map<String, String>? headers,
      Map<String, String>? query,
      T? body,
      String? contentType}) {
    if (method.isEmpty || path.isEmpty) {
      throw EmptyParametersError(['method', 'path']);
    }

    final cMethod = method.toNativeUtf8();
    final cPath = path.toNativeUtf8();

    try {
      bindings.pactffi_with_request(interaction, cMethod, cPath);
    } finally {
      calloc.free(cMethod);
      calloc.free(cPath);
    }

    if (headers != null) {
      _withHeaders(InteractionPart.Request, headers);
    }

    if (query != null) {
      query.forEach((key, value) {
        final cKey = key.toNativeUtf8();
        final cValue = value.toNativeUtf8();

        try {
          bindings.pactffi_with_query_parameter(interaction, cKey, 0, cValue);
        } finally {
          calloc.free(cKey);
          calloc.free(cValue);
        }
      });
    }

    if (body != null) {
      _withBody(InteractionPart.Request, body, contentType);
    }

    return this;
  }

  Interaction willRespondWith<T>(
    int status, {
    Map<String, String>? headers,
    T? body,
    String? contentType,
  }) {
    bindings.pactffi_response_status(interaction, status);

    if (headers != null) {
      _withHeaders(InteractionPart.Response, headers);
    }

    if (body != null) {
      _withBody(InteractionPart.Response, body, contentType);
    }

    return this;
  }
}
