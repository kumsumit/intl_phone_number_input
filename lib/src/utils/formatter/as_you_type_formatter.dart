import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:phone_parser/phone_parser.dart';

typedef OnInputFormatted<T> = void Function(T value);
typedef OnRejectedInput = void Function();
typedef OnAcceptedInput = void Function();

class CountryCodeBlockerFormatter extends TextInputFormatter {
  final OnRejectedInput onRejected;
  final OnAcceptedInput onAccepted;

  CountryCodeBlockerFormatter({
    required this.onRejected,
    required this.onAccepted,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.contains('+')) {
      onRejected();
      return oldValue;
    }

    onAccepted();
    return newValue;
  }
}

/// Flutter adapter around `phone_parser`'s pure Dart formatter.
class AsYouTypeFormatter extends TextInputFormatter {
  /// Contains characters allowed as separators.
  final RegExp separatorChars = RegExp('[^${Patterns.digits}]+');

  /// The [allowedChars] contains [RegExp] for allowable phone number characters.
  final RegExp allowedChars = RegExp('[${Patterns.plus}${Patterns.digits}]');

  /// The [isoCode] of the [Country] formatting the phone number to.
  final String isoCode;

  /// The [dialCode] of the [Country] formatting the phone number to.
  ///
  /// Kept for API compatibility with existing widget call sites.
  final String dialCode;
  final List<int> acceptedLengths;

  /// [onInputFormatted] is a callback that passes the formatted phone number.
  final OnInputFormatted<TextEditingValue> onInputFormatted;

  AsYouTypeFormatter({
    required this.isoCode,
    required this.dialCode,
    required this.acceptedLengths,
    required this.onInputFormatted,
  });

  int get effectiveMaxLength {
    final acceptedMaxLength = acceptedLengths.isEmpty
        ? PhoneParserTextInputFormatter.maxDigits
        : acceptedLengths.reduce((a, b) => a > b ? a : b);

    return acceptedMaxLength > PhoneParserTextInputFormatter.maxDigits
        ? PhoneParserTextInputFormatter.maxDigits
        : acceptedMaxLength;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatter = PhoneParserTextInputFormatter(
      isoCode: isoCode,
      digitLimit: newValue.text.runes.length,
    );

    late final String formattedText;
    try {
      formattedText = formatter.replace(newValue.text);
    } catch (_) {
      return oldValue;
    }

    if (formatter.normalizedDigits.isEmpty) {
      if (newValue.text.isEmpty) return newValue;
      return TextEditingValue.empty;
    }

    final enteredDigits = formatter.normalizedDigits;
    final nsnDigits = formatter.nationalSignificantDigits;
    final dialCodeDigits = dialCode.replaceAll(RegExp(r'\D'), '');
    final hasDialCodePrefix =
        dialCodeDigits.isNotEmpty &&
        enteredDigits.length > effectiveMaxLength &&
        enteredDigits.startsWith(dialCodeDigits);

    if (nsnDigits.length > effectiveMaxLength || hasDialCodePrefix) {
      return oldValue;
    }

    final offset = _selectionOffsetForFormattedText(
      formattedText: formattedText,
      newValue: newValue,
    );

    final textEditingValue = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: offset),
    );

    onInputFormatted(textEditingValue);
    return textEditingValue;
  }

  int _selectionOffsetForFormattedText({
    required String formattedText,
    required TextEditingValue newValue,
  }) {
    final requestedOffset = newValue.selection.end.clamp(
      0,
      newValue.text.length,
    );
    if (requestedOffset == 0) return 0;

    // Count significant (digit / '+') chars that sit before the cursor in the
    // raw new value.
    final significantCharsBeforeCursor = newValue.text
        .substring(0, requestedOffset)
        .split('')
        .where((char) => allowedChars.hasMatch(char))
        .length;

    if (significantCharsBeforeCursor == 0) return 0;

    final totalSignificantChars = newValue.text
        .split('')
        .where((char) => allowedChars.hasMatch(char))
        .length;

    if (significantCharsBeforeCursor >= totalSignificantChars) {
      return formattedText.length;
    }

    var seenSignificantChars = 0;
    for (var i = 0; i < formattedText.length; i++) {
      if (allowedChars.hasMatch(formattedText[i])) {
        seenSignificantChars++;
      }
      if (seenSignificantChars == significantCharsBeforeCursor) {
        return i + 1;
      }
    }

    return formattedText.length;
  }
}
