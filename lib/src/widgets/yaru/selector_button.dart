import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/widgets/common/item.dart';
import 'package:intl_phone_number_input/src/utils/input_types.dart';
import 'package:intl_phone_number_input/src/widgets/yaru/countries_search_list_widget.dart';
import 'package:yaru/yaru.dart';

class YaruSelectorButton extends StatelessWidget {
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

  const YaruSelectorButton({
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
      return YaruPopupMenuButton<Country>(
        initialValue: country,
        enabled: hasMultipleCountries && isEnabled,
        onSelected: onCountryChanged,
        constraints: const BoxConstraints(maxHeight: 420),
        child: _buildItem(country),
        itemBuilder: (context) => countries
            .map(
              (item) =>
                  PopupMenuItem<Country>(value: item, child: _buildItem(item)),
            )
            .toList(),
      );
    }

    return InkWell(
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
    // Ubuntu desktop apps use dialogs/menus rather than mobile bottom sheets.
    return showYaruCountryDialog(context, countries);
  }

  Future<Country?> showYaruCountryDialog(
    BuildContext inheritedContext,
    List<Country> countries,
  ) {
    return showDialog<Country>(
      context: inheritedContext,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        title: YaruDialogTitleBar(
          title: Text(selectorConfig.selectorTitle),
          isClosable: true,
        ),
        content: SizedBox(
          width: 450,
          height: 500,
          child: _buildSearchList(context),
        ),
        actions: [
          YaruOptionButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Helper to maintain the same list logic
  Widget _buildSearchList(BuildContext context) {
    return YaruCountrySearchListWidget(
      countries,
      scrollController: ScrollController(),
      autoFocus: autoFocusSearchField,
      showFlags: selectorConfig.showFlags,
      flagSize: flagSize,
      flagStyle: flagStyle,
      titleStyle:
          selectorConfig.titleStyle ?? Theme.of(context).textTheme.titleMedium,
      subtitleStyle:
          selectorConfig.subtitleStyle ?? Theme.of(context).textTheme.bodySmall,
      searchHintText: selectorConfig.searchHintText,
      emptySearchMessage: selectorConfig.emptySearchMessage,
      filterFunction: filterFunction,
    );
  }
}
