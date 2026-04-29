import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/widgets/macos/countries_search_list_widget.dart';
import 'package:intl_phone_number_input/src/utils/input_types.dart';
import 'package:intl_phone_number_input/src/widgets/common/item.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosSelectorButton extends StatelessWidget {
  final List<Country> countries;
  final Country? country;
  final SelectorConfig selectorConfig;
  final TextStyle? selectorTextStyle;
  final TextStyle? flagStyle;
  final String? searchFieldPlaceholder;
  final bool autoFocusSearchField;
  final bool isEnabled;
  final bool isScrollControlled;
  final double flagSize;
  final ValueChanged<Country> onCountryChanged;
  final List<Country> Function(String value)? filterFunction;

  const MacosSelectorButton({
    super.key,
    required this.countries,
    this.country,
    required this.selectorConfig,
    this.selectorTextStyle,
    this.flagStyle,
    this.searchFieldPlaceholder,
    required this.autoFocusSearchField,
    required this.onCountryChanged,
    required this.isEnabled,
    required this.isScrollControlled,
    required this.flagSize,
    required this.filterFunction,
  });

  Widget _buildItem(Country? itemCountry) {
    return Item(
      country: itemCountry,
      showFlag: selectorConfig.showFlags,
      leadingPadding: selectorConfig.leadingPadding,
      trailingSpace: selectorConfig.trailingSpace,
      textStyle: selectorTextStyle,
      flagStyle: flagStyle,
      flagSize: flagSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleCountries = countries.isNotEmpty && countries.length > 1;

    if (selectorConfig.selectorType == PhoneInputSelectorType.DROPDOWN) {
      return MacosPopupButton<Country>(
        value: country,
        itemHeight: null,
        items: countries
            .map(
              (item) => MacosPopupMenuItem<Country>(
                value: item,
                child: _buildItem(item),
              ),
            )
            .toList(),
        selectedItemBuilder: (context) =>
            countries.map((_) => _buildItem(country)).toList(),
        hint: _buildItem(country),
        onChanged: hasMultipleCountries && isEnabled
            ? (selected) {
                if (selected != null) {
                  onCountryChanged(selected);
                }
              }
            : null,
      );
    }

    return GestureDetector(
      onTap: hasMultipleCountries && isEnabled
          ? () async {
              final selected = await _showSelector(context, countries);
              if (selected != null) {
                onCountryChanged(selected);
              }
            }
          : null,
      child: _buildItem(country),
    );
  }

  Future<Country?> _showSelector(
    BuildContext context,
    List<Country> countries,
  ) {
    if (selectorConfig.selectorType == PhoneInputSelectorType.BOTTOM_SHEET) {
      return showCountrySelectorSheet(context, countries);
    }

    return showCountrySelectorDialog(context, countries);
  }

  Future<Country?> showCountrySelectorDialog(
    BuildContext inheritedContext,
    List<Country> countries,
  ) {
    return showMacosAlertDialog<Country>(
      context: inheritedContext,
      barrierDismissible: true,
      builder: (BuildContext context) => MacosAlertDialog(
        appIcon: const MacosIcon(CupertinoIcons.globe),
        title: Text(searchFieldPlaceholder ?? 'Select Country'),
        // Injecting the scrollable list into the message slot
        message: SizedBox(
          width: 400,
          height: 450,
          child: MacosCountrySearchListWidget(
            countries,
            searchPlaceholder: searchFieldPlaceholder,
            showFlags: selectorConfig.showFlags,
            autoFocus: autoFocusSearchField,
            flagSize: flagSize,
            flagStyle: flagStyle,
            titleStyle: selectorConfig.titleStyle,
            subtitleStyle: selectorConfig.subtitleStyle,
            searchHintText: selectorConfig.searchHintText,
            emptySearchMessage: selectorConfig.emptySearchMessage,
            filterFunction: filterFunction,
          ),
        ),
        primaryButton: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<Country?> showCountrySelectorSheet(
    BuildContext inheritedContext,
    List<Country> countries,
  ) {
    return showMacosSheet<Country>(
      context: inheritedContext,
      builder: (BuildContext context) {
        return MacosSheet(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  searchFieldPlaceholder ?? 'Select Country',
                  style: MacosTheme.of(context).typography.headline,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: MacosCountrySearchListWidget(
                    countries,
                    searchPlaceholder: searchFieldPlaceholder,
                    showFlags: selectorConfig.showFlags,
                    autoFocus: autoFocusSearchField,
                    flagSize: flagSize,
                    flagStyle: flagStyle,
                    titleStyle: selectorConfig.titleStyle,
                    subtitleStyle: selectorConfig.subtitleStyle,
                    searchHintText: selectorConfig.searchHintText,
                    emptySearchMessage: selectorConfig.emptySearchMessage,
                    filterFunction: filterFunction,
                  ),
                ),
                const SizedBox(height: 16),
                PushButton(
                  controlSize: ControlSize.large,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
