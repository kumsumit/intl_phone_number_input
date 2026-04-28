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
- Blocks `+` country-code entry in the text field and supports a localized warning message

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

The text field is intended for the national number only. The selected country supplies the dial code context, so the widget rejects `+` country-code input and can show a custom localized warning message.

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
  countryCodeWarningMessage: 'Enter the local number only',
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

## Quick Notes

- The input field is for the national number only.
- The selected country provides the dial code context.
- If a user types `+`, the widget blocks that input and can show `countryCodeWarningMessage`.
- `detectedCountryOrderStrategy` controls how detection affects selector ordering.
- `SelectorConfig` controls how the selector looks and behaves.

## Common Configuration

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
  countryCodeWarningMessage: 'Enter the local number only',
  autoValidateMode: AutovalidateMode.disabled,
)
```

Common options:

- `countries`: the available selector entries
- `defaultCountry`: the initial selector value
- `filterFunction`: optional search/filter override for the selector list
- `formatInput`: enables the as-you-type formatter
- `disableLengthCheck`: skips metadata-based max-length enforcement in the formatter
- `countryCodeWarningMessage`: localized warning shown when a user tries to enter `+` country-code text
- `autoDetectCountry`: uses `CountryDetector` to guess the initial country
- `detectedCountryOrderStrategy`: controls how the selector list is reordered after detection
- `countryNeighborResolver`: optional callback to override the built-in boundary-sharing neighbors for a given ISO code
- `selectorConfig`: controls selector mode and styling
- `textFieldController`: pass your own controller when the parent owns the text lifecycle

Conditional options:

- `spaceBetweenSelectorAndTextField`: only applies when `selectorConfig.setSelectorButtonAsPrefixIcon` is `false`
- `betweenTextFieldWidget`: only applies when `selectorConfig.setSelectorButtonAsPrefixIcon` is `false`
- `selectorButtonBottomWidget`: only applies when `selectorConfig.setSelectorButtonAsPrefixIcon` is `false`
- `hintText`: only used when `inputDecoration` is not provided
- `label`: only used when `inputDecoration` is not provided
- `inputBorder`: only used when `inputDecoration` is not provided

## InternationalPhoneNumberInput Parameters

- `countries`: list of countries available in the selector
- `defaultCountry`: initially selected country
- `filterFunction`: optional custom country filter for the selector search UI
- `autoDetectCountry`: enables automatic country detection on startup
- `countryDetectionMode`: selects which built-in detection signals to use
- `countryDetector`: optional custom detector that replaces the built-in detector
- `countryNeighborResolver`: optional custom neighbor resolver used by detection-based ordering
- `onAutoCountryDetected`: callback invoked with the country detection result
- `detectedCountryOrderStrategy`: controls how the selector list is reordered after detection
- `selectorConfig`: controls selector layout, search behavior, and selector styling
- `onInputChanged`: callback invoked when the parsed phone number changes
- `onInputValidated`: callback invoked when validity changes
- `onSubmit`: callback invoked when editing is completed
- `onFieldSubmitted`: callback invoked when the user submits the field
- `validator`: optional custom validator for the text field
- `onSaved`: callback invoked when a parent `Form` saves the field
- `fieldKey`: key forwarded to the internal `TextFormField`
- `textFieldController`: optional external text controller
- `keyboardType`: keyboard type used by the text field
- `keyboardAction`: keyboard action button configuration
- `initialValue`: initial phone number used to prefill the field and selected country
- `hintText`: hint text used when `inputDecoration` is not provided
- `label`: label widget used when `inputDecoration` is not provided
- `errorMessage`: default validation error text for invalid numbers
- `countryCodeWarningMessage`: warning shown when the user types a country code into the field
- `selectorButtonOnErrorPadding`: bottom padding used to keep the selector aligned when an error is shown
- `spaceBetweenSelectorAndTextField`: horizontal gap between the external selector button and the text field
- `selectorButtonBottomWidget`: optional widget shown below the external selector button
- `betweenTextFieldWidget`: optional widget shown between the external selector button and the text field
- `isEnabled`: enables or disables interaction
- `formatInput`: formats the number as the user types
- `autoFocus`: autofocuses the text field
- `autoFocusSearch`: autofocuses the selector search field when opened
- `autoValidateMode`: validation mode for the internal `TextFormField`
- `ignoreBlank`: treats blank input as valid when `true`
- `countrySelectorScrollControlled`: controls whether the bottom-sheet selector is scroll-controlled
- `textDirection`: text direction used by the text field
- `textStyle`: text style for the phone number field
- `selectorTextStyle`: text style for the selector button and dropdown items
- `flagStyle`: text style for flag emoji
- `inputBorder`: border used when `inputDecoration` is not provided
- `inputDecoration`: base decoration for the text field
- `searchBoxDecoration`: decoration for the selector search field
- `cursorColor`: cursor color for the text field
- `textAlign`: horizontal text alignment in the field
- `textAlignVertical`: vertical text alignment in the field
- `scrollPadding`: scroll padding forwarded to the internal `TextFormField`
- `onTap`: callback invoked when the text field is tapped
- `focusNode`: focus node for the text field
- `autofillHints`: autofill hints for the text field
- `flagSize`: font size used for flag emoji
- `disableLengthCheck`: disables metadata-based length enforcement in the formatter

Notes for conditional parameters:

- `spaceBetweenSelectorAndTextField`, `selectorButtonBottomWidget`, and `betweenTextFieldWidget` only apply when `selectorConfig.setSelectorButtonAsPrefixIcon` is `false`
- `hintText`, `label`, and `inputBorder` only apply when `inputDecoration` is not provided

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

Key options:

- `selectorType`: chooses between dropdown, dialog, and bottom-sheet selector UIs
- `showFlags`: controls flag visibility consistently in the selector button, dropdown items, and search list rows
- `countryComparator`: applies custom sorting to the selector list before any detection-based reordering
- `setSelectorButtonAsPrefixIcon`: places the selector inside the text field instead of beside it
- `leadingPadding` and `trailingPadding`: adjust selector spacing
- `trailingSpace`: pads short dial codes for steadier layout
- `useBottomSheetSafeArea`: enables safe-area handling for the bottom-sheet selector
- `titleStyle` and `subtitleStyle`: style country names and dial codes in the selector list
- `searchHintText`: custom hint for the selector search field
- `emptySearchMessage`: custom empty-state text when no country matches

## SelectorConfig Parameters

- `selectorType`: selector presentation style
- `showFlags`: whether flags are shown throughout the selector UI
- `countryComparator`: optional custom sort callback for countries
- `setSelectorButtonAsPrefixIcon`: whether the selector is rendered inside the text field
- `leadingPadding`: optional leading spacing for selector content
- `trailingPadding`: optional trailing spacing for selector content
- `trailingSpace`: whether short dial codes receive extra padding
- `useBottomSheetSafeArea`: whether the bottom-sheet selector respects safe areas
- `titleStyle`: text style for country names in the selector list
- `subtitleStyle`: text style for country dial codes and selector empty-state text
- `searchHintText`: hint shown in the selector search field
- `emptySearchMessage`: message shown when no country matches the search query

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
