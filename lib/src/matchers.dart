import 'package:pact_dart/src/errors.dart';

class PactMatchers {
  static const EMAIL_REGEX = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$';
  static const UUID_REGEX = r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$';

  /// Matches that the type and value is equal.
  static Map EqualTo(dynamic example) {
    return {'pact:matcher:type': 'equality', 'value': example};
  }

  static Map Term(String regex, String example) {
    if (regex.isEmpty || example.isEmpty) {
      throw PactMatcherError('`regex` and `example` cannot be empty.');
    }

    final isExampleValid = RegExp(regex).hasMatch(example);
    if (!isExampleValid) {
      throw PactMatcherError('`example` was not matched by the regex passed.');
    }

    return {'pact:matcher:type': 'regex', 'regex': regex, 'value': example};
  }

  /// Matches that the type is equal, and does not care for the value.
  ///
  /// For example, "Betsy" is the same type as "Graham"
  static Map SomethingLike(dynamic example) {
    if (example is Function) {
      throw PactMatcherError('`example` cannot be a function.');
    }

    return {'pact:matcher:type': 'type', 'value': example};
  }

  /// Matches that a list of elements are the same type.
  ///
  /// For example, if the [value] is [1, 2, 3] then [4, 5, 3] would be a valid
  /// match while ["a", "b", "c"] would not be.
  ///
  /// Optionally, set [min] and/or [max] to specify the boundary of the array.
  static Map EachLike(dynamic example, {int min = 0, int? max}) {
    if (min < 0) {
      throw PactMatcherError('`min` must be a positive integer.');
    }

    if (max != null && min > max) {
      throw PactMatcherError('`min` cannot be greater than `max`');
    }

    return {
      'pact:matcher:type': 'type',
      'value': example,
      'min': min,
      'max': max
    };
  }

  /// Allows heterogenous items to be matched within a list.
  /// Unlike EachLike which must be an array with elements of the same shape,
  /// ArrayContaining allows objects of different types and shapes.
  static Map ArrayContaining(List variants) {
    return {
      'pact:matcher:type': 'arrayContains',
      'variants': variants,
    };
  }

  /// Matches a "Integer" (int) value, for example, 1.
  static Map IntegerLike(int example) {
    return {
      'pact:matcher:type': 'integer',
      'value': example,
    };
  }

  /// Matches a "Decimal" (double) value, for example, 0.84.
  static Map DecimalLike(double example) {
    return {
      'pact:matcher:type': 'decimal',
      'value': example,
    };
  }

  /// Matches a null value
  static Map Null() {
    return {
      'pact:matcher:type': 'null',
    };
  }

  /// Matches that [value] is contained within the value being tested.
  ///
  /// For example, "Betsy" appears in the value "Betsy is an alligator".
  static Map Includes(dynamic value) {
    if (value is Function) {
      throw PactMatcherError('`value` cannot be a function.');
    }

    return {'pact:matcher:type': 'include', 'value': value};
  }

  static Map email(example) {
    return PactMatchers.Term(EMAIL_REGEX, example);
  }

  static Map uuid(example) {
    return PactMatchers.Term(UUID_REGEX, example);
  }
}
