import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';

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
  });
}
