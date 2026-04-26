# Intl Phone Number Input

A customizable Flutter widget for entering, formatting, and validating international phone numbers with [`phone_parser`](https://pub.dev/packages/phone_parser).

| Prefix selector | Bottom sheet | Dialog |
| --- | --- | --- |
| <img src="https://user-images.githubusercontent.com/27495055/80114512-9544b100-857b-11ea-9292-9c9c3eaf93e0.png" width="220" alt="Prefix selector example" /> | <img src="https://user-images.githubusercontent.com/27495055/80116677-261c8c00-857e-11ea-8167-a3de563287f4.png" width="220" alt="Bottom sheet selector example" /> | <img src="https://user-images.githubusercontent.com/27495055/80116721-3896c580-857e-11ea-84da-4efe13011d50.png" width="220" alt="Dialog selector example" /> |

## Features

- International number entry with live formatting
- Validation callbacks and form integration
- Dropdown, dialog, and bottom-sheet country selectors
- RTL-friendly layout
- Custom selector styling, decorations, and search UI
- Optional length-check bypass for custom workflows
- Optional country auto-detection and signal-aware selector ordering

## Install

```yaml
dependencies:
  intl_phone_number_input:
    git:
      url: https://github.com/natintosh/intl-phone-number-input.git
```

This package currently depends on a Git source for `phone_parser`, so it is configured with `publish_to: none`.

## Usage

The widget expects you to provide the country list and a default country. `filterFunction` is optional, and the example app includes a ready-to-use `country_list.dart` if you want a starting point.

```dart
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

final countries = <Country>[
  Country(
    name: 'India',
    alpha2Code: 'IN',
    alpha3Code: 'IND',
    dialCode: '+91',
  ),
  Country(
    name: 'United States',
    alpha2Code: 'US',
    alpha3Code: 'USA',
    dialCode: '+1',
  ),
];

final defaultCountry = countries.first;
final controller = TextEditingController();

InternationalPhoneNumberInput(
  countries: countries,
  defaultCountry: defaultCountry,
  textFieldController: controller,
  selectorConfig: const SelectorConfig(
    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
    setSelectorButtonAsPrefixIcon: true,
  ),
  initialValue: const PhoneNumber(isoCode: 'IN', nsn: ''),
  autoDetectCountry: true,
  detectedCountryOrderStrategy:
      DetectedCountryOrderStrategy.signalVotesThenDistance,
  formatInput: true,
  onInputChanged: (number) {
    debugPrint(number.international);
  },
  onInputValidated: (isValid) {
    debugPrint('valid: $isValid');
  },
  onAutoCountryDetected: (result) {
    debugPrint('detected ${result.countryCode} (${result.confidence}%)');
  },
);
```

## Main Parameters

```dart
InternationalPhoneNumberInput(
  countries: countries,
  defaultCountry: defaultCountry,
  filterFunction: filterFunction,
  selectorConfig: const SelectorConfig(),
  textFieldController: controller,
  initialValue: initialValue,
  onInputChanged: onInputChanged,
  onInputValidated: onInputValidated,
  onSaved: onSaved,
  validator: validator,
  autoDetectCountry: false,
  detectedCountryOrderStrategy: DetectedCountryOrderStrategy.none,
  formatInput: true,
  disableLengthCheck: false,
  ignoreBlank: false,
  autoValidateMode: AutovalidateMode.disabled,
)
```

Important options:

- `countries`: the available selector entries
- `defaultCountry`: the initial selector value
- `filterFunction`: optional search/filter override for the selector list
- `formatInput`: enables the as-you-type formatter
- `disableLengthCheck`: skips metadata-based max-length enforcement in the formatter
- `autoDetectCountry`: uses `CountryDetector` to guess the initial country
- `detectedCountryOrderStrategy`: controls how the selector list is reordered after detection
- `countryNeighborResolver`: optional callback to override the built-in boundary-sharing neighbors for a given ISO code
- `selectorConfig`: controls selector mode and styling
- `textFieldController`: pass your own controller when the parent owns the text lifecycle

## Detection Ordering

Use `detectedCountryOrderStrategy` to control selector ordering after detection:

- `DetectedCountryOrderStrategy.none`: keep the original country list order
- `DetectedCountryOrderStrategy.detectedCountryFirst`: place only the detected country first
- `DetectedCountryOrderStrategy.signalVotesThenDistance`: detected country first, then signal-voted countries, then the rest by geographic distance
- `DetectedCountryOrderStrategy.signalVotesThenNeighborsThenDistance`: detected country first, then signal-voted countries, then built-in boundary-sharing neighbors (or `countryNeighborResolver` overrides), then the remaining countries alphabetically

## SelectorConfig

```dart
const SelectorConfig(
  selectorType: PhoneInputSelectorType.DROPDOWN,
  showFlags: true,
  setSelectorButtonAsPrefixIcon: false,
  useBottomSheetSafeArea: false,
  leadingPadding: 3,
  trailingSpace: true,
)
```

### macOS setup

* If your Flutter macOS app uses the app sandbox, you must allow outbound network access.
* Add this entitlement to both `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:
  ```xml
  <key>com.apple.security.network.client</key>
  <true/>
  ```
* Without it, metadata download can fail with errors like:
  ```text
  SocketException: Connection failed (OS Error: Operation not permitted)
  ```
* Your app also needs write access to the directory you pass to `MetadataFinder.readMetadataJson(...)`.

## Notes

- The widget no longer needs manual `web/index.html` script tags.
- Metadata and formatting come from `phone_parser`.
- If phone metadata is unavailable for a country, the widget now falls back gracefully instead of throwing.

## Development

Local quality checks:

```bash
flutter analyze
flutter test
```

## License

[MIT](LICENSE)
