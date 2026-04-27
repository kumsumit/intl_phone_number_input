import 'package:flutter/services.dart';
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

/// [AsYouTypeFormatter] is a custom formatter that extends [TextInputFormatter]
/// which provides as you type validation and formatting for phone number inputted.
class AsYouTypeFormatter extends TextInputFormatter {
  static const int maxDigits = 15;

  /// Contains characters allowed as seperators.
  final RegExp separatorChars = RegExp(r'[^\d]+');

  /// The [allowedChars] contains [RegExp] for allowable phone number characters.
  final RegExp allowedChars = RegExp(r'[\d+]');

  final RegExp bracketsBetweenDigitsOrSpace = RegExp(
    r'(?![\s\d])([()])(?=[\d\s])',
  );

  /// The [isoCode] of the [Country] formatting the phone number to
  final String isoCode;

  /// The [dialCode] of the [Country] formatting the phone number to
  final String dialCode;
  final List<int> acceptedLengths;

  /// [onInputFormatted] is a callback that passes the formatted phone number
  final OnInputFormatted<TextEditingValue> onInputFormatted;

  AsYouTypeFormatter({
    required this.isoCode,
    required this.dialCode,
    required this.acceptedLengths,
    required this.onInputFormatted,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newValueText = newValue.text;
    final rawText = newValueText.replaceAll(separatorChars, '');

    // ✅ Always allow empty text
    if (rawText.isEmpty) {
      return newValue;
    }

    // ✅ Allow input to continue even if not yet in acceptedLengths
    // Only enforce max length, not exact match
    final acceptedMaxLength = acceptedLengths.isEmpty
        ? maxDigits
        : acceptedLengths.reduce((a, b) => a > b ? a : b);
    final effectiveMaxLength = acceptedMaxLength > maxDigits
        ? maxDigits
        : acceptedMaxLength;

    if (rawText.length > effectiveMaxLength) {
      return oldValue;
    }

    // Build full text with dial code
    final textToParse = dialCode + rawText;

    // Format the text
    late final String parsedText;
    try {
      parsedText = parsePhoneNumber(
        formatAsYouType(phoneNumber: textToParse),
      );
    } catch (_) {
      return newValue;
    }

    final offset = _selectionOffsetForFormattedText(
      formattedText: parsedText,
      newValue: newValue,
    );

    final textEditingValue = TextEditingValue(
      text: parsedText,
      selection: TextSelection.collapsed(offset: offset),
    );

    // Always call your callback
    onInputFormatted(textEditingValue);

    return textEditingValue;
  }

  int _selectionOffsetForFormattedText({
    required String formattedText,
    required TextEditingValue newValue,
  }) {
    final requestedOffset = newValue.selection.end.clamp(0, newValue.text.length);
    if (requestedOffset == 0) {
      return 0;
    }

    final significantCharsBeforeCursor = newValue.text
        .substring(0, requestedOffset)
        .split('')
        .where((char) => allowedChars.hasMatch(char))
        .length;

    if (significantCharsBeforeCursor == 0) {
      return 0;
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

  /// Accepts [input], unformatted phone number and
  /// returns a [Future<String>] of the formatted phone number.
  String formatAsYouType({required String phoneNumber}) {
    return PhoneNumber.parse(
      phoneNumber,
      destinationCountry: isoCode,
    ).formatNsn();
  }

  /// Accepts a formatted [phoneNumber]
  /// returns a [String] of `phoneNumber` with the dialCode replaced with an empty String
  String parsePhoneNumber(String? phoneNumber) {
    final filteredPhoneNumber = phoneNumber?.replaceAll(
      bracketsBetweenDigitsOrSpace,
      '',
    );

    if (dialCode.length > 4) {
      if (isPartOfNorthAmericanNumberingPlan(dialCode)) {
        String northAmericaDialCode = '+1';
        String countryDialCodeWithSpace =
            '$northAmericaDialCode ${dialCode.replaceFirst(northAmericaDialCode, '')}';

        return filteredPhoneNumber!
            .replaceFirst(countryDialCodeWithSpace, '')
            .replaceFirst(separatorChars, '')
            .trim();
      }
    }
    return filteredPhoneNumber!.replaceFirst(dialCode, '').trim();
  }

  /// Accepts a [dialCode]
  /// returns a [bool], true if the `dialCode` is part of North American Numbering Plan
  bool isPartOfNorthAmericanNumberingPlan(String dialCode) {
    return dialCode.contains('+1');
  }
}
