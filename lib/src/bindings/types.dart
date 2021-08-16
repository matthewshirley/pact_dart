import 'dart:ffi';
import 'package:ffi/ffi.dart';

// TODO: I don't know how to handle some pointers in Dart:
// TODO: * uintptr_t
// TODO: * usize

class PactHandle extends Struct {
  external Pointer<IntPtr> pact; //uintptr_t
}

class InteractionHandle extends Struct {
  external Pointer<Utf8> pact; // usize
  external Pointer<Utf8> interaction; // usize
}

class MessageHandle extends Struct {
  external Pointer<Utf8> pact; // usize
  external Pointer<Utf8> message; // usize
}

class MessagePactHandle extends Struct {
  external Pointer<Utf8> pact; // usize
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
