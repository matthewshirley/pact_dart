class PactMatcherError extends Error {
  final String reason;

  PactMatcherError(this.reason);

  @override
  String toString() => 'Unable to create PactMatcher. $reason';
}

class PactMismatchError extends Error {
  final String mismatches;

  PactMismatchError(this.mismatches);

  @override
  String toString() =>
      'Pact was unable to verify all interactions. Pact returned: $mismatches';
}

class PactWriteError extends Error {
  final int errorCode;

  PactWriteError(this.errorCode);

  String errorCodeDescription() {
    switch (errorCode) {
      case 1:
        return 'A general panic was caught';

      case 2:
        return 'The pact file was not able to be written';

      case 3:
        return 'A mock server with the provided port was not found';

      default:
        return 'Unexcepted error';
    }
  }

  @override
  String toString() =>
      'The mock service failed to write the pact file due to [Code: $errorCodeDescription()]';
}
