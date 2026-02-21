import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/gen/library.dart';
import 'package:pact_dart/src/errors.dart';
import 'package:pact_dart/src/utils/content_type.dart';

class Interaction {
  late int interaction;

  Interaction(int handle, String description) {
    final nativeDescription = description.toNativeUtf8().cast<Char>();

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

    final cProviderState = providerState.toNativeUtf8().cast<Char>();
    try {
      if (params != null && params.isNotEmpty) {
        params.forEach((key, value) {
          final cKey = key.toNativeUtf8().cast<Char>();
          final cValue = value.toNativeUtf8().cast<Char>();

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

    final cDescription = description.toNativeUtf8().cast<Char>();
    try {
      bindings.pactffi_upon_receiving(interaction, cDescription);
    } finally {
      calloc.free(cDescription);
    }

    return this;
  }

  void _withHeaders(InteractionPart part, Map<String, String> headers) {
    headers.forEach((key, value) {
      final cKey = key.toNativeUtf8().cast<Char>();
      final cValue = value.toNativeUtf8().cast<Char>();

      try {
        // TODO: `pactffi_with_header` and `pactffi_with_query_parameter` support an index field that
        // TODO: that is not support by this package, yet.
        bindings.pactffi_with_header(interaction, part, cKey, 0, cValue);
      } finally {
        calloc.free(cKey);
        calloc.free(cValue);
      }
    });
  }

  void _withBody<T>(InteractionPart part, T body, String? contentType) {
    Pointer<Char> cContentType;

    if (contentType != null) {
      cContentType = contentType.toNativeUtf8().cast<Char>();
    } else {
      cContentType = getContentType(body).toNativeUtf8().cast<Char>();
    }

    final cBody = jsonEncode(body).toNativeUtf8().cast<Char>();

    try {
      bindings.pactffi_with_body(interaction, part, cContentType, cBody);
    } finally {
      calloc.free(cContentType);
      calloc.free(cBody);
    }
  }

  void _withQuery(Map<String, dynamic> query) {
    query.forEach((key, value) {
      final cKey = key.toNativeUtf8().cast<Char>();
      Pointer<Char>? cValue;

      try {
        if (value is Map) {
          // Handle matcher map from PactMatchers
          cValue = jsonEncode(value).toNativeUtf8().cast<Char>();
          bindings.pactffi_with_query_parameter_v2(
              interaction, cKey, 0, cValue);
        } else if (value is List) {
          // Handle multiple values as a list without matchers
          final json = {'value': value};
          cValue = jsonEncode(json).toNativeUtf8().cast<Char>();
          bindings.pactffi_with_query_parameter_v2(
              interaction, cKey, 0, cValue);
        } else {
          // Simple string value
          cValue = value.toString().toNativeUtf8().cast<Char>();
          bindings.pactffi_with_query_parameter_v2(
              interaction, cKey, 0, cValue);
        }
      } finally {
        calloc.free(cKey);
        if (cValue != null) {
          calloc.free(cValue);
        }
      }
    });
  }

  /// Configures the request for this interaction.
  ///
  /// The [method] and [path] are required.
  /// Query parameters can be specified using the [query] parameter, which accepts:
  /// - Simple string values
  /// - Lists for multiple values for the same parameter
  /// - PactMatchers matchers (recommended):
  ///   * PactMatchers.QueryRegex - Regex matching for values
  ///   * PactMatchers.QueryMultiValue - Multiple values for a parameter
  ///   * PactMatchers.QueryMultiRegex - Regex matching for multiple values
  ///   * PactMatchers.QueryLike - Type-based matching (infers the type)
  ///   * PactMatchers.QueryEachLike - Array of values of the same type
  Interaction withRequest<T>(String method, String path,
      {Map<String, String>? headers,
      Map<String, dynamic>? query,
      T? body,
      String? contentType}) {
    if (method.isEmpty || path.isEmpty) {
      throw EmptyParametersError(['method', 'path']);
    }

    final cMethod = method.toNativeUtf8().cast<Char>();
    final cPath = path.toNativeUtf8().cast<Char>();

    try {
      bindings.pactffi_with_request(interaction, cMethod, cPath);
    } finally {
      calloc.free(cMethod);
      calloc.free(cPath);
    }

    if (headers != null) {
      _withHeaders(InteractionPart.InteractionPart_Request, headers);
    }

    if (query != null) {
      _withQuery(query);
    }

    if (body != null) {
      _withBody(InteractionPart.InteractionPart_Request, body, contentType);
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
      _withHeaders(InteractionPart.InteractionPart_Response, headers);
    }

    if (body != null) {
      _withBody(InteractionPart.InteractionPart_Response, body, contentType);
    }

    return this;
  }
}
