import 'package:logging/logging.dart';

class PactDartLogger {
  late final log;

  PactDartLogger() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });

    log = Logger('PactDart');
  }
}

Logger? _logger;
Logger get log => _logger ??= PactDartLogger().log;
