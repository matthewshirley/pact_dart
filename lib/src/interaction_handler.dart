import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/src/errors.dart';

abstract class InteractionHandler<T extends InteractionHandler<T>> {
  int handle;

  InteractionHandler(this.handle);

  T given(String providerState) {
    if (providerState.isEmpty) {
      throw EmptyParameterError('providerState');
    }

    final cState = providerState.toNativeUtf8().cast<Char>();
    try {
      bindings.pactffi_given(handle, cState);
    } finally {
      calloc.free(cState);
    }

    return this as T;
  }

  T andGiven(String providerState) {
    return given(providerState);
  }

  T givenWithParameter(String providerState, {Map<String, String>? params}) {
    if (providerState.isEmpty) {
      throw EmptyParameterError('providerState');
    }

    if (params == null || params.isEmpty) {
      return given(providerState);
    }

    final cState = providerState.toNativeUtf8().cast<Char>();

    try {
      params.forEach((key, value) {
        final cKey = key.toNativeUtf8().cast<Char>();
        final cValue = value.toNativeUtf8().cast<Char>();

        try {
          bindings.pactffi_given_with_param(handle, cState, cKey, cValue);
        } finally {
          calloc.free(cKey);
          calloc.free(cValue);
        }
      });
    } finally {
      calloc.free(cState);
    }

    return this as T;
  }
}
