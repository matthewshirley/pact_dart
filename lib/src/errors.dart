class EmptyParameterError extends Error {
  String parameter = '';

  EmptyParameterError(this.parameter);

  @override
  String toString() => '`$parameter` cannot be empty.';
}

class EmptyParametersError extends Error {
  List<String> parameters = [];

  EmptyParametersError(this.parameters);

  @override
  String toString() => '${parameters.join(' or ')} cannot be empty.';
}

class NoInteractionsError extends Error {
  @override
  String toString() =>
      'There are no interactions registered for the mock service to handle.';
}

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

class PactCreateMockServerError extends Error {
  final int errorCode;

  PactCreateMockServerError(this.errorCode);

  String get errorDescription {
    switch (errorCode) {
      case -1:
        return 'An invalid handle was received';

      case -3:
        return 'The mock server could not be started';

      case -4:
        return 'The method panicked';

      case -5:
        return 'The address is not valid';

      case -6:
        return 'Could not create the TLS configuration with the self-signed certificate';

      default:
        return 'Unexpected code. Please raise issue on GitHub Repo (github.com/matthewshirley/pact_dart)';
    }
  }

  @override
  String toString() =>
      'Unable to create the mock service because it returned the error code $errorCode ($errorDescription)';
}

class PactWriteError extends Error {
  final int errorCode;

  PactWriteError(this.errorCode);

  String errorDescription() {
    switch (errorCode) {
      case 1:
        return 'A general panic was caught';

      case 2:
        return 'The pact file was not able to be written';

      case 3:
        return 'A mock server with the provided port was not found';

      default:
        return 'Unexpected code, please raise issue on GitHub Repo (github.com/matthewshirley/pact_dart)';
    }
  }

  @override
  String toString() =>
      'Unable to write pact file because the mock service returned the error code $errorCode ($errorDescription)';
}
