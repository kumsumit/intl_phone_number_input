import 'dart:math' as math;

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
    required this.autoFocusSearchField,
    required this.onCountryChanged,
    required this.isEnabled,
    required this.isScrollControlled,
    required this.flagSize,
    required this.filterFunction,
  });

  Widget _buildItem(Country? itemCountry, {double? maximumFlagSize}) {
    return Item(
      country: itemCountry,
      showFlag: selectorConfig.showFlags,
      leadingPadding: selectorConfig.leadingPadding,
      trailingSpace: selectorConfig.trailingSpace,
      textStyle: selectorTextStyle,
      flagStyle: flagStyle,
      flagSize: math.min(flagSize, maximumFlagSize ?? flagSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleCountries = countries.isNotEmpty && countries.length > 1;

    if (selectorConfig.selectorType == PhoneInputSelectorType.DROPDOWN) {
      return SizedBox(
        height: 38,
        child: PushButton(
          controlSize: ControlSize.large,
          secondary: true,
          borderRadius: BorderRadius.circular(7),
          onPressed: hasMultipleCountries && isEnabled
              ? () async {
                  final selected = await _showSelector(context, countries);
                  if (selected != null) {
                    onCountryChanged(selected);
                  }
                }
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildItem(country, maximumFlagSize: 16),
              const SizedBox(width: 2),
              const MacosIcon(CupertinoIcons.chevron_down, size: 11),
            ],
          ),
        ),
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
        title: Text(selectorConfig.selectorTitle),
        // Injecting the scrollable list into the message slot
        message: SizedBox(
          width: 400,
          height: 450,
          child: MacosCountrySearchListWidget(
            countries,
            searchPlaceholder: selectorConfig.searchHintText,
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
                  selectorConfig.selectorTitle,
                  style: MacosTheme.of(context).typography.headline,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: MacosCountrySearchListWidget(
                    countries,
                    searchPlaceholder: selectorConfig.searchHintText,
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
