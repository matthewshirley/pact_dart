import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/src/bindings/types.dart';
import 'package:pact_dart/src/errors.dart';
import 'package:pact_dart/src/utils/content_type.dart';

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

      // TODO: `pactffi_with_header` and `pactffi_with_query_parameter_v2` support an index field
      // TODO: that is not fully supported by this package, yet.
      bindings.pactffi_with_header(interaction, cPart, cKey, 0, cValue);
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

    bindings.pactffi_with_body(interaction, part.value, cContentType, cBody);
  }

  void _withQuery(Map<String, dynamic> query) {
    query.forEach((key, value) {
      final cKey = key.toNativeUtf8();

      if (value is Map) {
        // Handle matcher map from PactMatchers
        final cValue = jsonEncode(value).toNativeUtf8();
        bindings.pactffi_with_query_parameter_v2(interaction, cKey, 0, cValue);
      } else if (value is List) {
        // Handle multiple values as a list without matchers
        final json = {'value': value};
        final cValue = jsonEncode(json).toNativeUtf8();
        bindings.pactffi_with_query_parameter_v2(interaction, cKey, 0, cValue);
      } else {
        // Simple string value
        final cValue = value.toString().toNativeUtf8();
        bindings.pactffi_with_query_parameter_v2(interaction, cKey, 0, cValue);
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

    final cMethod = method.toNativeUtf8();
    final cPath = path.toNativeUtf8();
    bindings.pactffi_with_request(interaction, cMethod, cPath);

    if (headers != null) {
      _withHeaders(InteractionPart.Request, headers);
    }

    if (query != null) {
      _withQuery(query);
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
