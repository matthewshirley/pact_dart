import 'dart:io';
import 'dart:ffi';
import 'package:path/path.dart' as path;

String getLibDirectory() {
  final env = Platform.environment['PACT_DART_LIB_DOWNLOAD_PATH'];
  if (env != null && env.isNotEmpty) {
    return env;
  }

  return '/usr/local/lib';
}

String getLibName() {
  if (Platform.isLinux) {
    return 'libpact_ffi.so';
  }
  if (Platform.isMacOS) return 'libpact_ffi.dylib';
  if (Platform.isWindows) return 'pact_ffi.dll';

  throw Exception('Package does not support the current platform');
}

DynamicLibrary openLibrary() {
  final name = getLibName();
  final libDir = getLibDirectory();
  final libPath = path.join(libDir, name);

  return DynamicLibrary.open(libPath);
}
