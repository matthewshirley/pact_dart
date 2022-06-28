import 'package:ffi/ffi.dart';

import 'package:pact_dart/src/bindings/bindings.dart';
import 'package:pact_dart/src/bindings/constants.dart';
import 'package:pact_dart/src/bindings/types.dart';
import 'package:pact_dart/src/errors.dart';
import 'package:pact_dart/src/ffi/extensions.dart';
import 'package:pact_dart/src/message.dart';

class MessagesPact {
  late MessagePactHandle handle;
  late Message currentMessage;

  List<Message> messages = [];

  MessagesPact(String consumer, String provider) {
    handle = bindings.pactffi_new_message_pact(
        consumer.toNativeUtf8(), provider.toNativeUtf8());
  }

  Message newMessage({String description = ''}) {
    currentMessage = Message(handle, description);
    messages.add(currentMessage);

    return currentMessage;
  }

  void writePactFile({String directory = 'contracts', bool overwrite = false}) {
    final result = bindings.pactffi_write_message_pact_file(
        handle, directory.toNativeUtf8(), overwrite.toInt());

    if (result != PactWriteStatusCodes.OK) {
      throw PactWriteError(result);
    }
  }
}
