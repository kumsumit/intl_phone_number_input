import 'package:intl_phone_number_input/src/models/country_model.dart';

/// [Utils] class contains utility methods for `intl_phone_number_input` library
class Utils {
  ///  Returns a [Country] form list of [countries] passed that matches [countryCode].
  ///  Returns the first [Country] in the list if no match is available.
  static Country getInitialSelectedCountry(
    List<Country> countries,
    String countryCode,
  ) {
    return countries.firstWhere(
      (country) => country.alpha2Code == countryCode,
      orElse: () => countries[0],
    );
  }

  /// Returns a [String] which will be the unicode of a Flag Emoji,
  /// from a country [countryCode] passed as a parameter.
  static String generateFlagEmojiUnicode(String countryCode) {
    final base = 127397;

    return countryCode.codeUnits
        .map((e) => String.fromCharCode(base + e))
        .toList()
        .reduce((value, element) => value + element)
        .toString();
  }
}

class Patterns {
  /// accepted punctuation within a phone number
  static const String punctuation = r' ()\[\]\-\.\/\\';
  static const String plus = r'\+＋';

  /// Westhen and easthern arabic numerals
  static const String digits = r'0-9０-９٠-٩۰-۹';
}

extension EnumParser on String {
  T toEnum<T>(List<T> values) {
    return values.firstWhere(
      (e) =>
          e.toString().toLowerCase().split(".").last == '$this'.toLowerCase(),
    );
  }
}
