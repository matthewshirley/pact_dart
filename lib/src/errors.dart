class PactMockServiceMismatchError extends Error {
  PactMockServiceMismatchError();

  @override
  String toString() => 'PactMockServiceMismatchError';
}

class NotImplemented extends Error {
  final String message;

  NotImplemented(this.message);

  @override
  String toString() => 'NotImplemented: $message';
}

class PactWriteError extends Error {
  final int errorCode;

  PactWriteError(this.errorCode);

  @override
  String toString() =>
      'The mock service failed to write the pact file due to [Code: $errorCode]';
}
