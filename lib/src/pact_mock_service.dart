import 'package:ffi/ffi.dart';

import 'package:pact_dart/src/ffi/extensions.dart';
import 'package:pact_dart/src/errors.dart';
import 'package:pact_dart/src/interaction.dart';
import 'package:pact_dart/src/bindings/types.dart';
import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/src/bindings/constants.dart';

import 'package:pact_dart/src/utils/logging.dart';

class PactMockService {
  int port = 1235;
  String host = '127.0.0.1';

  late PactHandle handle;
  late Interaction currentInteraction;

  List<Interaction> interactions = [];

  PactMockService(String consumer, String provider,
      {String? host, int? port, String logLevelEnv = 'PACT_LOG_LEVEL'}) {
    final logLevelEnvAsUtf8 = logLevelEnv.toNativeUtf8();
    try {
      bindings.pactffi_init(logLevelEnvAsUtf8);
    } finally {
      calloc.free(logLevelEnvAsUtf8);
    }

    final consumerAsUtf8 = consumer.toNativeUtf8();
    final providerAsUtf8 = provider.toNativeUtf8();

    try {
      handle = bindings.pactffi_new_pact(consumerAsUtf8, providerAsUtf8);
    } finally {
      calloc.free(consumerAsUtf8);
      calloc.free(providerAsUtf8);
    }

    if (port != null) {
      this.port = port;
    }

    if (host != null) {
      this.host = host;
    }
  }

  String get addr {
    return '$host:$port';
  }

  bool hasMatchedInteractions() {
    return bindings.pactffi_mock_server_matched(port).toBool();
  }

  bool reset() {
    return bindings.pactffi_cleanup_mock_server(port).toBool();
  }

  /// Creates a new "Interaction" that describes the interaction
  /// between the provider and consumer.
  Interaction newInteraction({String description = ''}) {
    currentInteraction = Interaction(handle, description);
    interactions.add(currentInteraction);

    return currentInteraction;
  }

  /// Sends the Pact Handle to the a newly created "Mock Server"
  /// so that the interactions can be mocked
  void run({bool secure = false}) {
    if (secure) {
      log.warning(
          'Secure is currently no longer supported. https://github.com/matthewshirley/pact_dart/issues/6');
    }

    if (interactions.isEmpty) {
      throw NoInteractionsError();
    }

    log.info('Starting mock server on', addr);
    final addrUtf8 = addr.toNativeUtf8();
    try {
      final portOrStatus = bindings.pactffi_create_mock_server_for_pact(
          handle, addrUtf8, secure.toInt());

      if (portOrStatus != port) {
        throw PactCreateMockServerError(portOrStatus);
      }
    } finally {
      calloc.free(addrUtf8);
    }
  }

  void onPactMismatches() {}

  /// Verifies the interactions were matched and writes the JSON contract
  void writePactFile({String directory = 'contracts', bool overwrite = false}) {
    final hasMatchedInteractions = this.hasMatchedInteractions();

    if (!hasMatchedInteractions) {
      final mismatches =
          bindings.pactffi_mock_server_mismatches(port).toDartString();
      throw PactMatchFailure(mismatches);
    }

    final dir = directory.toNativeUtf8();
    try {
      final result =
          bindings.pactffi_write_pact_file(port, dir, overwrite.toInt());

      if (result != PactWriteStatusCodes.OK) {
        throw PactWriteError(result);
      }
    } finally {
      calloc.free(dir);
    }
  }
}
