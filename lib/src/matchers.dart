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
  static Map EachLike(dynamic example, {int min = 1, int? max}) {
    if (min < 1) {
      throw PactMatcherError('`min` must be greater than zero.');
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

  /// Query parameter matchers

  /// Match a query parameter with a regex pattern
  ///
  /// Example: QueryRegex('AB123', '^[A-Z]{2}\\d{3}$')
  static Map QueryRegex(String example, String regex) {
    return Term(regex, example);
  }

  /// Match a query parameter with multiple values
  ///
  /// Example: QueryMultiValue(['1', '2', '3'])
  static Map QueryMultiValue(List<String> values) {
    if (values.isEmpty) {
      throw PactMatcherError('`values` cannot be empty.');
    }

    return {'value': values};
  }

  /// Match all values in a query parameter list with a regex pattern
  ///
  /// Example: QueryMultiRegex(['type1', 'type2'], '^type\\d+$')
  static Map QueryMultiRegex(List<String> examples, String regex) {
    if (regex.isEmpty || examples.isEmpty) {
      throw PactMatcherError('`regex` and `examples` cannot be empty.');
    }

    for (final example in examples) {
      final isExampleValid = RegExp(regex).hasMatch(example);
      if (!isExampleValid) {
        throw PactMatcherError(
            'Example "$example" was not matched by the regex passed.');
      }
    }

    return {'pact:matcher:type': 'regex', 'regex': regex, 'value': examples};
  }

  /// Match a query parameter based on its type
  ///
  /// Example: QueryLike(10) - will match any integer
  /// Example: QueryLike(10.5) - will match any decimal
  /// Example: QueryLike("string") - will match any string
  /// Example: QueryLike(true) - will match any boolean
  static Map QueryLike(dynamic example) {
    if (example is int) {
      return IntegerLike(example);
    } else if (example is double) {
      return DecimalLike(example);
    } else {
      return SomethingLike(example);
    }
  }

  /// Match a query parameter with multiple values of the same type
  ///
  /// Example: QueryEachLike("value", min: 1) - will match an array of strings
  /// Example: QueryEachLike(10, min: 2) - will match an array of at least 2 integers
  static Map QueryEachLike(dynamic example, {int min = 1, int? max}) {
    return EachLike(example, min: min, max: max);
  }
}
