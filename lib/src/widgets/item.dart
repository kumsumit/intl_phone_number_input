import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';

/// [Item]
class Item extends StatelessWidget {
  final Country? country;
  final bool? showFlag;
  final TextStyle? flagStyle;
  final TextStyle? textStyle;
  final bool withCountryNames;
  final double? leadingPadding;
  final bool trailingSpace;

  const Item({
    Key? key,
    this.country,
    this.showFlag,
    this.flagStyle,
    this.textStyle,
    this.withCountryNames = false,
    this.leadingPadding = 3,
    this.trailingSpace = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dialCode = (country?.dialCode ?? '');
    if (trailingSpace) {
      dialCode = dialCode.padRight(5, " ");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(width: leadingPadding),
        _Flag(
          country: country,
          showFlag: showFlag,
          flagStyle: flagStyle,
        ),
        SizedBox(width: 3.0),
        Text(
          '$dialCode',
          textDirection: TextDirection.ltr,
          style: textStyle,
        ),
      ],
    );
  }
}

class _Flag extends StatelessWidget {
  final Country? country;
  final bool? showFlag;
  final TextStyle? flagStyle;

  const _Flag({Key? key, this.country, this.showFlag, this.flagStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return country != null && showFlag!
        ? Text(
            Utils.generateFlagEmojiUnicode(country?.alpha2Code ?? ''),
            style: flagStyle ?? Theme.of(context).textTheme.labelMedium,
          )
        : SizedBox.shrink();
  }
}
