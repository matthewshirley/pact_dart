/// Dart has no way to install native libraries during package installation
///
/// Something to keep an eye on: https://github.com/dart-lang/pub/issues/39
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
          'Sorry! ${Platform.operatingSystem} is unsupported by pact_dart.');
  }
}

String getLibDirectory() {
  final env = Platform.environment['PACT_DART_LIB_DOWNLOAD_PATH'];
  if (env != null && env.isNotEmpty) {
    return env;
  }

  return '/usr/local/lib';
}

Uri generateDependencyLink(String name, String version, String fileType) {
  final operatingSystem =
      Platform.operatingSystem == 'macos' ? 'osx' : Platform.operatingSystem;

  final path =
      '/pact-foundation/pact-reference/releases/download/$name-v$version/$name-$operatingSystem-x86_64.$fileType.gz';

  return Uri(scheme: 'https', host: 'github.com', path: path);
}

Future<void> downloadDependency(String name, String version) async {
  final fileType = getPlatformFileType();
  final dependencyLink = generateDependencyLink(name, version, fileType);

  final res = await http.get(dependencyLink);
  final library = GZipCodec().decode(res.bodyBytes);

  final libDir = getLibDirectory();
  final libPath = path.join(libDir, '$name.$fileType');

  final writeStream = File(libPath.toString()).openWrite();
  writeStream.add(library);

  await writeStream.close();
}

void main() async {
  final dependencyName = Platform.isWindows ? 'pact_ffi' : 'libpact_ffi';
  final dependencyVersion = '0.3.3';

  await downloadDependency(dependencyName, dependencyVersion);
}
