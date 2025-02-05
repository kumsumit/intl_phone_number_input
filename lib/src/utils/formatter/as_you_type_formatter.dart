import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

typedef OnInputFormatted<T> = void Function(T value);

/// [AsYouTypeFormatter] is a custom formatter that extends [TextInputFormatter]
/// which provides as you type validation and formatting for phone number inputted.
class AsYouTypeFormatter extends TextInputFormatter {
  /// Contains characters allowed as seperators.
  final RegExp separatorChars = RegExp(r'[^\d]+');

  /// The [allowedChars] contains [RegExp] for allowable phone number characters.
  final RegExp allowedChars = RegExp(r'[\d+]');

  final RegExp bracketsBetweenDigitsOrSpace =
      RegExp(r'(?![\s\d])([()])(?=[\d\s])');

  /// The [isoCode] of the [Country] formatting the phone number to
  final String isoCode;

  /// The [dialCode] of the [Country] formatting the phone number to
  final String dialCode;
  final int maxLength;

  /// [onInputFormatted] is a callback that passes the formatted phone number
  final OnInputFormatted<TextEditingValue> onInputFormatted;

  AsYouTypeFormatter(
      {required this.isoCode,
      required this.dialCode,
      required this.maxLength,
      required this.onInputFormatted});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    int oldValueLength = oldValue.text.length;
    int newValueLength = newValue.text.length;

    if (newValueLength > 0 && newValueLength > oldValueLength) {
      String newValueText = newValue.text;
      String rawText = newValueText.replaceAll(separatorChars, '');
      if (PhoneNumber(isoCode: isoCode.toEnum(IsoCode.values), nsn: rawText)
              .nsn
              .length >
          maxLength) {
        return oldValue;
      }
      String textToParse = dialCode + rawText;

      final _ = newValueText
          .substring(
              oldValue.selection.start == -1 ? 0 : oldValue.selection.start,
              newValue.selection.end == -1 ? 0 : newValue.selection.end)
          .replaceAll(separatorChars, '');

      String parsedText =
          parsePhoneNumber(formatAsYouType(phoneNumber: textToParse));

      int offset = newValue.selection.end == -1 ? 0 : newValue.selection.end;

      if (separatorChars.hasMatch(parsedText) &&
          offset - 2 <= parsedText.length) {
        String valueInInputIndex = parsedText[offset - 1];

        if (offset < parsedText.length) {
          int offsetDifference = parsedText.length - offset;

          if (offsetDifference < 2) {
            if (separatorChars.hasMatch(valueInInputIndex)) {
              offset += 1;
            } else {
              bool isLastChar;
              try {
                var _ = newValueText[newValue.selection.end];
                isLastChar = false;
              } on RangeError {
                isLastChar = true;
              }
              if (isLastChar) {
                offset += offsetDifference;
              }
            }
          } else {
            if (parsedText.length > offset - 1) {
              if (separatorChars.hasMatch(valueInInputIndex)) {
                offset += 1;
              }
            }
          }
        }
        final TextEditingValue textEditingValue = TextEditingValue(
          text: parsedText,
          selection: TextSelection.collapsed(offset: offset),
        );

        newValue = textEditingValue;
        this.onInputFormatted(textEditingValue);
      }
    }

    return newValue;
  }

  /// Accepts [input], unformatted phone number and
  /// returns a [Future<String>] of the formatted phone number.
  String formatAsYouType({required String phoneNumber}) {
    return PhoneNumber.parse(phoneNumber,
            destinationCountry: isoCode.toEnum(IsoCode.values))
        .getFormattedNsn();
  }

  /// Accepts a formatted [phoneNumber]
  /// returns a [String] of `phoneNumber` with the dialCode replaced with an empty String
  String parsePhoneNumber(String? phoneNumber) {
    final filteredPhoneNumber =
        phoneNumber?.replaceAll(bracketsBetweenDigitsOrSpace, '');

    if (dialCode.length > 4) {
      if (isPartOfNorthAmericanNumberingPlan(dialCode)) {
        String northAmericaDialCode = '+1';
        String countryDialCodeWithSpace = northAmericaDialCode +
            ' ' +
            dialCode.replaceFirst(northAmericaDialCode, '');

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
