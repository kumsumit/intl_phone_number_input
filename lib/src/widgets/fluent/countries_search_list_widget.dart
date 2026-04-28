import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/widgets/common/flag_widget.dart';

class FluentCountrySearchListWidget extends StatefulWidget {
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

  const FluentCountrySearchListWidget(
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
  State<FluentCountrySearchListWidget> createState() =>
      _FluentCountrySearchListWidgetState();
}

class _FluentCountrySearchListWidgetState
    extends State<FluentCountrySearchListWidget> {
  final TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;

  @override
  void initState() {
    super.initState();
    filteredCountries = _filterCountries(_searchController.text);
  }

  @override
  void didUpdateWidget(covariant FluentCountrySearchListWidget oldWidget) {
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
    final theme = FluentTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextBox(
            controller: _searchController,
            autofocus: widget.autoFocus,
            placeholder: widget.searchPlaceholder ?? widget.searchHintText,
            prefix: const Padding(
              padding: EdgeInsetsDirectional.only(start: 8.0),
              child: Icon(FluentIcons.search),
            ),
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
                      style: widget.subtitleStyle ?? theme.typography.body,
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
                    return ListTile.selectable(
                      selectionMode: ListTileSelectionMode.none,
                      onPressed: () => Navigator.of(context).pop(country),
                      leading: widget.showFlags
                          ? FlagWidget(
                              country: country,
                              style:
                                  widget.flagStyle ??
                                  theme.typography.body?.copyWith(
                                    fontSize: widget.flagSize,
                                  ),
                            )
                          : null,
                      title: Text(
                        country.name,
                        style: widget.titleStyle ?? theme.typography.bodyStrong,
                      ),
                      subtitle: Text(
                        country.dialCode,
                        style: widget.subtitleStyle ?? theme.typography.caption,
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
