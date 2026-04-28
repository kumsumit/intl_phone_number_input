import 'package:flutter/widgets.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';

class FlagWidget extends StatelessWidget {
  final Country country;
  final TextStyle? style;

  const FlagWidget({super.key, required this.country, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      Utils.generateFlagEmojiUnicode(country.alpha2Code),
      style: style,
    );
  }
}
