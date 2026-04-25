import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/country_detector.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';

void main() {
  group('Country', () {
    final country = Country(
      name: 'India',
      alpha2Code: 'IN',
      alpha3Code: 'IND',
      dialCode: '+91',
    );

    test('matches by name, code, and dial code', () {
      expect(country.matches('india'), isTrue);
      expect(country.matches('in'), isTrue);
      expect(country.matches('IND'), isTrue);
      expect(country.matches('+91'), isTrue);
      expect(country.matches('usa'), isFalse);
    });

    test('compares equality by country codes and dial code', () {
      final sameCountry = Country(
        name: 'Bharat',
        alpha2Code: 'IN',
        alpha3Code: 'IND',
        dialCode: '+91',
      );

      expect(country, sameCountry);
      expect(country.hashCode, sameCountry.hashCode);
    });

    test('uses shared utility filtering', () {
      final countries = <Country>[
        country,
        Country(
          name: 'United States',
          alpha2Code: 'US',
          alpha3Code: 'USA',
          dialCode: '+1',
        ),
      ];

      final result = Utils.filterCountries(countries, 'uni');

      expect(result.map((item) => item.alpha2Code), ['US']);
    });
  });

  group('CountryDetector', () {
    test('returns nearby boundary countries for a known country code', () {
      final result = CountryDetector.possibleBoundaryCountriesFor('IN');

      expect(result, isNotEmpty);
      expect(result, isNot(contains('IN')));
    });

    test('ranks countries by distance from the detected country', () {
      final result = CountryDetector.rankCountriesByDistanceFrom('US', [
        'IN',
        'CA',
        'MX',
      ]);

      expect(result.take(2), ['MX', 'CA']);
    });
  });
}
