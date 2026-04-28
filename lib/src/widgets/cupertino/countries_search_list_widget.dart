import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/widgets/common/flag_widget.dart';

class CupertinoCountrySearchListWidget extends StatefulWidget {
  final List<Country> countries;
  final String? searchPlaceholder;
  final ScrollController? scrollController;
  final bool autoFocus;
  final bool showFlags;
  final double flagSize;
  final TextStyle? flagStyle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final String searchHintText;
  final String emptySearchMessage;
  final List<Country> Function(String value)? filterFunction;

  const CupertinoCountrySearchListWidget(
    this.countries, {
    super.key,
    this.searchPlaceholder,
    this.scrollController,
    this.showFlags = true,
    this.autoFocus = false,
    required this.flagSize,
    this.flagStyle,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.searchHintText,
    required this.emptySearchMessage,
    this.filterFunction,
  });

  @override
  State<CupertinoCountrySearchListWidget> createState() =>
      _CupertinoCountrySearchListWidgetState();
}

class _CupertinoCountrySearchListWidgetState
    extends State<CupertinoCountrySearchListWidget> {
  final TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;

  @override
  void initState() {
    super.initState();
    filteredCountries = _filterCountries(_searchController.text);
  }

  @override
  void didUpdateWidget(covariant CupertinoCountrySearchListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countries != widget.countries ||
        oldWidget.filterFunction != widget.filterFunction) {
      filteredCountries = _filterCountries(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Country> _filterCountries(String value) {
    final query = value.trim();
    final filterFunction = widget.filterFunction;
    return filterFunction != null
        ? _orderLikeWidgetCountries(filterFunction(query))
        : Utils.filterCountries(widget.countries, query);
  }

  List<Country> _orderLikeWidgetCountries(List<Country> result) {
    final codesInResult = result
        .map((country) => country.alpha2Code.toUpperCase())
        .toSet();
    final ordered = <Country>[];
    final seen = <String>{};

    for (final country in widget.countries) {
      final code = country.alpha2Code.toUpperCase();
      if (codesInResult.contains(code) && seen.add(code)) {
        ordered.add(country);
      }
    }

    for (final country in result) {
      final code = country.alpha2Code.toUpperCase();
      if (seen.add(code)) {
        ordered.add(country);
      }
    }

    return ordered;
  }

  String getSearchPlaceholder() {
    return widget.searchPlaceholder ?? widget.searchHintText;
  }

 @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: CupertinoSearchTextField(
            controller: _searchController,
            autofocus: widget.autoFocus,
            placeholder: getSearchPlaceholder(),
            onChanged: (value) {
              setState(() {
                filteredCountries = _filterCountries(value);
              });
            },
          ),
        ),
        Flexible(
          child: filteredCountries.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.emptySearchMessage,
                      style: widget.subtitleStyle ?? theme.textTheme.textStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: widget.scrollController,
                  shrinkWrap: true,
                  itemCount: filteredCountries.length,
                  itemBuilder: (BuildContext context, int index) {
                    final country = filteredCountries[index];
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(country),
                      // Replaced Container with DecoratedBox + Padding
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0x1F000000)),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              if (widget.showFlags)
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    end: 12,
                                  ),
                                  child: FlagWidget(
                                    country: country,
                                    style:
                                        widget.flagStyle ??
                                        theme.textTheme.textStyle.copyWith(
                                          fontSize: widget.flagSize,
                                        ),
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      country.name,
                                      textDirection: Directionality.of(context),
                                      style:
                                          widget.titleStyle ??
                                          theme.textTheme.textStyle,
                                      textAlign: TextAlign.start,
                                    ),
                                    Text(
                                      country.dialCode,
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.start,
                                      style:
                                          widget.subtitleStyle ??
                                          theme.textTheme.tabLabelTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
