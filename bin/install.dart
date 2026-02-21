/// Install the `libpact` dependency.
///
/// Currently, this is not managed by `pub` due to limitations:
///   - https://github.com/dart-lang/pub/issues/39
///   - https://github.com/dart-lang/pub/issues/3693
library;

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

String getPlatformFileType() {
  switch (Platform.operatingSystem) {
    case 'macos':
      return 'dylib';

    case 'linux':
      return 'so';

    case 'windows':
      return 'dll';

    default:
      throw UnsupportedError(
          '${Platform.operatingSystem} is unsupported by pact_dart.');
  }
}

String getLibDirectory() {
  final env = Platform.environment['PACT_DART_LIB_DOWNLOAD_PATH'];
  if (env != null && env.isNotEmpty) {
    return env;
  }

  switch (Platform.operatingSystem) {
    case 'windows':
      final programFiles =
          Platform.environment['ProgramFiles'] ?? 'C:\\Program Files';
      return '$programFiles\\PactDart';

    case 'macos':
    case 'linux':
      return '/usr/local/lib';

    default:
      final home = Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '.';
      return '$home/.pact_dart/lib';
  }
}

String getArchitecture() {
  final abi = Abi.current().toString();
  final arch = abi.split('_').last;

  switch (arch) {
    case 'arm64':
    case 'arm':
      return 'aarch64';

    case 'x64':
      return 'x86_64';

    case 'ia32':
      return 'x86';

    case 'riscv64':
    case 'riscv32':
      throw UnsupportedError('RISC-V is not currently supported');

    default:
      print('Warning: Unknown architecture: $arch, defaulting to x86_64');
      return 'x86_64';
  }
}

Uri getLibraryUri(String name, String version) {
  final architecture = getArchitecture();
  final fileType = getPlatformFileType();
  final operatingSystem = Platform.operatingSystem;

  final path =
      '/pact-foundation/pact-reference/releases/download/libpact_ffi-v$version/$name-$operatingSystem-$architecture.$fileType.gz';

  return Uri(scheme: 'https', host: 'github.com', path: path);
}

Uri getHeadersUri(String version) {
  final path =
      '/pact-foundation/pact-reference/releases/download/libpact_ffi-v$version/pact.h';

  return Uri(scheme: 'https', host: 'github.com', path: path);
}

List<int> extractGZipBytes(Uint8List bytes) {
  return GZipCodec().decode(bytes);
}

Future<Uint8List> download(Uri uri) async {
  final res = await http.get(uri);
  if (res.statusCode != 200) {
    throw Exception(
        'Resource returned a non-success status code (got ${res.statusCode})');
  }

  return res.bodyBytes;
}

Future<void> install(
    String directory, String name, String fileType, List<int> bytes) async {
  final libDirFile = Directory(directory);
  await libDirFile.create(recursive: true);

  final libPath = path.join(directory, '$name.$fileType');
  await File(libPath).writeAsBytes(bytes, flush: true);
}

void main(List<String> args) async {
  print('Running Pact FFI Install...');
  print('====================== \n');
  print(
      'This script installs "Pact FFI" from the Pact Foundation. This is a shared library');
  print('that Pact Dart creates bindings to. \n');
  print(
      'Note: You may need `sudo` privileges to write to the installation directory.');
  print(
      'Alternatively, set `PACT_DART_LIB_DOWNLOAD_PATH` to install to a user path.\n');
  print('====================== \n');

  final parser = ArgParser()
    ..addOption('version',
        abbr: 'v', defaultsTo: '0.4.27', help: 'Pact FFI version to install')
    ..addFlag("include-headers",
        abbr: "i",
        defaultsTo: false,
        help: "Download Pact FFI headers for development");

  final options = parser.parse(args);
  final version = options['version'] as String;
  final includeHeaders = options['include-headers'];

  List<int> libBytes;
  final libName = Platform.isWindows ? 'pact_ffi' : 'libpact_ffi';
  final libUri = getLibraryUri(libName, version);
  print("Getting $libName from $libUri...");

  try {
    final bytes = await download(libUri);
    libBytes = extractGZipBytes(bytes);
  } catch (e) {
    print("Unable to download $libName: $e.");
    exit(1);
  }

  final libDir = getLibDirectory();
  final libFileType = getPlatformFileType();
  print("Saving $libName to $libDir...");

  try {
    await install(libDir, libName, libFileType, libBytes);
  } catch (e) {
    print('Unable to save library to disk: $e');
    exit(1);
  }

  if (includeHeaders == true) {
    final headerUri = getHeadersUri(version);
    print("Getting `pact.h` from $headerUri");

    try {
      final bytes = await download(headerUri);
      await install(".", "pact", "h", bytes);
    } catch (e) {
      print("Unable to download pact.h: $e.");
      exit(1);
    }
  }
}
