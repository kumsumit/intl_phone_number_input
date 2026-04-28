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
  final String? searchFieldPlaceholder;
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
    this.searchFieldPlaceholder,
    required this.autoFocusSearchField,
    required this.onCountryChanged,
    required this.isEnabled,
    required this.isScrollControlled,
    required this.flagSize,
    required this.filterFunction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: countries.isNotEmpty && countries.length > 1 && isEnabled
          ? () async {
              final selected = await _showSelector(context, countries);
              if (selected != null) {
                onCountryChanged(selected);
              }
            }
          : null,
      child: Item(
        country: country,
        showFlag: selectorConfig.showFlags,
        leadingPadding: selectorConfig.leadingPadding,
        trailingSpace: selectorConfig.trailingSpace,
        textStyle: selectorTextStyle,
        flagStyle: flagStyle,
        flagSize: flagSize,
      ),
    );
  }

  Future<Country?> _showSelector(
    BuildContext context,
    List<Country> countries,
  ) {
    if (selectorConfig.selectorType == PhoneInputSelectorType.BOTTOM_SHEET) {
      return showYaruBottomSheet(context, countries);
    }
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
          title: Text(searchFieldPlaceholder ?? 'Select Country'),
          isClosable: true,
        ),
        content: SizedBox(
          width: 450,
          height: 500,
          child: _buildSearchList(context),
        ),
        actions: [
          YaruOptionButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Future<Country?> showYaruBottomSheet(
    BuildContext inheritedContext,
    List<Country> countries,
  ) {
    return showModalBottomSheet<Country>(
      context: inheritedContext,
      isScrollControlled: isScrollControlled,
      useSafeArea: selectorConfig.useBottomSheetSafeArea,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    searchFieldPlaceholder ?? 'Select Country',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(child: _buildSearchList(context)),
              ],
            );
          },
        );
      },
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
      titleStyle: selectorConfig.titleStyle ?? Theme.of(context).textTheme.titleMedium,
      subtitleStyle: selectorConfig.subtitleStyle ?? Theme.of(context).textTheme.bodySmall,
      searchHintText: searchFieldPlaceholder ?? 'Search country',
      emptySearchMessage: 'No countries found',
      filterFunction: filterFunction,
    );
  }
}
