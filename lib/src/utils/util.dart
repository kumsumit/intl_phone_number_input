import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:phone_parser/phone_parser.dart';

/// [Utils] class contains utility methods for `intl_phone_number_input` library
class Utils {
  static final Map<String, String> _flagCache = <String, String>{};

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

  /// Returns the subset of [countries] that match the provided [query].
  static List<Country> filterCountries(List<Country> countries, String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return List<Country>.from(countries);
    }

    return countries
        .where((country) => country.matches(normalizedQuery))
        .toList(growable: false);
  }

  /// Returns a [String] which will be the unicode of a Flag Emoji,
  /// from a country [countryCode] passed as a parameter.
  static String generateFlagEmojiUnicode(String countryCode) {
    return _flagCache.putIfAbsent(countryCode, () {
      final base = 127397;

      return countryCode.codeUnits
          .map((e) => String.fromCharCode(base + e))
          .join();
    });
  }

  /// Returns a formatted local example number for [isoCode] when metadata has
  /// one. Mobile examples are preferred because phone inputs most often collect
  /// mobile numbers.
  static String? examplePhoneNumberHint(String isoCode) {
    try {
      final example =
          PhoneNumber.getExampleNumberForType(
            isoCode: isoCode,
            type: PhoneNumberType.mobile,
          ) ??
          PhoneNumber.getExampleNumberForType(
            isoCode: isoCode,
            type: PhoneNumberType.fixedLine,
          ) ??
          PhoneNumber.getExampleNumber(isoCode);

      if (example == null || example.nsn.isEmpty) {
        return null;
      }

      return PhoneNumberFormatter.formatNsn(
        example.nsn,
        example.isoCode,
        NsnFormat.national,
        false,
      );
    } catch (_) {
      return null;
    }
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
      (e) => e.toString().toLowerCase().split(".").last == toLowerCase(),
    );
  }
}
