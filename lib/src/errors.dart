import 'dart:convert';

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

enum MismatchErrorType {
  MissingRequest,
  RequestNotFound,
  RequestMismatch,
  MockServerParsingFail,
  Unknown;

  static MismatchErrorType fromType(String type) {
    switch (type) {
      case 'missing-request':
        return MissingRequest;

      case 'request-not-found':
        return RequestNotFound;

      case 'request-mismatch':
        return RequestMismatch;

      case 'mock-server-parsing-fail':
        return MockServerParsingFail;

      default:
        return Unknown;
    }
  }
}

extension MismatchErrorTypeReason on MismatchErrorType {
  static var errorReasons = {
    MismatchErrorType.MissingRequest: 'Request was missing',
    MismatchErrorType.RequestNotFound: 'Request was unexpected',
    MismatchErrorType.RequestMismatch: 'Request was not matched',
    MismatchErrorType.MockServerParsingFail:
        'Mock Server was uanble to parse the failure.',
    MismatchErrorType.Unknown: 'Something went wrong.'
  };

  String get reason => errorReasons[this] ?? 'Something went wrong';
}

class PactMatchFailure extends Error {
  late List errors;

  PactMatchFailure(String mismatches) {
    errors = jsonDecode(mismatches);
  }

  @override
  String toString() {
    var output = 'Pact was unable to validate one or more interaction(s):\n\n';
    var errorReason = '';

    var index = 1;
    errors.forEach((error) {
      var errorType = MismatchErrorType.fromType(error['type']);
      errorReason = errorType.reason;
      var expected = '';
      var actual = '';

      switch (errorType) {
        case MismatchErrorType.MissingRequest:
          expected += '${error['method']} ${error['path']}';
          break;

        case MismatchErrorType.RequestNotFound:
          expected += '';
          actual += '${error['method']} ${error['path']}';
          break;

        case MismatchErrorType.RequestMismatch:
          var mismatches = error['mismatches'];
          errorReason += " (${error['method']} ${error['path']})";

          mismatches.forEach((mismatch) {
            expected += '- ${mismatch['mismatch']}\n\t\t';
          });
          break;

        default:
          break;
      }

      output += 'Interaction Mismatch #$index\n';
      output += '\tReason:\n\t\t$errorReason\n';
      if (expected.isNotEmpty) {
        output += '\n\tExpected:\n\t\t$expected\n';
      }

      if (actual.isNotEmpty) {
        output += '\n\tActual:\n\t\t$actual\n\n';
      }

      index++;
    });

    return output;
  }
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

  String get errorDescription {
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
