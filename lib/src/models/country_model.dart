/// A [Country] model represents an instance of a country which contains
/// information about the country
class Country {
  /// The name of the [Country]
  final String? name;

  /// The alpha 2 isoCode of the [Country]
  final String? alpha2Code;

  /// The alpha 3 isoCode of the [Country]
  final String? alpha3Code;

  /// The dialCode of the [Country]
  final String? dialCode;

  /// The currencyCode of the [Country]
  final String? currencyCode;

  /// The currencySymbol of the [Country]
  final String? currencySymbol;

  /// The currencyName of the [Country]
  final String? currencyName;

  /// The nameTranslation for translation
  final Map<String, String>? nameTranslations;

  /// The minLength for phoneNumber
  final int minLength;

  /// The maxLength for phoneNumber
  final int maxLength;

  /// The Currency Selector position
  final bool symbolOnLeft;

  Country({
    required this.name,
    required this.alpha2Code,
    required this.alpha3Code,
    required this.dialCode,
    required this.minLength,
    required this.maxLength,
    required this.currencyCode,
    required this.currencyName,
    required this.currencySymbol,
    required this.symbolOnLeft,
    this.nameTranslations,
  });

  /// Convert [Countries.countryList] to [Country] model
  factory Country.fromJson(Map<String, dynamic> data) {
    return Country(
      name: data['en_short_name'],
      alpha2Code: data['alpha_2_code'],
      alpha3Code: data['alpha_3_code'],
      dialCode: data['dial_code'],
      minLength: data['minLength'],
      maxLength: data["maxLength"],
      currencyCode: data["currency_code"],
      currencyName: data["currency_name"],
      symbolOnLeft: data["symbol_on_left"],
      currencySymbol: data["currency_symbol"],
      nameTranslations: data['nameTranslations'] != null
          ? Map<String, String>.from(data['nameTranslations'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Country &&
        other.alpha2Code == this.alpha2Code &&
        other.alpha3Code == this.alpha3Code &&
        other.dialCode == this.dialCode;
  }

  @override
  int get hashCode => Object.hashAll([alpha2Code, alpha3Code, dialCode]);

  @override
  String toString() => '[Country] { '
      'name: $name, '
      'alpha2: $alpha2Code, '
      'alpha3: $alpha3Code, '
      'dialCode: $dialCode '
      '}';
}
