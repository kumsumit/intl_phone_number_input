import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:intl_phone_number_input/src/utils/formatter/as_you_type_formatter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AsYouTypeFormatter', () {
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
  });

  group('InternationalPhoneNumberInput', () {
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
            body: InternationalPhoneNumberInput(
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
      final initialText = tester.widget<TextFormField>(textField).controller!.text;

      state.updatePhoneNumber(secondNumber);
      await tester.pump();

      final updatedText = tester.widget<TextFormField>(textField).controller!.text;

      expect(updatedText, isNot(initialText));
      expect(updatedText, secondNumber.nsn);
    });

    testWidgets('reports empty input as invalid when blanks are not ignored', (
      tester,
    ) async {
      final validatedValues = <bool>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InternationalPhoneNumberInput(
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
  });
}

class _Harness extends StatefulWidget {
  const _Harness({
    required this.countries,
    required this.defaultCountry,
    required this.filterFunction,
    required this.initialValue,
    required this.formatInput,
  });

  final List<Country> countries;
  final Country defaultCountry;
  final List<Country> Function(String value) filterFunction;
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
      body: InternationalPhoneNumberInput(
        countries: widget.countries,
        defaultCountry: widget.defaultCountry,
        filterFunction: widget.filterFunction,
        initialValue: currentValue,
        formatInput: widget.formatInput,
      ),
    );
  }
}
