import 'package:flutter/widgets.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/widgets/common/flag_widget.dart';

/// [Item]
class Item extends StatelessWidget {
  final Country? country;
  final bool? showFlag;
  final double flagSize;
  final TextStyle? textStyle;
  final TextStyle? flagStyle;
  final double? leadingPadding;
  final double? trailingPadding;
  final bool trailingSpace;

  const Item({
    super.key,
    this.country,
    this.showFlag,
    required this.flagSize,
    this.textStyle,
    this.flagStyle,
    this.leadingPadding = 3,
    this.trailingPadding = 3,
    this.trailingSpace = true,
  });

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
        if (showFlag == true && country != null)
          FlagWidget(
            country: country!,
            style:
                flagStyle?.copyWith(fontSize: flagSize) ??
                TextStyle(fontSize: flagSize),
          ),
        SizedBox(width: 3.0),
        Text(dialCode, textDirection: TextDirection.ltr, style: textStyle),
        SizedBox(width: trailingPadding),
      ],
    );
  }
}
