import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/widgets/countries_search_list_widget.dart';
import 'package:intl_phone_number_input/src/widgets/input_widget.dart';
import 'package:intl_phone_number_input/src/widgets/item.dart';

/// [SelectorButton]
class SelectorButton extends StatelessWidget {
  final List<Country> countries;
  final Country? country;
  final SelectorConfig selectorConfig;
  final TextStyle? selectorTextStyle;
  final TextStyle? flagStyle;
  final InputDecoration? searchBoxDecoration;
  final bool autoFocusSearchField;
  final bool isEnabled;
  final bool isScrollControlled;
  final double flagSize;

  final ValueChanged<Country> onCountryChanged;
  final List<Country> Function(String value) filterFunction;

  const SelectorButton({
    super.key,
    required this.countries,
    this.country,
    required this.selectorConfig,
    this.selectorTextStyle,
    this.flagStyle,
    required this.searchBoxDecoration,
    required this.autoFocusSearchField,
    required this.onCountryChanged,
    required this.isEnabled,
    required this.isScrollControlled,
    required this.flagSize,
    required this.filterFunction,
  });

  @override
  Widget build(BuildContext context) {
    return selectorConfig.selectorType == PhoneInputSelectorType.DROPDOWN
        ? countries.isNotEmpty && countries.length > 1
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<Country>(
                    hint: Item(
                      country: country,
                      showFlag: selectorConfig.showFlags,
                      leadingPadding: selectorConfig.leadingPadding,
                      trailingSpace: selectorConfig.trailingSpace,
                      textStyle: selectorTextStyle,
                      flagStyle: flagStyle,
                      flagSize: flagSize,
                    ),
                    value: country,
                    items: mapCountryToDropdownItem(countries),
                    onChanged: (val) {
                      if (val != null && isEnabled) {
                        onCountryChanged(val);
                      }
                    },
                  ),
                )
              : Item(
                  country: country,
                  showFlag: selectorConfig.showFlags,
                  leadingPadding: selectorConfig.leadingPadding,
                  trailingPadding: selectorConfig.trailingPadding,
                  trailingSpace: selectorConfig.trailingSpace,
                  textStyle: selectorTextStyle,
                  flagStyle: flagStyle,
                  flagSize: flagSize,
                )
        : MaterialButton(
            padding: EdgeInsets.zero,
            minWidth: 0,
            onPressed: countries.isNotEmpty && countries.length > 1 && isEnabled
                ? () async {
                    Country? selected;
                    if (selectorConfig.selectorType ==
                        PhoneInputSelectorType.BOTTOM_SHEET) {
                      selected = await showCountrySelectorBottomSheet(
                        context,
                        countries,
                      );
                    } else {
                      selected = await showCountrySelectorDialog(
                        context,
                        countries,
                      );
                    }

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

  /// Converts the list [countries] to `DropdownMenuItem` 09931265823
  List<DropdownMenuItem<Country>> mapCountryToDropdownItem(
    List<Country> countries,
  ) {
    return countries.map((country) {
      return DropdownMenuItem<Country>(
        value: country,
        child: Item(
          country: country,
          showFlag: selectorConfig.showFlags,
          textStyle: selectorTextStyle,
          flagStyle: flagStyle,
          trailingSpace: selectorConfig.trailingSpace,
          flagSize: flagSize,
        ),
      );
    }).toList();
  }

  /// shows a Dialog with list [countries] if the [PhoneInputSelectorType.DIALOG] is selected
  Future<Country?> showCountrySelectorDialog(
    BuildContext inheritedContext,
    List<Country> countries,
  ) {
    return showDialog(
      context: inheritedContext,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        content: Directionality(
          textDirection: Directionality.of(inheritedContext),
          child: SizedBox(
            width: double.maxFinite,
            child: CountrySearchListWidget(
              countries,
              searchBoxDecoration: searchBoxDecoration,
              showFlags: selectorConfig.showFlags,
              autoFocus: autoFocusSearchField,
              flagSize: flagSize,
              flagStyle: flagStyle,
              titleStyle: selectorConfig.titleStyle,
              subtitleStyle: selectorConfig.subtitleStyle,
              filterFunction: filterFunction,
            ),
          ),
        ),
      ),
    );
  }

  /// shows a Dialog with list [countries] if the [PhoneInputSelectorType.BOTTOM_SHEET] is selected
  Future<Country?> showCountrySelectorBottomSheet(
    BuildContext inheritedContext,
    List<Country> countries,
  ) {
    return showModalBottomSheet(
      context: inheritedContext,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      useSafeArea: selectorConfig.useBottomSheetSafeArea,
      builder: (BuildContext context) {
        return Stack(
          children: [
            GestureDetector(onTap: () => Navigator.pop(context)),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: DraggableScrollableSheet(
                builder: (BuildContext context, ScrollController controller) {
                  return Directionality(
                    textDirection: Directionality.of(inheritedContext),
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: Theme.of(context).canvasColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: CountrySearchListWidget(
                        countries,
                        searchBoxDecoration: searchBoxDecoration,
                        scrollController: controller,
                        showFlags: selectorConfig.showFlags,
                        autoFocus: autoFocusSearchField,
                        flagSize: flagSize,
                        flagStyle: flagStyle,
                        titleStyle: selectorConfig.titleStyle,
                        subtitleStyle: selectorConfig.subtitleStyle,
                        filterFunction: filterFunction,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
