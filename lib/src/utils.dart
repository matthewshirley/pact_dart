import 'package:pact_dart/pact_dart.dart';

/// Pact matchers helper
///
/// This class contains all the matchers that are used in the project.
/// It is used to generate the pact files.
///
abstract class PactMatchersHelper {
  // UUID v4 matcher
  static dynamic uuid([
    String example = '8cea59b8-97d3-4ceb-aa67-c8769e0ea1e5',
  ]) {
    return PactMatchers.Term(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      example,
    );
  }

  // Email matcher
  static dynamic email([String example = 'user@example.com']) {
    return PactMatchers.Term(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      example,
    );
  }

  // Date matcher
  static dynamic date([String example = '2023-01-01']) {
    return PactMatchers.Term(
      r'^\d{4}-\d{2}-\d{2}$',
      example,
    );
  }

  // DateTime matcher
  static dynamic dateTime([String example = '2023-01-01T12:00:00Z']) {
    return PactMatchers.Term(
      r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$',
      example,
    );
  }
}
