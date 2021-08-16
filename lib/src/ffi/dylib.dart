import 'dart:io';
import 'dart:ffi';
import 'package:path/path.dart' as path;

String getlibraryName() {
  if (Platform.isLinux) {
    return 'libpact_ffi-linux-x86_64.so';
  }
  if (Platform.isMacOS) return 'libpact_ffi-osx-x86_64.dylib';
  if (Platform.isWindows) return 'pact_ffi-windows-x86_64.dll';

  throw Exception('Package does not support the current platform');
}

DynamicLibrary openLibrary() {
  final libraryName = getlibraryName();
  final libraryPath =
      path.join(Directory.current.path, 'dependencies', libraryName);

  return DynamicLibrary.open(libraryPath);
}
