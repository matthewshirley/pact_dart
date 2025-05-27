// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:pact_dart/src/bindings/signatures.dart';
import 'package:pact_dart/src/bindings/types.dart';
import 'package:pact_dart/src/ffi/dylib.dart';

class PactFFIBindings {
  late DynamicLibrary pactffi;

  late void Function(Pointer<Utf8> log_env_var) pactffi_init;

  late Pointer<Utf8> Function() pactffi_version;

  late PactHandle Function(
          Pointer<Utf8> consumer_name, Pointer<Utf8> provider_name)
      pactffi_new_pact;

  late InteractionHandle Function(PactHandle pact, Pointer<Utf8> description)
      pactffi_new_interaction;

  late int Function(InteractionHandle interaction, Pointer<Utf8> description)
      pactffi_given;

  late int Function(InteractionHandle interaction, Pointer<Utf8> description,
      Pointer<Utf8> key, Pointer<Utf8> value) pactffi_given_with_param;

  late int Function(InteractionHandle interaction, Pointer<Utf8> description)
      pactffi_upon_receiving;

  late int Function(InteractionHandle interaction, Pointer<Utf8> method,
      Pointer<Utf8> path) pactffi_with_request;

  late int Function(InteractionHandle interaction, int status)
      pactffi_response_status;

  late int Function(InteractionHandle interaction, int part,
      Pointer<Utf8> content_type, Pointer<Utf8> body) pactffi_with_body;

  late int Function(Pointer<Utf8> pact_str, Pointer<Utf8> addr_str, int bool)
      pactffi_create_mock_server;

  late int Function(PactHandle pact, Pointer<Utf8> addr_str, int tls)
      pactffi_create_mock_server_for_pact;

  late int Function(
          int mock_server_port, Pointer<Utf8> directory, int overwrite)
      pactffi_write_pact_file;

  late int Function(int mock_server_port) pactffi_mock_server_matched;

  /// External interface to get all the mismatches from a mock server. The port number of the
  /// mock server is passed in, and a pointer to a C string with the mismatches in JSON
  /// format is returned.
  ///
  /// https://docs.rs/pact_ffi/0.3.3/pact_ffi/mock_server/fn.pactffi_mock_server_mismatches.html
  /// https://docs.rs/pact_ffi/0.3.3/src/pact_ffi/mock_server/mod.rs.html#391-414
  ///
  late Pointer<Utf8> Function(int mock_server_port)
      pactffi_mock_server_mismatches;

  late int Function(InteractionHandle interaction, int part, Pointer<Utf8> name,
      int index, Pointer<Utf8> value) pactffi_with_header;

  late int Function(InteractionHandle interaction, Pointer<Utf8> name,
      int index, Pointer<Utf8> value) pactffi_with_query_parameter;

  late int Function(InteractionHandle interaction, Pointer<Utf8> name,
      int index, Pointer<Utf8> value) pactffi_with_query_parameter_v2;

  late int Function(int mock_server_port) pactffi_cleanup_mock_server;

  /// Get a description of a mismatch.
  ///
  /// https://docs.rs/pact_ffi/0.3.3/pact_ffi/fn.pactffi_mismatch_description.html
  /// https://docs.rs/pact_ffi/0.3.3/src/pact_ffi/lib.rs.html#265-274
  late Pointer<Utf8> Function(Pointer<Utf8> mismatches)
      pactffi_mismatch_description;

  PactFFIBindings() {
    pactffi = openLibrary();

    pactffi_init = pactffi
        .lookup<NativeFunction<pactffi_init_native>>('pactffi_init')
        .asFunction();

    pactffi_version = pactffi
        .lookup<NativeFunction<pactffi_version_native>>('pactffi_version')
        .asFunction();

    pactffi_new_pact = pactffi
        .lookup<NativeFunction<pactffi_new_pact_native>>('pactffi_new_pact')
        .asFunction();

    pactffi_new_interaction = pactffi
        .lookup<NativeFunction<pactffi_new_interaction_native>>(
            'pactffi_new_interaction')
        .asFunction();

    pactffi_given = pactffi
        .lookup<NativeFunction<pactffi_given_native>>('pactffi_given')
        .asFunction();

    pactffi_given_with_param = pactffi
        .lookup<NativeFunction<pactffi_given_with_param_native>>(
            'pactffi_given_with_param')
        .asFunction();

    pactffi_upon_receiving = pactffi
        .lookup<NativeFunction<pactffi_upon_receiving_native>>(
            'pactffi_upon_receiving')
        .asFunction();

    pactffi_with_request = pactffi
        .lookup<NativeFunction<pactffi_with_request_native>>(
            'pactffi_with_request')
        .asFunction();

    pactffi_response_status = pactffi
        .lookup<NativeFunction<pactffi_response_status_native>>(
            'pactffi_response_status')
        .asFunction();

    pactffi_with_body = pactffi
        .lookup<NativeFunction<pactffi_with_body_native>>('pactffi_with_body')
        .asFunction();

    pactffi_create_mock_server = pactffi
        .lookup<NativeFunction<pactffi_create_mock_server_native>>(
            'pactffi_create_mock_server')
        .asFunction();

    pactffi_create_mock_server_for_pact = pactffi
        .lookup<NativeFunction<pactffi_create_mock_server_for_pact_native>>(
            'pactffi_create_mock_server_for_pact')
        .asFunction();

    pactffi_write_pact_file = pactffi
        .lookup<NativeFunction<pactffi_write_pact_file_native>>(
            'pactffi_write_pact_file')
        .asFunction();

    pactffi_mock_server_matched = pactffi
        .lookup<NativeFunction<pactffi_mock_server_matched_native>>(
            'pactffi_mock_server_matched')
        .asFunction();

    pactffi_mock_server_mismatches = pactffi
        .lookup<NativeFunction<pactffi_mock_server_mismatches_native>>(
            'pactffi_mock_server_mismatches')
        .asFunction();

    pactffi_with_header = pactffi
        .lookup<NativeFunction<pactffi_with_header_native>>(
            'pactffi_with_header')
        .asFunction();

    pactffi_with_query_parameter = pactffi
        .lookup<NativeFunction<pactffi_with_query_parameter_native>>(
            'pactffi_with_query_parameter')
        .asFunction();

    pactffi_with_query_parameter_v2 = pactffi
        .lookup<NativeFunction<pactffi_with_query_parameter_v2_native>>(
            'pactffi_with_query_parameter_v2')
        .asFunction();

    pactffi_cleanup_mock_server = pactffi
        .lookup<NativeFunction<pactffi_cleanup_mock_server_native>>(
            'pactffi_cleanup_mock_server')
        .asFunction();

    pactffi_mismatch_description = pactffi
        .lookup<NativeFunction<pactffi_mismatch_description_native>>(
            'pactffi_mismatch_description')
        .asFunction();
  }
}

PactFFIBindings? _cachedBindings;
PactFFIBindings get bindings => _cachedBindings ??= PactFFIBindings();
