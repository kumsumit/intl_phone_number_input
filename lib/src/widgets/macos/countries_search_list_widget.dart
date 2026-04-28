import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/widgets/common/flag_widget.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosCountrySearchListWidget extends StatefulWidget {
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

  const MacosCountrySearchListWidget(
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
  State<MacosCountrySearchListWidget> createState() =>
      _MacosCountrySearchListWidgetState();
}

class _MacosCountrySearchListWidgetState
    extends State<MacosCountrySearchListWidget> {
  final TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;

  @override
  void initState() {
    super.initState();
    filteredCountries = _filterCountries(_searchController.text);
  }

  @override
  void didUpdateWidget(covariant MacosCountrySearchListWidget oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: MacosSearchField(
            controller: _searchController,
            autofocus: widget.autoFocus,
            placeholder: widget.searchPlaceholder ?? widget.searchHintText,
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
                      style: widget.subtitleStyle ?? theme.typography.caption1,
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
                    return PressableMacosListTile(
                      onPressed: () => Navigator.of(context).pop(country),
                      leading: widget.showFlags
                          ? FlagWidget(
                              country: country,
                              style:
                                  widget.flagStyle ??
                                  theme.typography.body.copyWith(
                                    fontSize: widget.flagSize,
                                  ),
                            )
                          : null,
                      title: Text(
                        country.name,
                        style: widget.titleStyle ?? theme.typography.headline,
                      ),
                      subtitle: Text(
                        country.dialCode,
                        style:
                            widget.subtitleStyle ??
                            theme.typography.subheadline,
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

/// A helper widget to make the list tile feel native to macOS interaction
class PressableMacosListTile extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? leading;
  final Widget title;
  final Widget subtitle;

  const PressableMacosListTile({
    super.key,
    required this.onPressed,
    this.leading,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: MacosListTile(
            leading: leading,
            title: title,
            subtitle: subtitle,
          ),
        ),
      ),
    );
  }
}
