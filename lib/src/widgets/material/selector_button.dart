import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/input_types.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/widgets/common/item.dart';
import 'package:intl_phone_number_input/src/widgets/material/countries_search_list_widget.dart';

class MaterialSelectorButton extends StatelessWidget {
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
  final List<Country> Function(String value)? filterFunction;

  const MaterialSelectorButton({
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

  // Builds the shared Item widget used both as the button face
  // and as the dropdown header — ensures identical padding/style everywhere.
  Widget _buildItem({bool inDropdownList = false}) {
    return Item(
      country: country,
      showFlag: selectorConfig.showFlags,
      leadingPadding: selectorConfig.leadingPadding,
      trailingPadding: inDropdownList ? null : selectorConfig.trailingPadding,
      trailingSpace: selectorConfig.trailingSpace,
      textStyle: selectorTextStyle,
      flagStyle: flagStyle,
      flagSize: flagSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMultipleCountries =
        countries.isNotEmpty && countries.length > 1;

    if (selectorConfig.selectorType == PhoneInputSelectorType.DROPDOWN) {
      if (!hasMultipleCountries) {
        // Only one country — show a static item, no button chrome at all.
        return _buildItem();
      }

      return DropdownButtonHideUnderline(
        child: DropdownButton<Country>(
          value: country,
          // selectedItemBuilder ensures the *header* always looks like
          // _buildItem(), regardless of which item is highlighted in the list.
          selectedItemBuilder: (BuildContext context) {
            return countries.map((_) => _buildItem()).toList();
          },
          hint: _buildItem(),
          items: _mapCountryToDropdownItem(countries),
          onChanged: isEnabled
              ? (Country? val) {
                  if (val != null) onCountryChanged(val);
                }
              : null, // passing null disables the dropdown natively
        ),
      );
    }

    // BOTTOM_SHEET / DIALOG — single tappable surface, no MaterialButton.
    return InkWell(
      onTap: hasMultipleCountries && isEnabled
          ? () async {
              final selected = await _showSelector(context, countries);
              if (selected != null) {
                onCountryChanged(selected);
              }
            }
          : null,
      child: _buildItem(),
    );
  }

  Future<Country?> _showSelector(
    BuildContext context,
    List<Country> countries,
  ) {
    if (selectorConfig.selectorType == PhoneInputSelectorType.BOTTOM_SHEET) {
      return _showCountrySelectorBottomSheet(context, countries);
    }
    return _showCountrySelectorDialog(context, countries);
  }

  List<DropdownMenuItem<Country>> _mapCountryToDropdownItem(
    List<Country> countries,
  ) {
    return countries.map((c) {
      return DropdownMenuItem<Country>(
        value: c,
        child: Item(
          country: c,
          showFlag: selectorConfig.showFlags,
          textStyle: selectorTextStyle,
          flagStyle: flagStyle,
          trailingSpace: selectorConfig.trailingSpace,
          flagSize: flagSize,
        ),
      );
    }).toList();
  }

  Future<Country?> _showCountrySelectorDialog(
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
            child: MaterialCountrySearchListWidget(
              countries,
              searchBoxDecoration: searchBoxDecoration,
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

  Future<Country?> _showCountrySelectorBottomSheet(
    BuildContext inheritedContext,
    List<Country> countries,
  ) {
    return showModalBottomSheet(
      context: inheritedContext,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
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
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                      child: MaterialCountrySearchListWidget(
                        countries,
                        searchBoxDecoration: searchBoxDecoration,
                        scrollController: controller,
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
