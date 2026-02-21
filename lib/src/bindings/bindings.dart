// ignore_for_file: non_constant_identifier_names

import 'package:pact_dart/gen/library.dart';
import 'package:pact_dart/src/ffi/dylib.dart';

NativeLibrary? _cachedBindings;
NativeLibrary get bindings {
  var pactffi = openLibrary();
  return _cachedBindings ??= NativeLibrary(pactffi);
}
