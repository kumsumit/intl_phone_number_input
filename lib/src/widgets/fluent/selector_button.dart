import 'package:fluent_ui/fluent_ui.dart'; // Swapped from macos_ui
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/widgets/fluent/countries_search_list_widget.dart';
import 'package:intl_phone_number_input/src/widgets/common/item.dart';

class FluentSelectorButton extends StatelessWidget {
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

  const FluentSelectorButton({
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
    // We use a HoverButton or Button to give it the Windows 'Clickable' feel
    return Button(
      onPressed: countries.isNotEmpty && countries.length > 1 && isEnabled
          ? () async {
              final selected = await _showSelector(context, countries);
              if (selected != null) {
                onCountryChanged(selected);
              }
            }
          : null,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
      ),
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
    // Windows doesn't typically use bottom sheets for this.
    // We default to a ContentDialog for both types for a consistent Windows experience.
    return showCountrySelectorDialog(context, countries);
  }

  Future<Country?> showCountrySelectorDialog(
    BuildContext context,
    List<Country> countries,
  ) {
    return showDialog<Country>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => ContentDialog(
        title: Text(searchFieldPlaceholder ?? 'Select Country'),
        constraints: const BoxConstraints(maxWidth: 450),
        content: SizedBox(
          height: 500, // Fixed height for the scrollable list
          child: FluentCountrySearchListWidget(
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
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
