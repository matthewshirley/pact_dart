/// Install the `libpact` dependency.
///
/// Currently, this is not managed by `pub` due to limitations:
///   - https://github.com/dart-lang/pub/issues/39
///   - https://github.com/dart-lang/pub/issues/3693
library install;

import 'dart:ffi';
import 'dart:io';

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

Uri generateDependencyLink(String name, String version, String fileType) {
  final architecture = getArchitecture();
  final operatingSystem = Platform.operatingSystem;

  final path =
      '/pact-foundation/pact-reference/releases/download/libpact_ffi-v$version/$name-$operatingSystem-$architecture.$fileType.gz';

  return Uri(scheme: 'https', host: 'github.com', path: path);
}

Future<void> downloadDependency(String name, String version) async {
  final fileType = getPlatformFileType();
  final dependencyLink = generateDependencyLink(name, version, fileType);

  print('🛜 Downloading from: ${dependencyLink.toString()}');

  try {
    final res = await http.get(dependencyLink);
    if (res.statusCode != 200) {
      throw Exception('Download failed with status code ${res.statusCode}');
    }

    final library = GZipCodec().decode(res.bodyBytes);

    final libDir = getLibDirectory();
    final libDirFile = Directory(libDir);
    await libDirFile.create(recursive: true);

    final libPath = path.join(libDir, '$name.$fileType');
    print('💾 Installing to: $libPath');

    try {
      await File(libPath).writeAsBytes(library, flush: true);
      print('✅ Successfully installed $name v$version.');
    } catch (e) {
      throw Exception(
          'Unable to write to $libPath. Try running with sudo or specify a different directory with PACT_DART_LIB_DOWNLOAD_PATH environment variable.');
    }
  } catch (e) {
    print('😢 An error occurred during installation: $e');
    rethrow;
  }
}

void main() async {
  final dependencyName = Platform.isWindows ? 'pact_ffi' : 'libpact_ffi';
  const dependencyVersion = '0.4.27';
  final libDir = getLibDirectory();

  print('🚀 Pact Dart Installation');
  print('======================');
  print(
      'This script will install the $dependencyName library required by Pact Dart:');
  print('- Library: $dependencyName v$dependencyVersion');
  print('- Platform: ${Platform.operatingSystem} (${getArchitecture()})');
  print('- Install directory: $libDir');
  print('');
  print(
      'Note: You may need admin privileges to write to the installation directory.');
  print(
      'If installation fails, you can specify an alternative directory using');
  print('the PACT_DART_LIB_DOWNLOAD_PATH environment variable.');
  print('');

  try {
    await downloadDependency(dependencyName, dependencyVersion);
  } catch (e) {
    print('\nSomething went wrong: $e');
    exit(1);
  }
}
