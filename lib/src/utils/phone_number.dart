// // import 'dart:async';
// import 'dart:math';

// import 'package:collection/collection.dart' show IterableExtension;
// import 'package:equatable/equatable.dart';
// import 'package:intl_phone_number_input/src/models/country_list.dart';
// import 'package:phone_numbers_parser/phone_numbers_parser.dart' as parser;
// // import 'package:intl_phone_number_input/src/utils/phone_number/phone_number_util.dart';

// import 'phone_number/util_new.dart';



// /// [PhoneNumber] contains detailed information about a phone number
// class PhoneNumber extends Equatable {
//   /// Either formatted or unformatted String of the phone number
//   final String? phoneNumber;
// // 
//   /// The Country [dialCode] of the phone number
//   final String? dialCode;

//   /// Country [isoCode] of the phone number
//   final String? isoCode;

//   /// [_hash] is used to compare instances of [PhoneNumber] object.
//   final int _hash;

//   /// Returns an integer generated after the object was initialised.
//   /// Used to compare different instances of [PhoneNumber]
//   int get hash => _hash;

//   @override
//   List<Object?> get props => [phoneNumber, isoCode, dialCode];

//   PhoneNumber({
//     this.phoneNumber,
//     this.dialCode,
//     this.isoCode,
//   }) : _hash = 1000 + Random().nextInt(99999 - 1000);

//   @override
//   String toString() {
//     return 'PhoneNumber(phoneNumber: $phoneNumber, dialCode: $dialCode, isoCode: $isoCode)';
//   }

//   /// Returns [PhoneNumber] which contains region information about
//   /// the [phoneNumber] and [isoCode] passed.
//   static PhoneNumber getRegionInfoFromPhoneNumber(
//     String phoneNumber, [
//     String isoCode = '',
//   ]) {
//     final parsedPhoneNumber = parser.PhoneNumber.parse(phoneNumber,
//             destinationCountry: isoCode.toEnum(parser.IsoCode.values));
//     String? internationalPhoneNumber = parsedPhoneNumber.international;
//     //     await PhoneNumberUtil.normalizePhoneNumber(
//     //   phoneNumber: phoneNumber,
//     //   isoCode: regionInfo.isoCode ?? isoCode,
//     // );

//     return PhoneNumber(
//       phoneNumber: internationalPhoneNumber,
//       dialCode: parsedPhoneNumber.countryCode,
//       isoCode: parsedPhoneNumber.isoCode.name,
//     );
//   }

//   /// Accepts a [PhoneNumber] object and returns a formatted phone number String
//   static String getParsableNumber(PhoneNumber phoneNumber) {
//     if (phoneNumber.isoCode != null) {
//       String? formattedNumber = PhoneNumberUtilNew.formatAsYouType(
//         phoneNumber: phoneNumber.phoneNumber!,
//         isoCode:  phoneNumber.isoCode!,
//       );
//       print("I m dial code");
//       print(phoneNumber.dialCode);
//       return formattedNumber!.replaceAll(
//         RegExp('^([\\+]?${phoneNumber.dialCode}[\\s]?)'),
//         '',
//       );
//     } else {
//       throw new Exception('ISO Code is "${phoneNumber.isoCode}"');
//     }
//   }

//   /// Returns a String of [phoneNumber] without [dialCode]
//   String parseNumber() {
//     return this.phoneNumber!.replaceAll("${this.dialCode}", '');
//   }

//   /// For predefined phone number returns Country's [isoCode] from the dial code,
//   /// Returns null if not found.
//   static String? getISO2CodeByPrefix(String prefix) {
//     if (prefix.isNotEmpty) {
//       prefix = prefix.startsWith('+') ? prefix : '+$prefix';
//       var country = Countries.countryList
//           .firstWhereOrNull((country) => country['dial_code'] == prefix);
//       if (country != null && country['alpha_2_code'] != null) {
//         return country['alpha_2_code'];
//       }
//     }
//     return null;
//   }
// }
