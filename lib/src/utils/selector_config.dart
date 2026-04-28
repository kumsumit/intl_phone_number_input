import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/widgets/input_widget.dart';

/// Compares two countries for custom selector ordering.
///
/// Return `-1` if `a` should come before `b`, `0` if they are equivalent,
/// and `1` if `b` should come before `a`.
typedef CountryComparator = int Function(Country, Country);

/// Configuration for the country selector UI.
class SelectorConfig {
  /// Which selector presentation to use.
  final PhoneInputSelectorType selectorType;

  /// Whether to show flags in the selector button, dropdown items, and list rows.
  final bool showFlags;

  /// Optional custom sort order for the country list.
  ///
  /// When omitted, the incoming list order is preserved unless other widget
  /// features reorder it.
  final CountryComparator? countryComparator;

  /// Whether to place the selector inside the text field as a prefix icon.
  final bool setSelectorButtonAsPrefixIcon;

  /// Leading space before the selector content.
  final double? leadingPadding;

  /// Trailing space after the selector content.
  final double? trailingPadding;

  /// Whether to pad short dial codes for more stable visual width.
  final bool trailingSpace;

  /// Whether the bottom-sheet selector should respect the safe area.
  final bool useBottomSheetSafeArea;

  /// Text style for country names in the selector list.
  final TextStyle? titleStyle;

  /// Text style for country dial codes and empty-state text in the selector list.
  final TextStyle? subtitleStyle;

  /// Hint text shown in the selector search field.
  final String searchHintText;

  /// Message shown when no country matches the current query.
  final String emptySearchMessage;

  const SelectorConfig({
    this.selectorType = PhoneInputSelectorType.DROPDOWN,
    this.showFlags = true,
    this.countryComparator,
    this.setSelectorButtonAsPrefixIcon = false,
    this.leadingPadding,
    this.trailingPadding,
    this.trailingSpace = true,
    this.useBottomSheetSafeArea = false,
    this.titleStyle,
    this.subtitleStyle,
    this.searchHintText = 'Search by country name or dial code',
    this.emptySearchMessage = 'No matching countries',
  });
}
