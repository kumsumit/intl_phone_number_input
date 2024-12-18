import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/test/test_helper.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';

/// Creates a list of Countries with a search textfield.
class CountrySearchListWidget extends StatefulWidget {
  final List<Country> countries;
  final InputDecoration? searchBoxDecoration;
  final String? locale;
  final ScrollController? scrollController;
  final bool autoFocus;
  final bool? showFlags;
  final bool isFlagEmoji;
  final double flagSize;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  CountrySearchListWidget(
    this.countries,
    this.locale, {
    this.searchBoxDecoration,
    this.scrollController,
    this.showFlags,
    this.autoFocus = false,
    required this.flagSize,
    required this.isFlagEmoji,
    required this.titleStyle,
    required this.subtitleStyle,
  });

  @override
  _CountrySearchListWidgetState createState() =>
      _CountrySearchListWidgetState();
}

class _CountrySearchListWidgetState extends State<CountrySearchListWidget> {
  late TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;

  @override
  void initState() {
    final String value = _searchController.text.trim();
    filteredCountries = Utils.filterCountries(
      countries: widget.countries,
      locale: widget.locale,
      value: value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Returns [InputDecoration] of the search box
  InputDecoration getSearchBoxDecoration() {
    return widget.searchBoxDecoration ??
        InputDecoration(labelText: 'Search by country name or dial code');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            key: Key(TestHelper.CountrySearchInputKeyValue),
            decoration: getSearchBoxDecoration(),
            controller: _searchController,
            autofocus: widget.autoFocus,
            onChanged: (value) {
              final String value = _searchController.text.trim();
              return setState(
                () => filteredCountries = Utils.filterCountries(
                  countries: widget.countries,
                  locale: widget.locale,
                  value: value,
                ),
              );
            },
          ),
        ),
        Flexible(
          child: ListView.builder(
            controller: widget.scrollController,
            shrinkWrap: true,
            itemCount: filteredCountries.length,
            itemBuilder: (BuildContext context, int index) {
              Country country = filteredCountries[index];
              return DirectionalCountryListTile(
                country: country,
                locale: widget.locale,
                showFlags: widget.showFlags!,
                isFlagEmoji: widget.isFlagEmoji,
                flagSize: widget.flagSize,
                titleStyle: widget.titleStyle,
                subtitleStyle: widget.subtitleStyle,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class DirectionalCountryListTile extends StatelessWidget {
  final Country country;
  final String? locale;
  final bool showFlags;
  final double flagSize;
  final bool isFlagEmoji;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  const DirectionalCountryListTile(
      {super.key,
      required this.country,
      required this.locale,
      required this.showFlags,
      this.flagSize = 20,
      this.isFlagEmoji = true,
      this.titleStyle,
      this.subtitleStyle
      });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key(TestHelper.countryItemKeyValue(country.alpha2Code)),
      leading: (showFlags
          ? Flag(
              country: country,
              flagSize: flagSize,
              isFlagEmoji: isFlagEmoji,
            )
          : null),
      title: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${Utils.getCountryName(country, locale)}',
          textDirection: Directionality.of(context),
          style: titleStyle,
          textAlign: TextAlign.start,
        ),
      ),
      subtitle: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${country.dialCode ?? ''}',
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.start,
          style: subtitleStyle,
        ),
      ),
      onTap: () => Navigator.of(context).pop(country),
    );
  }
}

class Flag extends StatelessWidget {
  final Country country;
  final double flagSize;
  final bool isFlagEmoji;
  const Flag(
      {required this.country,
      required this.flagSize,
      required this.isFlagEmoji});

  @override
  Widget build(BuildContext context) {
    return isFlagEmoji
        ? Text(
            Utils.generateFlagEmojiUnicode(country.alpha2Code ?? 'IN'),
            style: Theme.of(context).textTheme.headlineSmall,
          )
        : CircleFlag(
            country.alpha2Code ?? "IN",
            size: flagSize,
          );
  }
}
