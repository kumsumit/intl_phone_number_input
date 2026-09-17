import 'package:phone_parser/phone_parser.dart';

/// Applies a product's accepted phone-number types to phone-parser metadata.
///
/// The default policy intentionally remains mobile-only for backwards
/// compatibility. Pass a different set to an input widget when collecting
/// business, landline, or VoIP numbers.
class PhoneNumberMetadataPolicy {
  const PhoneNumberMetadataPolicy._();

  static const Set<PhoneNumberType> defaultAcceptedTypes = {
    PhoneNumberType.mobile,
  };

  static bool accepts(PhoneNumber number, Set<PhoneNumberType> acceptedTypes) {
    if (number.nsn.isEmpty) return false;

    return acceptedTypes.any((type) {
      if (type == PhoneNumberType.fixedLineOrMobile) {
        return number.isValid(type: PhoneNumberType.fixedLine) ||
            number.isValid(type: PhoneNumberType.mobile);
      }
      return type != PhoneNumberType.unknown && number.isValid(type: type);
    });
  }

  static List<int> acceptedLengths(
    String isoCode,
    Set<PhoneNumberType> acceptedTypes,
  ) {
    final metadata = MetadataFinder.findMetadataLengthForIsoCode(isoCode);
    final lengths = <int>{};
    for (final type in acceptedTypes) {
      if (type == PhoneNumberType.fixedLineOrMobile) {
        lengths.addAll(metadata['fixedLine'] ?? const <int>[]);
        lengths.addAll(metadata['mobile'] ?? const <int>[]);
      } else {
        lengths.addAll(metadata[_metadataKey(type)] ?? const <int>[]);
      }
    }
    return lengths.toList()..sort();
  }

  static String _metadataKey(PhoneNumberType type) {
    switch (type) {
      case PhoneNumberType.fixedLine:
        return 'fixedLine';
      case PhoneNumberType.mobile:
        return 'mobile';
      case PhoneNumberType.voip:
        return 'voip';
      case PhoneNumberType.tollFree:
        return 'tollFree';
      case PhoneNumberType.premiumRate:
        return 'premiumRate';
      case PhoneNumberType.sharedCost:
        return 'sharedCost';
      case PhoneNumberType.personalNumber:
        return 'personalNumber';
      case PhoneNumberType.uan:
        return 'uan';
      case PhoneNumberType.pager:
        return 'pager';
      case PhoneNumberType.voiceMail:
        return 'voiceMail';
      case PhoneNumberType.fixedLineOrMobile:
      case PhoneNumberType.unknown:
        return '';
    }
  }
}
