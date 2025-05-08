import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

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
          'Sorry! ${Platform.operatingSystem} is unsupported by pact_dart.');
  }
}

String getLibDirectory() {
  final env = Platform.environment['PACT_DART_LIB_DOWNLOAD_PATH'];
  if (env != null && env.isNotEmpty) {
    return env;
  }
  // Requires elevated permission for writing
  return '/usr/local/lib';
}

/// Determine the architecture using `uname -m` on Unix-like systems,
/// and default to `x86_64` on Windows or if `uname` fails.
String getArchitecture() {
  if (Platform.isWindows) {
    // For simplicity, default to x86_64 on Windows
    return 'x86_64';
  }

  try {
    final result = Process.runSync('uname', ['-m']);
    if (result.exitCode == 0) {
      final arch = result.stdout.trim();
      switch (arch) {
        case 'x86_64':
          return 'x86_64';
        case 'arm64':
        case 'aarch64':
          return 'aarch64';
        // Extend with more architectures if needed.
      }
    }
  } catch (_) {
    // Fall through if `uname` not available
  }

  // Fallback
  return 'x86_64';
}

/// Generate the GitHub release URL for a given library name, version, and file type.
Uri generateDependencyLink(String name, String version, String fileType) {
  final operatingSystem =
      Platform.operatingSystem == 'macos' ? 'macos' : Platform.operatingSystem;
  final architecture = getArchitecture();

  final releasePath = '/pact-foundation/pact-reference/releases/download/'
      '$name-v$version/$name-$operatingSystem-$architecture.$fileType.gz';

  print('Generated link: $releasePath');
  return Uri(scheme: 'https', host: 'github.com', path: releasePath);
}

/// Downloads and unpacks the given dependency from GitHub, placing it in [getLibDirectory()].

Future<void> downloadDependency(String name, String version) async {
  final fileType = getPlatformFileType();
  final dependencyLink = generateDependencyLink(name, version, fileType);

  print('Downloading from $dependencyLink ...');
  final res = await http.get(dependencyLink);
  if (res.statusCode != 200) {
    throw HttpException('Failed to download from $dependencyLink '
        '(HTTP ${res.statusCode})');
  }

  final library = GZipCodec().decode(res.bodyBytes);

  final libDir = getLibDirectory();
  final libPath = p.join(libDir, '$name.$fileType');

  // Ensure the directory exists
  final dir = Directory(libDir);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  print('Writing to $libPath ...');
  final writeStream = File(libPath).openWrite();
  writeStream.add(library);
  await writeStream.close();
}

Future<void> main() async {
  // For Windows, the library is called "pact_ffi.dll";
  // for macOS/Linux, "libpact_ffi.(dylib|so)"
  final dependencyName = Platform.isWindows ? 'pact_ffi' : 'libpact_ffi';
  final dependencyVersion = '0.4.27';

  await downloadDependency(dependencyName, dependencyVersion);
  print('Download and extraction completed.');
}
