// lib/services/country_detector.dart

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;

import 'country_borders_data.dart';
import 'country_coordinates_data.dart';

class CountryResult {
  final String? countryCode;
  final String? countryName;
  final String? city;
  final String? timezone;
  final String? locale;
  final String? ip;
  final int confidence; // 0–100
  final Map<String, int> allVotes;

  const CountryResult({
    this.countryCode,
    this.countryName,
    this.city,
    this.timezone,
    this.locale,
    this.ip,
    this.confidence = 0,
    this.allVotes = const {},
  });

  @override
  String toString() =>
      'CountryResult(country: $countryCode, confidence: $confidence%, city: $city)';
}

class CountryDetector {
  // // ── Country code → Name ────────────────────────────────────────────────────
  static const Map<String, String> countryNames = {
    'AF': 'Afghanistan',
    'AL': 'Albania',
    'DZ': 'Algeria',
    'AS': 'American Samoa',
    'AD': 'Andorra',
    'AO': 'Angola',
    'AI': 'Anguilla',
    'AQ': 'Antarctica',
    'AG': 'Antigua and Barbuda',
    'AR': 'Argentina',
    'AM': 'Armenia',
    'AW': 'Aruba',
    'AU': 'Australia',
    'AT': 'Austria',
    'AZ': 'Azerbaijan',
    'BS': 'Bahamas',
    'BH': 'Bahrain',
    'BD': 'Bangladesh',
    'BB': 'Barbados',
    'BY': 'Belarus',
    'BE': 'Belgium',
    'BZ': 'Belize',
    'BJ': 'Benin',
    'BM': 'Bermuda',
    'BT': 'Bhutan',
    'BO': 'Bolivia',
    'BA': 'Bosnia and Herzegovina',
    'BW': 'Botswana',
    'BR': 'Brazil',
    'BN': 'Brunei',
    'BG': 'Bulgaria',
    'BF': 'Burkina Faso',
    'BI': 'Burundi',
    'KH': 'Cambodia',
    'CM': 'Cameroon',
    'CA': 'Canada',
    'CV': 'Cape Verde',
    'CF': 'Central African Republic',
    'TD': 'Chad',
    'CL': 'Chile',
    'CN': 'China',
    'CO': 'Colombia',
    'KM': 'Comoros',
    'CD': 'Congo (DRC)',
    'CG': 'Congo',
    'CR': 'Costa Rica',
    'CI': 'Côte d\'Ivoire',
    'HR': 'Croatia',
    'CU': 'Cuba',
    'CY': 'Cyprus',
    'CZ': 'Czechia',
    'DK': 'Denmark',
    'DJ': 'Djibouti',
    'DM': 'Dominica',
    'DO': 'Dominican Republic',
    'EC': 'Ecuador',
    'EG': 'Egypt',
    'SV': 'El Salvador',
    'GQ': 'Equatorial Guinea',
    'ER': 'Eritrea',
    'EE': 'Estonia',
    'ET': 'Ethiopia',
    'FJ': 'Fiji',
    'FI': 'Finland',
    'FR': 'France',
    'GA': 'Gabon',
    'GM': 'Gambia',
    'GE': 'Georgia',
    'DE': 'Germany',
    'GH': 'Ghana',
    'GR': 'Greece',
    'GD': 'Grenada',
    'GT': 'Guatemala',
    'GN': 'Guinea',
    'GW': 'Guinea-Bissau',
    'GY': 'Guyana',
    'HT': 'Haiti',
    'HN': 'Honduras',
    'HU': 'Hungary',
    'IS': 'Iceland',
    'IN': 'India',
    'ID': 'Indonesia',
    'IR': 'Iran',
    'IQ': 'Iraq',
    'IE': 'Ireland',
    'IL': 'Israel',
    'IT': 'Italy',
    'JM': 'Jamaica',
    'JP': 'Japan',
    'JO': 'Jordan',
    'KZ': 'Kazakhstan',
    'KE': 'Kenya',
    'KI': 'Kiribati',
    'KP': 'North Korea',
    'KR': 'South Korea',
    'KW': 'Kuwait',
    'KG': 'Kyrgyzstan',
    'LA': 'Laos',
    'LV': 'Latvia',
    'LB': 'Lebanon',
    'LS': 'Lesotho',
    'LR': 'Liberia',
    'LY': 'Libya',
    'LI': 'Liechtenstein',
    'LT': 'Lithuania',
    'LU': 'Luxembourg',
    'MG': 'Madagascar',
    'MW': 'Malawi',
    'MY': 'Malaysia',
    'MV': 'Maldives',
    'ML': 'Mali',
    'MT': 'Malta',
    'MH': 'Marshall Islands',
    'MR': 'Mauritania',
    'MU': 'Mauritius',
    'MX': 'Mexico',
    'FM': 'Micronesia',
    'MD': 'Moldova',
    'MC': 'Monaco',
    'MN': 'Mongolia',
    'ME': 'Montenegro',
    'MA': 'Morocco',
    'MZ': 'Mozambique',
    'MM': 'Myanmar',
    'NA': 'Namibia',
    'NR': 'Nauru',
    'NP': 'Nepal',
    'NL': 'Netherlands',
    'NZ': 'New Zealand',
    'NI': 'Nicaragua',
    'NE': 'Niger',
    'NG': 'Nigeria',
    'NO': 'Norway',
    'OM': 'Oman',
    'PK': 'Pakistan',
    'PW': 'Palau',
    'PA': 'Panama',
    'PG': 'Papua New Guinea',
    'PY': 'Paraguay',
    'PE': 'Peru',
    'PH': 'Philippines',
    'PL': 'Poland',
    'PT': 'Portugal',
    'QA': 'Qatar',
    'RO': 'Romania',
    'RU': 'Russia',
    'RW': 'Rwanda',
    'KN': 'Saint Kitts and Nevis',
    'LC': 'Saint Lucia',
    'VC': 'Saint Vincent and the Grenadines',
    'WS': 'Samoa',
    'SM': 'San Marino',
    'ST': 'Sao Tome and Principe',
    'SA': 'Saudi Arabia',
    'SN': 'Senegal',
    'RS': 'Serbia',
    'SC': 'Seychelles',
    'SL': 'Sierra Leone',
    'SG': 'Singapore',
    'SK': 'Slovakia',
    'SI': 'Slovenia',
    'SB': 'Solomon Islands',
    'SO': 'Somalia',
    'ZA': 'South Africa',
    'ES': 'Spain',
    'LK': 'Sri Lanka',
    'SD': 'Sudan',
    'SR': 'Suriname',
    'SE': 'Sweden',
    'CH': 'Switzerland',
    'SY': 'Syria',
    'TW': 'Taiwan',
    'TJ': 'Tajikistan',
    'TZ': 'Tanzania',
    'TH': 'Thailand',
    'TL': 'Timor-Leste',
    'TG': 'Togo',
    'TO': 'Tonga',
    'TT': 'Trinidad and Tobago',
    'TN': 'Tunisia',
    'TR': 'Turkey',
    'TM': 'Turkmenistan',
    'TV': 'Tuvalu',
    'UG': 'Uganda',
    'UA': 'Ukraine',
    'AE': 'United Arab Emirates',
    'GB': 'United Kingdom',
    'US': 'United States',
    'UY': 'Uruguay',
    'UZ': 'Uzbekistan',
    'VU': 'Vanuatu',
    'VA': 'Vatican City',
    'VE': 'Venezuela',
    'VN': 'Vietnam',
    'YE': 'Yemen',
    'ZM': 'Zambia',
    'ZW': 'Zimbabwe',
    'XK': 'Kosovo', // widely used unofficial ISO
    'PS': 'Palestine',
    'HK': 'Hong Kong',
    'MO': 'Macau',

    // Disputed / partially recognized
    'EH': 'Western Sahara',
    'NC': 'Northern Cyprus', // unofficial (TRNC)
    'AB': 'Abkhazia', // unofficial
    'OS': 'South Ossetia', // unofficial
    'SXK': 'Sark', // edge micro-territory (rare use)
    'XU': 'European Union', // non-country but sometimes used
  };

