import 'dart:convert';
import 'package:ffi/ffi.dart';

import 'package:pact_dart/src/errors.dart';
import 'package:pact_dart/src/interaction.dart';
import 'package:pact_dart/src/bindings/types.dart';
import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/src/bindings/constants.dart';

final consumerName = 'dart-ffi-consumer'.toNativeUtf8();
final providerName = 'dart-ffi-provider'.toNativeUtf8();

final handle = bindings.pactffi_new_pact(consumerName, providerName);

class PactMockService {
  late PactHandle handle;

  PactMockService(String consumer, String provider, String? description) {
    bindings.pactffi_init('PACT_LOG_LEVEL'.toNativeUtf8());

    handle = bindings.pactffi_new_pact(
        consumer.toNativeUtf8(), provider.toNativeUtf8());
  }

  Interaction given(String providerState) {
    return Interaction(handle, providerState);
  }

  void run() {
    bindings.pactffi_create_mock_server_for_pact(
        handle, '127.0.0.1:1235'.toNativeUtf8(), 0);
  }

  void writePactFile() {
    final isVerified = bindings.pactffi_mock_server_matched(1235);

    /// TODO: Int8 -> Bool
    if (isVerified != 1) {
      final mismatches = jsonDecode(
          bindings.pactffi_mock_server_mismatches(1235).toDartString());

      // TODO: Loop over all mismatches and return to user!
      for (Map mismatch in mismatches) {
        print(mismatch);
      }
      throw PactMockServiceMismatchError();
    }

    final writeOutcome =
        bindings.pactffi_write_pact_file(1235, 'contracts'.toNativeUtf8(), 1);

    if (writeOutcome != PactWriteStatusCodes.OK) {
      throw PactWriteError(writeOutcome);
    }
  }
}
