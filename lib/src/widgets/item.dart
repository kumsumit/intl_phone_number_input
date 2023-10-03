import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';

import 'countries_search_list_widget.dart';

/// [Item]
class Item extends StatelessWidget {
  final Country? country;
  final bool? showFlag;
  final double flagSize;
  final bool isFlagEmoji;
  final TextStyle? textStyle;
  final bool withCountryNames;
  final double? leadingPadding;
  final double? trailingPadding;
  final bool trailingSpace;

  const Item({
    Key? key,
    this.country,
    this.showFlag,
    required this.flagSize,
  required  this.isFlagEmoji,
    this.textStyle,
    this.withCountryNames = false,
    this.leadingPadding = 3,
    this.trailingPadding = 3,
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
        if(country != null)
        Flag(
          country: country!,
          isFlagEmoji: isFlagEmoji,
          flagSize: flagSize,
        ),
        SizedBox(width: 3.0),
        Text(
          '$dialCode',
          textDirection: TextDirection.ltr,
          style: textStyle,
        ),
        SizedBox(width: trailingPadding),
      ],
    );
  }
}