  // ── Signal 1: Timezone (instant, no permission) ───────────────────────────
  static Future<Map<String, String?>> _getTimezoneSignal() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      if (timezone.identifier.isNotEmpty) {
        return {
          'country': getCountryCodeForTimezone(timezone.identifier),
          'timezone': timezone.identifier,
        };
      }
    } catch (_) {
      // ignore and fallback
    }
    // Always return a valid map if failed
    return {'country': null, 'timezone': null};
  }

  // ── Signal 2: Locale / Language (instant, no permission) ──────────────────
  static Map<String, String?> _getLocaleSignal() {
    try {
      final locale = PlatformDispatcher.instance.locale;
      final tag = locale.toLanguageTag(); // e.g. "en-IN"
      String? country = locale.countryCode; // Flutter gives this directly!
      return {'country': country, 'locale': tag};
    } catch (_) {
      return {'country': null, 'locale': null};
    }
  }

  // ── Signal 3: Offset (instant, no permission) ──────────────────────────────
  static Map<String, dynamic> _getOffsetSignal() {
    try {
      final offset = (DateTime.now().timeZoneOffset.inMinutes / 60).toString();
      final countries = getCountriesForOffset(offset); // List<String>
      return {
        'countries': countries, // List of country codes
        'offset': offset,
      };
    } catch (_) {
      return {'countries': <String>[], 'offset': null};
    }
  }

  // ── Signal 4: System locale list (extra hints) ─────────────────────────────
  static Map<String, String?> _getLocalesSignal() {
    try {
      final locales = PlatformDispatcher.instance.locales;
      for (final locale in locales) {
        if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
          return {
            'country': locale.countryCode,
            'locale': locale.toLanguageTag(),
          };
        }
      }
      return {'country': null, 'locale': null};
    } catch (_) {
      return {'country': null, 'locale': null};
    }
  }

  // ── Signal 5: IP Geolocation (async, most accurate) ───────────────────────
  static Future<Map<String, String?>> _getIPSignal() async {
    final apis = [_fetchIpApiCo, _fetchIpApiCom, _fetchFreeIpApi];
    for (final fetcher in apis) {
      try {
        final result = await fetcher().timeout(const Duration(seconds: 4));
        if (result['country'] != null) return result;
      } catch (_) {
        continue;
      }
    }
    return {'country': null, 'city': null, 'ip': null};
  }

  static Future<Map<String, String?>> _fetchIpApiCo() async {
    final res = await http.get(Uri.parse('https://ipapi.co/json/'));
    final data = jsonDecode(res.body);
    return {
      'country': data['country_code'],
      'city': data['city'],
      'ip': data['ip'],
    };
  }

  static Future<Map<String, String?>> _fetchIpApiCom() async {
    final res = await http.get(
      Uri.parse('https://ip-api.com/json/?fields=countryCode,city,query'),
    );
    final data = jsonDecode(res.body);
    return {
      'country': data['countryCode'],
      'city': data['city'],
      'ip': data['query'],
    };
  }

  static Future<Map<String, String?>> _fetchFreeIpApi() async {
    final res = await http.get(Uri.parse('https://freeipapi.com/api/json'));
    final data = jsonDecode(res.body);
    return {
      'country': data['countryCode'],
      'city': data['cityName'],
      'ip': data['ipAddress'],
    };
  }

  // ── Combiner ───────────────────────────────────────────────────────────────
  static CountryResult _combine({
    required Map<String, String?> ip,
    required Map<String, String?> timezone,
    required Map<String, dynamic> offset,
    required Map<String, String?> locale,
    required Map<String, String?> locales,
  }) {
    final weighted = <String, int>{};

    void vote(String? country, int weight) {
      if (country == null || country.isEmpty) return;
      final c = country.toUpperCase();
      weighted[c] = (weighted[c] ?? 0) + weight;
    }

    void voteMany(List<String> countries, int weight) {
      for (final c in countries) {
        vote(c, weight);
      }
    }

    vote(ip['country'], 60);
    vote(timezone['country'], 20);
    vote(locale['country'], 15);
    vote(locales['country'], 5);
    // Boost all possible countries for this offset
    final offsetCountries =
        (offset['countries'] as List?)?.cast<String>() ?? [];
    voteMany(offsetCountries, 10);

    if (weighted.isEmpty) {
      return const CountryResult(confidence: 0);
    }

    final sorted = weighted.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCode = sorted.first.key;
    final topScore = sorted.first.value;
    final confidence = topScore.clamp(0, 100);

    return CountryResult(
      countryCode: topCode,
      countryName: countryNames[topCode],
      city: ip['city'],
      timezone: timezone['timezone'],
      locale: locale['locale'],
      ip: ip['ip'],
      confidence: confidence,
      allVotes: Map.fromEntries(sorted),
    );
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Instant best-guess from timezone + locale only (no network call).
  static Future<CountryResult> detectSync() async {
    final tz = await _getTimezoneSignal();
    debugPrint('[CountryDetector] timezone signal:   $tz');
    final offset = _getOffsetSignal();
    debugPrint('[CountryDetector] offset signal:     $offset');
    final loc = _getLocaleSignal();
    debugPrint('[CountryDetector] locale signal:     $loc');
    final locs = _getLocalesSignal();
    debugPrint('[CountryDetector] locales signal:    $locs');
    return _combine(
      ip: {},
      timezone: tz,
      offset: offset,
      locale: loc,
      locales: locs,
    );
  }

  /// Full detection including IP geolocation (async, most accurate).
  static Future<CountryResult> detect() async {
    final tz = await _getTimezoneSignal();
    debugPrint('[CountryDetector] timezone signal:   $tz');
    final offset = _getOffsetSignal();
    debugPrint('[CountryDetector] offset signal:     $offset');
    final loc = _getLocaleSignal();
    debugPrint('[CountryDetector] locale signal:     $loc');
    final locs = _getLocalesSignal();
    debugPrint('[CountryDetector] locales signal:    $locs');
    final ip = await _getIPSignal();
    debugPrint('[CountryDetector] ip signal:         $ip');
    return _combine(
      ip: ip,
      timezone: tz,
      offset: offset,
      locale: loc,
      locales: locs,
    );
  }

  static List<String> possibleBoundaryCountriesFor(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      return const [];
    }

    final borders = countryBorders[normalized];
    if (borders != null) {
      return List.unmodifiable(borders);
    }

    try {
      final origin = countryCoordinates[normalized];
      if (origin == null) {
        return const [];
      }

      final ranked =
          countryCoordinates.entries
              .where((entry) => entry.key != normalized)
              .map(
                (entry) => (
                  code: entry.key,
                  distanceKm: origin.distanceTo(entry.value),
                ),
              )
              .toList(growable: false)
            ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      return List.unmodifiable(ranked.take(4).map((entry) => entry.code));
    } catch (error, stackTrace) {
      debugPrint('[CountryDetector] failed to rank boundary countries: $error');
      debugPrintStack(stackTrace: stackTrace);
      return const [];
    }
  }

  static List<String> rankCountriesByDistanceFrom(
    String code,
    Iterable<String> countryCodes,
  ) {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      return List.unmodifiable(
        countryCodes.map((item) => item.trim().toUpperCase()),
      );
    }

    try {
      final origin = countryCoordinates[normalized];
      if (origin == null) {
        return List.unmodifiable(
          countryCodes.map((item) => item.trim().toUpperCase()),
        );
      }

      final known = <({String code, double distanceKm})>[];
      final unknown = <String>[];

      for (final rawCode in countryCodes) {
        final candidate = rawCode.trim().toUpperCase();
        if (candidate.isEmpty || candidate == normalized) {
          continue;
        }

        final coordinates = countryCoordinates[candidate];
        if (coordinates == null) {
          unknown.add(candidate);
          continue;
        }

        known.add((
          code: candidate,
          distanceKm: origin.distanceTo(coordinates),
        ));
      }

      known.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      return List.unmodifiable([
        ...known.map((entry) => entry.code),
        ...unknown,
      ]);
    } catch (error, stackTrace) {
      debugPrint('[CountryDetector] failed to rank countries by distance: $error');
      debugPrintStack(stackTrace: stackTrace);
      return List.unmodifiable(
        countryCodes.map((item) => item.trim().toUpperCase()),
      );
    }
  }
}

extension on CountryCoordinates {
  double distanceTo(CountryCoordinates other) {
    const earthRadiusKm = 6371.0;
    final lat1 = _degreesToRadians(latitude);
    final lat2 = _degreesToRadians(other.latitude);
    final deltaLat = _degreesToRadians(other.latitude - latitude);
    final deltaLon = _degreesToRadians(other.longitude - longitude);

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) => degrees * math.pi / 180;
}
