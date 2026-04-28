import 'package:intl_phone_number_input/src/utils/country_detector.dart';

enum PhoneInputSelectorType { DROPDOWN, BOTTOM_SHEET, DIALOG }


enum CountryDetectionMode { localSignals, networkSignals }

enum DetectedCountryOrderStrategy {
  none,
  detectedCountryFirst,
  signalVotesThenDistance,
  signalVotesThenNeighborsThenDistance,
}

typedef CountryDetectorCallback = Future<CountryResult> Function();
typedef CountryNeighborResolver = List<String> Function(String countryCode);
