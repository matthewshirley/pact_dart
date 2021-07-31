import 'dart:ffi';
import 'package:ffi/ffi.dart';

class PactHandle extends Struct {
  external Pointer<IntPtr> pact; // TODO: How should Dart handle uintptr_t?
}

class InteractionHandle extends Struct {
  external Pointer<Utf8> pact; // TODO: How should Dart handle usize?
  external Pointer<Utf8> interaction; // TODO: How should Dart handle usize?
}

class MessageHandle extends Struct {
  external Pointer<Utf8> pact; // TODO: How should Dart handle usize?
  external Pointer<Utf8> message; // TODO: How should Dart handle usize?
}

class MessagePactHandle extends Struct {
  external Pointer<Utf8> pact; // TODO: How should Dart handle usize?
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
