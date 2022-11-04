import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'types.dart';

/// c_char -> Pointer<Utf8>
/// bool -> Int8
/// i32 -> Int32
/// size_t -> IntPtr

//
typedef pactffi_init_native = Void Function(Pointer<Utf8> log_env_var);

typedef pactffi_version_native = Pointer<Utf8> Function();

/// TODO
typedef generate_regex_value_internal_native = Void Function();

/// TODO
typedef pactffi_check_regex_native = Void Function();

typedef pactffi_cleanup_mock_server_native = Int8 Function(
    Int32 mock_server_port);

typedef pactffi_create_mock_server_native = Int32 Function(
    Pointer<Utf8> pact_str, Pointer<Utf8> addr_str, Int8 bool);

typedef pactffi_create_mock_server_for_pact_native = Int32 Function(
    PactHandle pact, Pointer<Utf8> addr_str, Int8 bool);

typedef pactffi_free_string_native = Void Function(Pointer<Utf8> s);

/// TODO
typedef pactffi_generate_datetime_string_native = Void Function();

/// TODO
typedef pactffi_generate_regex_value_native = Void Function();

typedef pactffi_get_tls_ca_certificate_native = Pointer<Utf8> Function();

typedef pactffi_given_native = Int8 Function(
    InteractionHandle interaction, Pointer<Utf8> description);

typedef pactffi_given_with_param_native = Int8 Function(
    InteractionHandle interaction,
    Pointer<Utf8> description,
    Pointer<Utf8> name,
    Pointer<Utf8> value);

typedef pactffi_message_expects_to_receive_native = Void Function(
    MessageHandle message, Pointer<Utf8> description);

typedef pactffi_message_given_native = Void Function(
    MessageHandle message, Pointer<Utf8> description);

typedef pactffi_message_given_with_param_native = Void Function(
    MessageHandle message,
    Pointer<Utf8> description,
    Pointer<Utf8> name,
    Pointer<Utf8> value);

typedef pactffi_message_reify_native = Pointer<Utf8> Function(
    MessageHandle message);

typedef pactffi_message_with_contents_native = Void Function(
    MessageHandle message, Pointer<Utf8> content_type, Uint8 body, IntPtr size);

typedef pactffi_message_with_metadata_native = Void Function(
    MessageHandle message, Pointer<Utf8> key, Pointer<Utf8> value);

typedef pactffi_mock_server_logs_native = Pointer<Utf8> Function(
    Int32 mock_server_port);

typedef pactffi_mock_server_matched_native = Int8 Function(
    Int32 mock_server_port);

/// External interface to get all the mismatches from a mock server. The port number of the
/// mock server is passed in, and a pointer to a C string with the mismatches in JSON
/// format is returned.
///
/// https://docs.rs/pact_ffi/0.3.3/pact_ffi/mock_server/fn.pactffi_mock_server_mismatches.html
/// https://docs.rs/pact_ffi/0.3.3/src/pact_ffi/mock_server/mod.rs.html#391-414
typedef pactffi_mock_server_mismatches_native = Pointer<Utf8> Function(
    Int32 mock_server_port);

typedef pactffi_new_interaction_native = InteractionHandle Function(
    PactHandle pact, Pointer<Utf8> description);

typedef pactffi_new_message_native = MessageHandle Function(
  MessagePactHandle pact,
  Pointer<Utf8> description,
);

typedef pactffi_new_message_pact_native = MessagePactHandle Function(
    Pointer<Utf8> consumer_name, Pointer<Utf8> provider_name);

typedef pactffi_new_pact_native = PactHandle Function(
    Pointer<Utf8> consumer_name, Pointer<Utf8> provider_name);

typedef pactffi_response_status_native = Int8 Function(
    InteractionHandle interaction, Int16 status);

typedef pactffi_upon_receiving_native = Int8 Function(
    InteractionHandle interaction, Pointer<Utf8> description);

typedef pactffi_with_binary_file_native = Int8 Function(
    InteractionHandle interaction,
    InteractionPart part,
    Pointer<Utf8> content_type,
    Pointer<Utf8> body, // TODO: body: *const u8,
    IntPtr size);

typedef pactffi_with_body_native = Int8 Function(InteractionHandle interaction,
    Int8 part, Pointer<Utf8> content_type, Pointer<Utf8> body);

typedef pactffi_with_header_native = Int8 Function(
    InteractionHandle interaction,
    Int8 part,
    Pointer<Utf8> name,
    IntPtr index,
    Pointer<Utf8> value);

typedef pactffi_with_message_pact_metadata_native = Void Function(
    MessagePactHandle pact,
    Pointer<Utf8> namespace,
    Pointer<Utf8> name,
    Pointer<Utf8> value);

typedef pactffi_with_multipart_file_native = StringResult Function(
    InteractionHandle interaction,
    InteractionPart part,
    Pointer<Utf8> content_type,
    Pointer<Utf8> file,
    Pointer<Utf8> part_name);

typedef pactffi_with_pact_metadata_native = Int8 Function(PactHandle pact,
    Pointer<Utf8> namespace, Pointer<Utf8> name, Pointer<Utf8> value);

typedef pactffi_with_query_parameter_native = Int8 Function(
    InteractionHandle interaction,
    Pointer<Utf8> name,
    IntPtr size,
    Pointer<Utf8> value);

typedef pactffi_with_request_native = Int8 Function(
    InteractionHandle interaction, Pointer<Utf8> method, Pointer<Utf8> path);

typedef pactffi_with_specification_native = Int8 Function(
    PactHandle pact, PactSpecification version);

typedef pactffi_write_message_pact_file_native = Int32 Function(
    MessagePactHandle pact, Pointer<Utf8> directory, Int8 overwrite);

typedef pactffi_write_pact_file_native = Int32 Function(
    Int32 mock_server_port, Pointer<Utf8> directory, Int8 overwrite);

/// Get a description of a mismatch.
///
/// https://docs.rs/pact_ffi/0.3.3/pact_ffi/fn.pactffi_mismatch_description.html
/// https://docs.rs/pact_ffi/0.3.3/src/pact_ffi/lib.rs.html#265-274
typedef pactffi_mismatch_description_native = Pointer<Utf8> Function(
    Pointer<Utf8> mismatch);
