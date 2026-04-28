import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/widgets/cupertino/countries_search_list_widget.dart';
import 'package:intl_phone_number_input/src/utils/input_types.dart';
import 'package:intl_phone_number_input/src/widgets/common/item.dart';

class CupertinoSelectorButton extends StatelessWidget {
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

  const CupertinoSelectorButton({
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
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: countries.isNotEmpty && countries.length > 1 && isEnabled
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
      return showCountrySelectorBottomSheet(context, countries);
    }

    return showCountrySelectorDialog(context, countries);
  }

  Future<Country?> showCountrySelectorDialog(
    BuildContext inheritedContext,
    List<Country> countries,
  ) {
    return showCupertinoDialog<Country>(
      context: inheritedContext,
      barrierDismissible: true,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Directionality(
          textDirection: Directionality.of(inheritedContext),
          child: SizedBox(
            width: double.maxFinite,
            child: CupertinoCountrySearchListWidget(
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
        ),
      ),
    );
  }

  Future<Country?> showCountrySelectorBottomSheet(
    BuildContext inheritedContext,
    List<Country> countries,
  ) {
    return showCupertinoModalPopup<Country>(
      context: inheritedContext,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: Directionality.of(inheritedContext),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: CupertinoPopupSurface(
              isSurfacePainted: true,
              child: SafeArea(
                top: false,
                bottom: selectorConfig.useBottomSheetSafeArea,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: CupertinoCountrySearchListWidget(
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
              ),
            ),
          ),
        );
      },
    );
  }
}
