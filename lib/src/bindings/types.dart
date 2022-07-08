import 'dart:ffi';

/// https://docs.rs/pact_ffi/latest/pact_ffi/mock_server/handles/struct.PactHandle.html
class PactHandle extends Struct {
  external Pointer<Uint16> pact_ref;
}

/// https://docs.rs/pact_ffi/latest/pact_ffi/mock_server/handles/struct.MessagePactHandle.html
class MessagePactHandle extends Struct {
  external Pointer<Uint16> pact_ref;
}

/// https://docs.rs/pact_ffi/latest/pact_ffi/mock_server/handles/struct.InteractionHandle.html
class InteractionHandle extends Struct {
  external Pointer<Uint32> interaction_ref;
}

/// https://docs.rs/pact_ffi/latest/pact_ffi/mock_server/handles/struct.MessageHandle.html
class MessageHandle extends Struct {
  external Pointer<Uint32> interaction_ref;
}

enum InteractionPart {
  Request,
  Response,
}

extension InteractionPartExtensionMap on InteractionPart {
  static const values = [0, 1];
  int get value => values[index];
}

enum StringResult {
  Ok,
  Failed,
}

extension StringResultExtensionMap on StringResult {
  static const values = [0, 1];
  int get value => values[index];
}

enum PactSpecification { Unkown, V1, V1_1, V2, V3, V4 }
