// import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';

/// Creates a list of Countries with a search textfield.
class CountrySearchListWidget extends StatefulWidget {
  final List<Country> countries;
  final InputDecoration? searchBoxDecoration;
  final ScrollController? scrollController;
  final bool autoFocus;
  final bool? showFlags;
  final double flagSize;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final List<Country> Function(String value) filterFunction;

  CountrySearchListWidget(
    this.countries, {
    this.searchBoxDecoration,
    this.scrollController,
    this.showFlags,
    this.autoFocus = false,
    required this.flagSize,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.filterFunction,
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
    filteredCountries = widget.filterFunction(value);
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
            decoration: getSearchBoxDecoration(),
            controller: _searchController,
            autofocus: widget.autoFocus,
            onChanged: (value) {
              final String value = _searchController.text.trim();
              return setState(() {
                filteredCountries = widget.filterFunction(value);
              });
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
                showFlags: widget.showFlags!,
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
  final bool showFlags;
  final double flagSize;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  const DirectionalCountryListTile({
    super.key,
    required this.country,
    required this.showFlags,
    this.flagSize = 20,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: (showFlags ? Flag(country: country, flagSize: flagSize) : null),
      title: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(country.name,
          textDirection: Directionality.of(context),
          style: titleStyle,
          textAlign: TextAlign.start,
        ),
      ),
      subtitle: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          '${country.dialCode}',
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
  const Flag({required this.country, required this.flagSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      Utils.generateFlagEmojiUnicode(country.alpha2Code),
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontSize: flagSize),
    );
  }
}
