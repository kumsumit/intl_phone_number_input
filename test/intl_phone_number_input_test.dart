import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:intl_phone_number_input/src/utils/formatter/as_you_type_formatter.dart';
import 'package:intl_phone_number_input/src/widgets/common/flag_widget.dart';
import 'package:phone_parser/src/metadata/bundled_metadata.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    MetadataFinder.info =
        jsonDecode(bundledMetadataJson) as Map<String, dynamic>;
  });

  group('AsYouTypeFormatter', () {
    test('rejects attempts to enter a country code prefix', () {
      var rejected = false;
      var accepted = false;
      final formatter = CountryCodeBlockerFormatter(
        onRejected: () {
          rejected = true;
        },
        onAccepted: () {
          accepted = true;
        },
      );

      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(text: '+1');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result, oldValue);
      expect(rejected, isTrue);
      expect(accepted, isFalse);
    });

    test('allows empty input', () {
      final formatter = AsYouTypeFormatter(
        isoCode: 'US',
        dialCode: '+1',
        acceptedLengths: const [10],
        onInputFormatted: (_) {},
      );

      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '1'),
        const TextEditingValue(text: ''),
      );

      expect(result.text, isEmpty);
    });

    test('blocks input past the accepted max length', () {
      final formatter = AsYouTypeFormatter(
        isoCode: 'US',
        dialCode: '+1',
        acceptedLengths: const [10],
        onInputFormatted: (_) {},
      );

      final oldValue = const TextEditingValue(text: '1234567890');
      final newValue = const TextEditingValue(text: '12345678901');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result, oldValue);
    });

    test('blocks input past 15 digits when accepted lengths are disabled', () {
      final formatter = AsYouTypeFormatter(
        isoCode: 'US',
        dialCode: '+1',
        acceptedLengths: const [],
        onInputFormatted: (_) {},
      );

      const oldValue = TextEditingValue(text: '123456789012345');
      const newValue = TextEditingValue(text: '1234567890123456');

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result, oldValue);
    });

    test('preserves a regional leading zero while checking NSN length', () {
      final formatter = AsYouTypeFormatter(
        isoCode: 'IT',
        dialCode: '+39',
        acceptedLengths: const [10],
        onInputFormatted: (_) {},
      );

      const newValue = TextEditingValue(
        text: '0212345678',
        selection: TextSelection.collapsed(offset: 10),
      );

      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: ''),
        newValue,
      );

      expect(result.text, '02 1234 5678');
    });

    test('formats and deletes Indian mobile input consistently', () {
      final formatter = AsYouTypeFormatter(
        isoCode: 'IN',
        dialCode: '+91',
        acceptedLengths: const [10],
        onInputFormatted: (_) {},
      );
      var value = const TextEditingValue(text: '');
      final insertionOutputs = <String>[];

      for (final digit in '9931571989'.split('')) {
        final nextText = '${value.text}$digit';
        value = formatter.formatEditUpdate(
          value,
          TextEditingValue(
            text: nextText,
            selection: TextSelection.collapsed(offset: nextText.length),
          ),
        );
        insertionOutputs.add(value.text);
      }

      expect(insertionOutputs, [
        '9',
        '99',
        '993',
        '9931',
        '99315',
        '99315 7',
        '99315 71',
        '99315 719',
        '99315 7198',
        '99315 71989',
      ]);

      final deletionOutputs = <String>[];
      for (var i = 0; i < 9; i++) {
        final nextText = value.text.substring(0, value.text.length - 1);
        value = formatter.formatEditUpdate(
          value,
          TextEditingValue(
            text: nextText,
            selection: TextSelection.collapsed(offset: nextText.length),
          ),
        );
        deletionOutputs.add(value.text);
      }

      expect(deletionOutputs, [
        '99315 7198',
        '99315 719',
        '99315 71',
        '99315 7',
        '99315',
        '9931',
        '993',
        '99',
        '9',
      ]);
    });
  });

  group('MaterialInternationalPhoneNumber', () {
    final countries = <Country>[
      Country(
        name: 'United States',
        alpha2Code: 'US',
        alpha3Code: 'USA',
        dialCode: '+1',
      ),
    ];
    final defaultCountry = countries.first;

    List<Country> filterCountries(String value) {
      return countries.where((country) => country.matches(value)).toList();
    }

    testWidgets('does not dispose an externally owned controller', (
      tester,
    ) async {
      final externalController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialInternationalPhoneNumber(
              countries: countries,
              defaultCountry: defaultCountry,
              filterFunction: filterCountries,
              textFieldController: externalController,
              formatInput: false,
            ),
          ),
        ),
      );

      await tester.pumpWidget(const SizedBox.shrink());

      expect(() => externalController.text = '12345', returnsNormally);

      externalController.dispose();
    });

    testWidgets('uses the selected country example as the default hint', (
      tester,
    ) async {
      final india = Country(
        name: 'India',
        alpha2Code: 'IN',
        alpha3Code: 'IND',
        dialCode: '+91',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialInternationalPhoneNumber(
              countries: [india],
              defaultCountry: india,
              filterFunction: (value) => [india],
              label: const Text('Mobile number'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile number'), findsOneWidget);
      expect(find.text('81234 56789'), findsOneWidget);
    });

    testWidgets('updates the field when initialValue changes', (tester) async {
      final firstNumber = const PhoneNumber(isoCode: 'US', nsn: '4155552671');
      final secondNumber = const PhoneNumber(isoCode: 'US', nsn: '6505551234');

      await tester.pumpWidget(
        MaterialApp(
          home: _Harness(
            countries: countries,
            defaultCountry: defaultCountry,
            filterFunction: filterCountries,
            initialValue: firstNumber,
            formatInput: false,
          ),
        ),
      );

      final state = tester.state<_HarnessState>(find.byType(_Harness));
      final textField = find.byType(TextFormField);
      final initialText = tester
          .widget<TextFormField>(textField)
          .controller!
          .text;

      state.updatePhoneNumber(secondNumber);
      await tester.pump();

      final updatedText = tester
          .widget<TextFormField>(textField)
          .controller!
          .text;

      expect(updatedText, isNot(initialText));
      expect(updatedText, secondNumber.nsn);
    });

    testWidgets('saves using the selected country as parse context', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      PhoneNumber? savedNumber;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: MaterialInternationalPhoneNumber(
                countries: countries,
                defaultCountry: defaultCountry,
                filterFunction: filterCountries,
                formatInput: false,
                onSaved: (number) {
                  savedNumber = number;
                },
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '6505551234');
      await tester.pump();

      formKey.currentState!.save();

      expect(savedNumber, isNotNull);
      expect(savedNumber!.isoCode, 'US');
      expect(savedNumber!.nsn, '6505551234');
    });

    testWidgets('reports empty input as invalid when blanks are not ignored', (
      tester,
    ) async {
      final validatedValues = <bool>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialInternationalPhoneNumber(
              countries: countries,
              defaultCountry: defaultCountry,
              filterFunction: filterCountries,
              ignoreBlank: false,
              onInputValidated: validatedValues.add,
              formatInput: false,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      expect(validatedValues, isNotEmpty);
      expect(validatedValues.last, isFalse);
    });

    testWidgets('reports an empty phone number when the field is cleared', (
      tester,
    ) async {
      final changedValues = <PhoneNumber>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialInternationalPhoneNumber(
              countries: countries,
              defaultCountry: defaultCountry,
              filterFunction: filterCountries,
              onInputChanged: changedValues.add,
              formatInput: false,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      expect(changedValues, isNotEmpty);
      expect(changedValues.last.isoCode, defaultCountry.alpha2Code);
      expect(changedValues.last.nsn, isEmpty);
    });

    testWidgets('reports invalid unparseable input changes to listeners', (
      tester,
    ) async {
      final changedValues = <PhoneNumber>[];
      final validatedValues = <bool>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialInternationalPhoneNumber(
              countries: countries,
              defaultCountry: defaultCountry,
              filterFunction: filterCountries,
              onInputChanged: changedValues.add,
              onInputValidated: validatedValues.add,
              formatInput: true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '6505551234');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), '(');
      await tester.pump();

      expect(changedValues, isNotEmpty);
      expect(changedValues.last.isoCode, defaultCountry.alpha2Code);
      expect(changedValues.last.nsn, isEmpty);
      expect(validatedValues, isNotEmpty);
      expect(validatedValues.last, isFalse);
    });

    testWidgets('shows a custom warning when country code input is attempted', (
      tester,
    ) async {
      const warningMessage = 'Use local number only';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialInternationalPhoneNumber(
              countries: countries,
              defaultCountry: defaultCountry,
              filterFunction: filterCountries,
              countryCodeWarningMessage: warningMessage,
              autoValidateMode: AutovalidateMode.always,
              formatInput: false,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '+1');
      await tester.pump();

      final textField = tester.widget<TextFormField>(
        find.byType(TextFormField),
      );
      expect(textField.controller!.text, isEmpty);
      expect(find.text(warningMessage), findsOneWidget);
    });

    testWidgets('clears the country code warning after valid input', (
      tester,
    ) async {
      const warningMessage = 'Use local number only';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialInternationalPhoneNumber(
              countries: countries,
              defaultCountry: defaultCountry,
              filterFunction: filterCountries,
              countryCodeWarningMessage: warningMessage,
              autoValidateMode: AutovalidateMode.always,
              formatInput: false,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '+1');
      await tester.pump();
      expect(find.text(warningMessage), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '6505551234');
      await tester.pump();

      expect(find.text(warningMessage), findsNothing);
    });

    testWidgets(
      'keeps the cursor at the end when formatting reaches a valid number',
      (tester) async {
        final controller = TextEditingController();
        final validatedValues = <bool>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MaterialInternationalPhoneNumber(
                countries: countries,
                defaultCountry: defaultCountry,
                filterFunction: filterCountries,
                textFieldController: controller,
                formatInput: true,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                onInputValidated: validatedValues.add,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TextFormField));
        await tester.pump();

        const digits = '6505551234';
        for (var i = 0; i < digits.length; i++) {
          final nextText = '${controller.text}${digits[i]}';
          tester.testTextInput.updateEditingValue(
            TextEditingValue(
              text: nextText,
              selection: TextSelection.collapsed(offset: nextText.length),
            ),
          );
          await tester.pump();
        }

        expect(controller.selection.isCollapsed, isTrue);
        expect(controller.selection.baseOffset, controller.text.length);
      },
    );

    testWidgets('uses the built-in country filter when none is provided', (
      tester,
    ) async {
      final multiCountries = <Country>[
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialInternationalPhoneNumber(
              countries: multiCountries,
              defaultCountry: multiCountries.first,
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
              ),
              formatInput: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MaterialButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).last, 'United');
      await tester.pumpAndSettle();

      expect(find.text('United States'), findsOneWidget);
      expect(find.text('India'), findsNothing);
    });

    testWidgets('hides flags in the selector button when showFlags is false', (
      tester,
    ) async {
      final multiCountries = <Country>[
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

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialInternationalPhoneNumber(
              countries: multiCountries,
              defaultCountry: multiCountries.first,
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
                showFlags: false,
              ),
              formatInput: false,
            ),
          ),
        ),
      );

      expect(find.byType(FlagWidget), findsNothing);
      expect(find.byType(MaterialButton), findsOneWidget);
    });

    testWidgets('can auto-detect and prioritize the detected country', (
      tester,
    ) async {
      final multiCountries = <Country>[
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
        Country(
          name: 'Canada',
          alpha2Code: 'CA',
          alpha3Code: 'CAN',
          dialCode: '+1',
        ),
        Country(
          name: 'Mexico',
          alpha2Code: 'MX',
          alpha3Code: 'MEX',
          dialCode: '+52',
        ),
        Country(
          name: 'India',
          alpha2Code: 'IN',
          alpha3Code: 'IND',
          dialCode: '+91',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialInternationalPhoneNumber(
              countries: multiCountries,
              defaultCountry: multiCountries.first,
              autoDetectCountry: true,
              detectedCountryOrderStrategy:
                  DetectedCountryOrderStrategy.signalVotesThenDistance,
              countryDetector: () async => const CountryResult(
                countryCode: 'US',
                confidence: 80,
                allVotes: {'US': 80, 'CA': 35, 'MX': 20},
              ),
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
              ),
              formatInput: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(MaterialButton));
      await tester.pumpAndSettle();

      final countryTiles = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .toList();
      final countryNames = countryTiles.map((tile) {
        final title = tile.title! as Align;
        final text = title.child! as Text;
        return text.data;
      }).toList();

      expect(countryNames.take(4), [
        'United States',
        'Canada',
        'Mexico',
        'India',
      ]);
    });

    testWidgets(
      'detectedCountryFirst keeps only the detected country pinned and leaves the rest alphabetical',
      (tester) async {
        final multiCountries = <Country>[
          Country(
            name: 'Canada',
            alpha2Code: 'CA',
            alpha3Code: 'CAN',
            dialCode: '+1',
          ),
          Country(
            name: 'India',
            alpha2Code: 'IN',
            alpha3Code: 'IND',
            dialCode: '+91',
          ),
          Country(
            name: 'Mexico',
            alpha2Code: 'MX',
            alpha3Code: 'MEX',
            dialCode: '+52',
          ),
          Country(
            name: 'United States',
            alpha2Code: 'US',
            alpha3Code: 'USA',
            dialCode: '+1',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MaterialInternationalPhoneNumber(
                countries: multiCountries,
                defaultCountry: multiCountries.first,
                autoDetectCountry: true,
                detectedCountryOrderStrategy:
                    DetectedCountryOrderStrategy.detectedCountryFirst,
                countryDetector: () async => const CountryResult(
                  countryCode: 'US',
                  confidence: 80,
                  allVotes: {'US': 80, 'MX': 30, 'IN': 20},
                ),
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                formatInput: false,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final dynamic state = tester.state(
          find.byType(MaterialInternationalPhoneNumber),
        );
        final countryNames = (state.countries as List<Country>)
            .map((country) => country.name)
            .toList();

        expect(countryNames, ['United States', 'Canada', 'India', 'Mexico']);
      },
    );

    testWidgets(
      'detectedCountryFirst uses default country first before detection and keeps the rest alphabetical',
      (tester) async {
        final multiCountries = <Country>[
          Country(
            name: 'Canada',
            alpha2Code: 'CA',
            alpha3Code: 'CAN',
            dialCode: '+1',
          ),
          Country(
            name: 'India',
            alpha2Code: 'IN',
            alpha3Code: 'IND',
            dialCode: '+91',
          ),
          Country(
            name: 'Mexico',
            alpha2Code: 'MX',
            alpha3Code: 'MEX',
            dialCode: '+52',
          ),
          Country(
            name: 'United States',
            alpha2Code: 'US',
            alpha3Code: 'USA',
            dialCode: '+1',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MaterialInternationalPhoneNumber(
                countries: multiCountries,
                defaultCountry: multiCountries.last,
                detectedCountryOrderStrategy:
                    DetectedCountryOrderStrategy.detectedCountryFirst,
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                formatInput: false,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final dynamic state = tester.state(
          find.byType(MaterialInternationalPhoneNumber),
        );
        final countryNames = (state.countries as List<Country>)
            .map((country) => country.name)
            .toList();

        expect(countryNames, ['United States', 'Canada', 'India', 'Mexico']);
      },
    );

    testWidgets(
      'keeps detected ordering in the chooser when a custom filterFunction is used',
      (tester) async {
        final multiCountries = <Country>[
          Country(
            name: 'Australia',
            alpha2Code: 'AU',
            alpha3Code: 'AUS',
            dialCode: '+61',
          ),
          Country(
            name: 'Bangladesh',
            alpha2Code: 'BD',
            alpha3Code: 'BGD',
            dialCode: '+880',
          ),
          Country(
            name: 'Bhutan',
            alpha2Code: 'BT',
            alpha3Code: 'BTN',
            dialCode: '+975',
          ),
          Country(
            name: 'India',
            alpha2Code: 'IN',
            alpha3Code: 'IND',
            dialCode: '+91',
          ),
          Country(
            name: 'Sri Lanka',
            alpha2Code: 'LK',
            alpha3Code: 'LKA',
            dialCode: '+94',
          ),
        ];

        List<Country> filterCountries(String value) {
          return multiCountries
              .where((country) => country.matches(value))
              .toList();
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MaterialInternationalPhoneNumber(
                countries: multiCountries,
                defaultCountry: multiCountries.first,
                filterFunction: filterCountries,
                autoDetectCountry: true,
                detectedCountryOrderStrategy: DetectedCountryOrderStrategy
                    .signalVotesThenNeighborsThenDistance,
                countryDetector: () async => const CountryResult(
                  countryCode: 'IN',
                  confidence: 92,
                  allVotes: {'IN': 92, 'LK': 60},
                ),
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                formatInput: false,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.byType(MaterialButton));
        await tester.pumpAndSettle();

        final countryTiles = tester
            .widgetList<ListTile>(find.byType(ListTile))
            .toList();
        final countryNames = countryTiles.map((tile) {
          final title = tile.title! as Align;
          final text = title.child! as Text;
          return text.data;
        }).toList();

        expect(countryNames.take(5), [
          'India',
          'Bangladesh',
          'Bhutan',
          'Sri Lanka',
          'Australia',
        ]);
      },
    );

    testWidgets(
      'orders India, Sri Lanka, neighbor buckets, then alphabetical remainder',
      (tester) async {
        final multiCountries = <Country>[
          Country(
            name: 'Australia',
            alpha2Code: 'AU',
            alpha3Code: 'AUS',
            dialCode: '+61',
          ),
          Country(
            name: 'Bangladesh',
            alpha2Code: 'BD',
            alpha3Code: 'BGD',
            dialCode: '+880',
          ),
          Country(
            name: 'Bhutan',
            alpha2Code: 'BT',
            alpha3Code: 'BTN',
            dialCode: '+975',
          ),
          Country(
            name: 'China',
            alpha2Code: 'CN',
            alpha3Code: 'CHN',
            dialCode: '+86',
          ),
          Country(
            name: 'India',
            alpha2Code: 'IN',
            alpha3Code: 'IND',
            dialCode: '+91',
          ),
          Country(
            name: 'Japan',
            alpha2Code: 'JP',
            alpha3Code: 'JPN',
            dialCode: '+81',
          ),
          Country(
            name: 'Myanmar',
            alpha2Code: 'MM',
            alpha3Code: 'MMR',
            dialCode: '+95',
          ),
          Country(
            name: 'Nepal',
            alpha2Code: 'NP',
            alpha3Code: 'NPL',
            dialCode: '+977',
          ),
          Country(
            name: 'Pakistan',
            alpha2Code: 'PK',
            alpha3Code: 'PAK',
            dialCode: '+92',
          ),
          Country(
            name: 'Sri Lanka',
            alpha2Code: 'LK',
            alpha3Code: 'LKA',
            dialCode: '+94',
          ),
          Country(
            name: 'United States',
            alpha2Code: 'US',
            alpha3Code: 'USA',
            dialCode: '+1',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MaterialInternationalPhoneNumber(
                countries: multiCountries,
                defaultCountry: multiCountries.last,
                autoDetectCountry: true,
                detectedCountryOrderStrategy: DetectedCountryOrderStrategy
                    .signalVotesThenNeighborsThenDistance,
                countryDetector: () async => const CountryResult(
                  countryCode: 'IN',
                  confidence: 92,
                  allVotes: {'IN': 92, 'LK': 60},
                ),
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                formatInput: false,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final dynamic state = tester.state(
          find.byType(MaterialInternationalPhoneNumber),
        );
        final countryNames = (state.countries as List<Country>)
            .map((country) => country.name)
            .toList();

        expect(countryNames.take(10), [
          'India',
          'Nepal',
          'Pakistan',
          'Bangladesh',
          'Bhutan',
          'Myanmar',
          'China',
          'Sri Lanka',
          'Australia',
          'Japan',
        ]);
      },
    );

    testWidgets(
      'interleaves each signal-backed country with its own neighbors before the alphabetical remainder',
      (tester) async {
        final multiCountries = <Country>[
          Country(
            name: 'Australia',
            alpha2Code: 'AU',
            alpha3Code: 'AUS',
            dialCode: '+61',
          ),
          Country(
            name: 'Bangladesh',
            alpha2Code: 'BD',
            alpha3Code: 'BGD',
            dialCode: '+880',
          ),
          Country(
            name: 'Bhutan',
            alpha2Code: 'BT',
            alpha3Code: 'BTN',
            dialCode: '+975',
          ),
          Country(
            name: 'China',
            alpha2Code: 'CN',
            alpha3Code: 'CHN',
            dialCode: '+86',
          ),
          Country(
            name: 'India',
            alpha2Code: 'IN',
            alpha3Code: 'IND',
            dialCode: '+91',
          ),
          Country(
            name: 'Maldives',
            alpha2Code: 'MV',
            alpha3Code: 'MDV',
            dialCode: '+960',
          ),
          Country(
            name: 'Myanmar',
            alpha2Code: 'MM',
            alpha3Code: 'MMR',
            dialCode: '+95',
          ),
          Country(
            name: 'Nepal',
            alpha2Code: 'NP',
            alpha3Code: 'NPL',
            dialCode: '+977',
          ),
          Country(
            name: 'Pakistan',
            alpha2Code: 'PK',
            alpha3Code: 'PAK',
            dialCode: '+92',
          ),
          Country(
            name: 'Sri Lanka',
            alpha2Code: 'LK',
            alpha3Code: 'LKA',
            dialCode: '+94',
          ),
          Country(
            name: 'United States',
            alpha2Code: 'US',
            alpha3Code: 'USA',
            dialCode: '+1',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MaterialInternationalPhoneNumber(
                countries: multiCountries,
                defaultCountry: multiCountries.last,
                autoDetectCountry: true,
                detectedCountryOrderStrategy: DetectedCountryOrderStrategy
                    .signalVotesThenNeighborsThenDistance,
                countryDetector: () async => const CountryResult(
                  countryCode: 'IN',
                  confidence: 92,
                  allVotes: {'IN': 92, 'LK': 60, 'MV': 45},
                ),
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                formatInput: false,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final dynamic state = tester.state(
          find.byType(MaterialInternationalPhoneNumber),
        );
        final countryNames = (state.countries as List<Country>)
            .map((country) => country.name)
            .toList();

        expect(countryNames.take(11), [
          'India',
          'Nepal',
          'Pakistan',
          'Bangladesh',
          'Bhutan',
          'Myanmar',
          'China',
          'Sri Lanka',
          'Maldives',
          'Australia',
          'United States',
        ]);
      },
    );

    testWidgets(
      'does not promote unofficial disputed neighbors for other countries',
      (tester) async {
        final countries = <Country>[
          Country(
            name: 'Albania',
            alpha2Code: 'AL',
            alpha3Code: 'ALB',
            dialCode: '+355',
          ),
          Country(
            name: 'Greece',
            alpha2Code: 'GR',
            alpha3Code: 'GRC',
            dialCode: '+30',
          ),
          Country(
            name: 'Kosovo',
            alpha2Code: 'XK',
            alpha3Code: 'XKX',
            dialCode: '+383',
          ),
          Country(
            name: 'Montenegro',
            alpha2Code: 'ME',
            alpha3Code: 'MNE',
            dialCode: '+382',
          ),
          Country(
            name: 'North Macedonia',
            alpha2Code: 'MK',
            alpha3Code: 'MKD',
            dialCode: '+389',
          ),
          Country(
            name: 'Serbia',
            alpha2Code: 'RS',
            alpha3Code: 'SRB',
            dialCode: '+381',
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MaterialInternationalPhoneNumber(
                countries: countries,
                defaultCountry: countries.first,
                autoDetectCountry: true,
                detectedCountryOrderStrategy: DetectedCountryOrderStrategy
                    .signalVotesThenNeighborsThenDistance,
                countryDetector: () async => const CountryResult(
                  countryCode: 'AL',
                  confidence: 90,
                  allVotes: {'AL': 90},
                ),
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                formatInput: false,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final dynamic state = tester.state(
          find.byType(MaterialInternationalPhoneNumber),
        );
        final countryNames = (state.countries as List<Country>)
            .map((country) => country.name)
            .toList();

        expect(countryNames.take(4), [
          'Albania',
          'North Macedonia',
          'Montenegro',
          'Greece',
        ]);
        expect(countryNames.indexOf('Kosovo'), greaterThan(3));
      },
    );
  });
}

class _Harness extends StatefulWidget {
  const _Harness({
    required this.countries,
    required this.defaultCountry,
    required this.initialValue,
    required this.formatInput,
    this.filterFunction,
  });

  final List<Country> countries;
  final Country defaultCountry;
  final List<Country> Function(String value)? filterFunction;
  final PhoneNumber initialValue;
  final bool formatInput;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late PhoneNumber currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }

  void updatePhoneNumber(PhoneNumber value) {
    setState(() {
      currentValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MaterialInternationalPhoneNumber(
        countries: widget.countries,
        defaultCountry: widget.defaultCountry,
        filterFunction: widget.filterFunction,
        initialValue: currentValue,
        formatInput: widget.formatInput,
      ),
    );
  }
}
