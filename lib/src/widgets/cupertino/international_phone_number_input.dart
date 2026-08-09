import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/country_detector.dart';
import 'package:intl_phone_number_input/src/utils/formatter/as_you_type_formatter.dart';
import 'package:intl_phone_number_input/src/utils/input_types.dart';
import 'package:intl_phone_number_input/src/utils/metadata_bootstrap.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/widgets/cupertino/input_widget_view.dart';
import 'package:intl_phone_number_input/src/widgets/cupertino/selector_button.dart';
import 'package:phone_parser/phone_parser.dart';

final Map<String, List<int>> _acceptedLengthCache = <String, List<int>>{};
const Set<String> _sensitiveNeighborCodes = {'XK'};

/// Shared core for the public phone input widgets (platform-neutral).
///
/// [initialValue] accepts a [PhoneNumber] this is used to set initial values
/// for phone the input field and the selector button
///
/// [selectorButtonOnErrorPadding] is a double which is used to align the selector
/// button with the input field when an error occurs
///
/// [countries] accepts list of string on Country isoCode, if specified filters
/// available countries to match the [countries] specified.
class CupertinoInternationalPhoneNumber extends StatefulWidget {
  /// Controls how the country selector is rendered and styled.
  final SelectorConfig selectorConfig;

  /// The list of countries available in the selector.
  final List<Country> countries;

  /// The initially selected country.
  final Country defaultCountry;

  /// Optional override for filtering countries inside the selector search UI.
  final List<Country> Function(String value)? filterFunction;

  /// Whether to attempt automatic country detection on startup.
  final bool autoDetectCountry;

  /// Selects which signal source the built-in detector should use.
  final CountryDetectionMode countryDetectionMode;

  /// Optional override for country detection.
  ///
  /// When provided, this is used instead of the built-in detector.
  final CountryDetectorCallback? countryDetector;

  /// Optional override for resolving neighboring countries for an ISO code.
  final CountryNeighborResolver? countryNeighborResolver;

  /// Called with the detection result after auto-detection completes.
  final ValueChanged<CountryResult>? onAutoCountryDetected;

  /// Controls how countries are reordered when detection is enabled.
  final DetectedCountryOrderStrategy detectedCountryOrderStrategy;

  /// Called whenever the parsed phone number changes.
  final ValueChanged<PhoneNumber>? onInputChanged;

  /// Called whenever the current phone number validity changes.
  final ValueChanged<bool>? onInputValidated;

  /// Called when the text field editing is completed.
  final VoidCallback? onSubmit;

  /// Called when the user submits the text field.
  final ValueChanged<String>? onFieldSubmitted;

  /// Optional custom validator for the text field.
  ///
  /// When omitted, the built-in phone-number validator is used.
  final String? Function(String?)? validator;

  /// Called when a parent [Form] saves this field.
  final ValueChanged<PhoneNumber>? onSaved;

  /// Optional key forwarded to the internal [TextFormField].
  final Key? fieldKey;

  /// Optional external controller for the internal text field.
  final TextEditingController? textFieldController;

  /// Keyboard configuration for the internal text field.
  final TextInputType keyboardType;

  /// Action button shown by the platform keyboard.
  final TextInputAction? keyboardAction;

  /// Initial phone number value used to populate the field and country.
  final PhoneNumber? initialValue;

  /// Hint text for the field. Defaults to a formatted example number for the
  /// selected country.
  final String? hintText;

  /// Label widget used when [inputDecoration] is not provided.
  final Widget? label;

  /// Error message shown by the default validator.
  final String? errorMessage;

  /// Warning shown when the user tries to type a country code into the field.
  final String? countryCodeWarningMessage;

  /// Bottom padding used to align the selector when the text field shows an error.
  final double selectorButtonOnErrorPadding;

  /// Horizontal gap between the selector button and the text field.
  ///
  /// Only used when [selectorConfig.setSelectorButtonAsPrefixIcon] is `false`.
  final double spaceBetweenSelectorAndTextField;

  /// Optional widget rendered below the external selector button column.
  ///
  /// Only used when [selectorConfig.setSelectorButtonAsPrefixIcon] is `false`.
  final Widget? selectorButtonBottomWidget;

  /// Optional widget rendered between the external selector button and the text
  /// field.
  ///
  /// Only used when [selectorConfig.setSelectorButtonAsPrefixIcon] is `false`.
  final Widget? betweenTextFieldWidget;
  // final int maxLength;

  /// Whether the selector and text field are interactive.
  final bool isEnabled;

  /// Whether to format the input as the user types.
  final bool formatInput;

  /// Whether the text field should request focus automatically.
  final bool autoFocus;

  /// Whether the selector search field should autofocus when opened.
  final bool autoFocusSearch;

  /// Validation mode forwarded to the internal [TextFormField].
  final AutovalidateMode autoValidateMode;

  /// Whether a blank value should be treated as valid.
  final bool ignoreBlank;

  /// Whether the bottom-sheet selector should be scroll-controlled.
  final bool countrySelectorScrollControlled;

  /// Text direction used by the internal text field.
  final TextDirection textDirection;

  /// Text style for the phone number input.
  final TextStyle? textStyle;

  /// Text style for the selector button and dropdown items.
  final TextStyle? selectorTextStyle;

  /// Text style used when rendering flag emoji.
  final TextStyle? flagStyle;

  /// Decoration for the CupertinoTextField (background, border, etc).
  final BoxDecoration? decoration;

  /// Placeholder text for the CupertinoTextField.
  final String? placeholder;

  /// Widget to display before the editable part.
  final Widget? prefix;

  /// Widget to display after the editable part.
  final Widget? suffix;

  /// Padding for the CupertinoTextField content.
  final EdgeInsets? padding;

  /// Cursor color for the text field.
  final Color? cursorColor;

  /// Horizontal text alignment inside the text field.
  final TextAlign textAlign;

  /// Vertical text alignment inside the text field.
  final TextAlignVertical textAlignVertical;

  /// Scroll padding forwarded to the internal [TextFormField].
  final EdgeInsets scrollPadding;

  /// Called when the text field is tapped.
  final void Function()? onTap;

  /// Focus node for the internal text field.
  final FocusNode? focusNode;

  /// Autofill hints forwarded to the internal text field.
  final Iterable<String>? autofillHints;

  /// Font size used for flag emoji rendering.
  final double flagSize;

  /// Disables metadata-based minimum and maximum length enforcement.
  final bool disableLengthCheck;

  CupertinoInternationalPhoneNumber({
    super.key,
    required this.countries,
    required this.defaultCountry,
    this.filterFunction,
    this.autoDetectCountry = false,
    this.countryDetectionMode = CountryDetectionMode.localSignals,
    this.countryDetector,
    this.countryNeighborResolver,
    this.onAutoCountryDetected,
    this.detectedCountryOrderStrategy = DetectedCountryOrderStrategy.none,
    this.selectorConfig = const SelectorConfig(),
    this.onInputChanged,
    this.onInputValidated,
    this.onSubmit,
    this.textDirection = TextDirection.ltr,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.onTap,
    this.fieldKey,
    this.textFieldController,
    this.keyboardAction,
    this.keyboardType = TextInputType.phone,
    this.initialValue,
    this.hintText,
    this.errorMessage = 'Invalid phone number',
    this.countryCodeWarningMessage =
        'Enter the phone number without country code',
    this.selectorButtonOnErrorPadding = 24,
    this.spaceBetweenSelectorAndTextField = 12,
    this.isEnabled = true,
    this.formatInput = true,
    this.autoFocus = false,
    this.autoFocusSearch = false,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.ignoreBlank = false,
    this.countrySelectorScrollControlled = true,
    this.textStyle,
    this.flagStyle,
    this.selectorTextStyle,
    this.decoration,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.padding,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.focusNode,
    this.cursorColor,
    this.autofillHints,
    this.selectorButtonBottomWidget,
    this.betweenTextFieldWidget,
    this.label,
    this.disableLengthCheck = false,
    this.flagSize = 20,
  });

  @override
  State<CupertinoInternationalPhoneNumber> createState() =>
      CupertinoInternationalPhoneNumberState();
}

class CupertinoInternationalPhoneNumberState
    extends State<CupertinoInternationalPhoneNumber> {
  late TextEditingController controller;
  bool _ownsController = false;
  double selectorButtonBottomPadding = 0;
  int currentLength = 0;
  List<int> acceptedLengths = [];
  late Country country;
  List<Country> countries = [];
  bool isNotValid = true;
  String errorText = "";
  bool _showCountryCodeWarning = false;
  bool _hasUserSelectedCountry = false;
  bool _autoDetectionStarted = false;
  CountryResult? _detectedCountryResult;

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    PhoneMetadataBootstrap.ensureInitializedOrThrow();
    country = widget.defaultCountry;
    countries = _reorderCountriesForStrategy(widget.countries);
    _attachController(widget.textFieldController);
    acceptedLengths = _acceptedLengthsFor(widget.initialValue?.isoCode);
    initialiseWidget();
    _maybeAutoDetectCountry();
  }

  @override
  void setState(fn) {
    if (mounted) {
      // debugPrint("Main setState");
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoInputWidgetView(
          selectorSection: buildSelectorButton(),
          selectorSpacing: widget.spaceBetweenSelectorAndTextField,
          label: widget.label,
          fieldKey: widget.fieldKey,
          controller: controller,
          onTap: widget.onTap,
          cursorColor: widget.cursorColor,
          focusNode: widget.focusNode,
          enabled: widget.isEnabled,
          autofocus: widget.autoFocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.keyboardAction,
          textStyle: widget.textStyle,
          placeholder:
              widget.placeholder ??
              widget.hintText ??
              Utils.examplePhoneNumberHint(country.alpha2Code),
          prefix: widget.prefix,
          textAlign: widget.textAlign,
          textAlignVertical: widget.textAlignVertical,
          onEditingComplete: widget.onSubmit,
          onFieldSubmitted: widget.onFieldSubmitted,
          autovalidateMode: widget.autoValidateMode,
          validator: widget.validator ?? _defaultValidator,
          onSaved: (value) {
            if (widget.onSaved != null) {
              widget.onSaved!(_parsePhoneNumberValueOrFallback(value ?? ""));
            }
          },
          scrollPadding: widget.scrollPadding,
          inputFormatters: inputFormatters,
          counterText: formatAcceptedLengths(acceptedLengths, currentLength),
          textDirection: widget.textDirection,
          autofillHints: widget.autofillHints,
        ),
        if (widget.selectorButtonBottomWidget != null)
          widget.selectorButtonBottomWidget!,
        if (widget.betweenTextFieldWidget != null)
          widget.betweenTextFieldWidget!,
      ],
    );
  }

  Widget buildSelectorButton() {
    return CupertinoSelectorButton(
      countries: widget.countries,
      country: country,
      selectorConfig: widget.selectorConfig,
      selectorTextStyle: widget.selectorTextStyle,
      flagStyle: widget.flagStyle,
      autoFocusSearchField: widget.autoFocusSearch,
      onCountryChanged: (selected) {
        setState(() {
          country = selected;
          acceptedLengths = _acceptedLengthsFor(selected.alpha2Code);
        });
        if (widget.onInputChanged != null) {
          widget.onInputChanged!(
            PhoneNumber(isoCode: selected.alpha2Code, nsn: controller.text),
          );
        }
      },
      isEnabled: widget.isEnabled,
      isScrollControlled: widget.countrySelectorScrollControlled,
      flagSize: widget.flagSize,
      filterFunction: widget.filterFunction,
    );
  }

  @override
  void didUpdateWidget(covariant CupertinoInternationalPhoneNumber oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.textFieldController != widget.textFieldController) {
      final previousText = controller.text;
      _detachController();
      _attachController(
        widget.textFieldController,
        initialText: widget.textFieldController == null ? previousText : null,
      );
    }

    final countriesChanged = !listEquals(oldWidget.countries, widget.countries);
    final defaultCountryChanged =
        oldWidget.defaultCountry != widget.defaultCountry;
    final initialValueChanged = oldWidget.initialValue != widget.initialValue;
    final formatChanged = oldWidget.formatInput != widget.formatInput;
    final autoDetectChanged =
        oldWidget.autoDetectCountry != widget.autoDetectCountry ||
        oldWidget.countryDetectionMode != widget.countryDetectionMode ||
        oldWidget.countryDetector != widget.countryDetector ||
        oldWidget.countryNeighborResolver != widget.countryNeighborResolver ||
        oldWidget.detectedCountryOrderStrategy !=
            widget.detectedCountryOrderStrategy;

    if (!countriesChanged &&
        !defaultCountryChanged &&
        !initialValueChanged &&
        !formatChanged &&
        !autoDetectChanged) {
      return;
    }

    final nextCountries = widget.countries;
    final nextCountry = _resolveCountryForUpdate(nextCountries);

    setState(() {
      countries = _reorderCountriesForStrategy(nextCountries);
      country = nextCountry;
      acceptedLengths = _acceptedLengthsFor(nextCountry.alpha2Code);
    });

    if (initialValueChanged || formatChanged) {
      initialiseWidget();
    } else {
      phoneNumberControllerListener();
    }

    if (autoDetectChanged) {
      _autoDetectionStarted = false;
      _maybeAutoDetectCountry();
    }
  }

  void _attachController(
    TextEditingController? externalController, {
    String? initialText,
  }) {
    _ownsController = externalController == null;
    controller =
        externalController ?? TextEditingController(text: initialText ?? '');
    controller.addListener(phoneNumberControllerListener);
  }

  void _detachController() {
    controller.removeListener(phoneNumberControllerListener);
    if (_ownsController) {
      controller.dispose();
    }
  }

  List<int> _acceptedLengthsFor(String? isoCode) {
    final cacheKey = isoCode ?? country.alpha2Code;
    final cachedValue = _acceptedLengthCache[cacheKey];
    if (cachedValue != null) {
      return cachedValue;
    }

    try {
      final lengths = MetadataFinder.findMetadataLengthForIsoCode(cacheKey);
      final acceptedLengths = List<int>.unmodifiable(
        lengths["mobile"] ?? const <int>[],
      );
      _acceptedLengthCache[cacheKey] = acceptedLengths;
      return acceptedLengths;
    } catch (_) {
      _acceptedLengthCache[cacheKey] = const <int>[];
      return const <int>[];
    }
  }

  Country _resolveCountryForUpdate(List<Country> nextCountries) {
    if (nextCountries.isEmpty) {
      return widget.defaultCountry;
    }

    final initialIsoCode = widget.initialValue?.isoCode;
    if (initialIsoCode != null) {
      final initialCountry = nextCountries.where(
        (item) => item.alpha2Code == initialIsoCode,
      );
      if (initialCountry.isNotEmpty) {
        return initialCountry.first;
      }
    }

    final currentCountry = nextCountries.where(
      (item) => item.alpha2Code == country.alpha2Code,
    );
    if (currentCountry.isNotEmpty) {
      return currentCountry.first;
    }

    final defaultCountry = nextCountries.where(
      (item) => item.alpha2Code == widget.defaultCountry.alpha2Code,
    );
    if (defaultCountry.isNotEmpty) {
      return defaultCountry.first;
    }

    return nextCountries.first;
  }

  Future<void> _maybeAutoDetectCountry() async {
    if (!widget.autoDetectCountry ||
        _autoDetectionStarted ||
        _hasUserSelectedCountry ||
        _hasExplicitInitialCountry()) {
      return;
    }

    _autoDetectionStarted = true;
    final detector = widget.countryDetector ?? _defaultCountryDetector;

    try {
      final result = await detector();
      widget.onAutoCountryDetected?.call(result);
      if (!mounted ||
          result.countryCode == null ||
          result.countryCode!.isEmpty) {
        return;
      }

      final detectedCountry = _findCountryByIsoCode(result.countryCode!);
      if (detectedCountry == null) {
        return;
      }

      setState(() {
        _detectedCountryResult = result;
        country = detectedCountry;
        acceptedLengths = _acceptedLengthsFor(detectedCountry.alpha2Code);
        countries = _prioritizeCountriesForDetection(result);
      });

      phoneNumberControllerListener();
    } catch (_) {
      // Detection is best-effort only.
    }
  }

  bool _hasExplicitInitialCountry() {
    final initial = widget.initialValue;
    return initial != null && initial.isoCode.isNotEmpty;
  }

  Future<CountryResult> _defaultCountryDetector() {
    switch (widget.countryDetectionMode) {
      case CountryDetectionMode.localSignals:
        return CountryDetector.detectSync();
      case CountryDetectionMode.networkSignals:
        return CountryDetector.detect();
    }
  }

  Country? _findCountryByIsoCode(String isoCode) {
    final normalizedIsoCode = isoCode.trim().toUpperCase();
    for (final item in widget.countries) {
      if (item.alpha2Code.toUpperCase() == normalizedIsoCode) {
        return item;
      }
    }
    return null;
  }

  List<Country> _prioritizeCountriesForDetection(CountryResult result) {
    final sortedCountries = _sortCountries(widget.countries);
    final strategy = _effectiveDetectedCountryOrderStrategy;
    if (strategy == DetectedCountryOrderStrategy.none) {
      return sortedCountries;
    }

    final detectedIsoCode = result.countryCode?.toUpperCase();
    final defaultIsoCode = widget.defaultCountry.alpha2Code.toUpperCase();

    final voteOrderedCodes = result.allVotes.keys
        .map((code) => code.toUpperCase())
        .where((code) => code != detectedIsoCode)
        .toList(growable: false);

    // Put default country first if provided and different from detected
    final rootCodes = <String>[];
    if (defaultIsoCode.isNotEmpty) {
      rootCodes.add(defaultIsoCode);
    }
    if (detectedIsoCode != null &&
        detectedIsoCode.isNotEmpty &&
        detectedIsoCode != defaultIsoCode) {
      rootCodes.add(detectedIsoCode);
    }
    rootCodes.addAll(
      voteOrderedCodes.where((code) => !rootCodes.contains(code)),
    );

    if (strategy == DetectedCountryOrderStrategy.detectedCountryFirst) {
      return _orderCountriesByCodesThenAlphabetical(
        sortedCountries,
        rootCodes.take(1).toList(),
      );
    }

    final includeNeighbors =
        strategy ==
        DetectedCountryOrderStrategy.signalVotesThenNeighborsThenDistance;

    if (includeNeighbors) {
      return _orderCountriesByCodesThenAlphabetical(
        sortedCountries,
        _interleavedRootAndNeighborCodesFor(rootCodes, sortedCountries),
      );
    }

    final prioritizedCodes = <String>[...rootCodes];
    final remainingCodes = sortedCountries
        .map((country) => country.alpha2Code.toUpperCase())
        .where((code) => !prioritizedCodes.contains(code))
        .toList(growable: false);

    if (detectedIsoCode != null && detectedIsoCode.isNotEmpty) {
      prioritizedCodes.addAll(
        CountryDetector.rankCountriesByDistanceFrom(
          detectedIsoCode,
          remainingCodes,
        ),
      );
    } else {
      // Fallback if no detected
      prioritizedCodes.addAll(remainingCodes);
    }

    return _orderCountriesByCodesThenAlphabetical(
      sortedCountries,
      prioritizedCodes,
    );
  }

  List<Country> _reorderCountriesForStrategy(List<Country> countries) {
    final sortedCountries = _sortCountries(countries);
    final strategy = _effectiveDetectedCountryOrderStrategy;
    if (strategy == DetectedCountryOrderStrategy.none) {
      return sortedCountries;
    }

    final defaultIsoCode = widget.defaultCountry.alpha2Code.toUpperCase();
    final detectedResult = _detectedCountryResult;
    final detectedIsoCode = detectedResult?.countryCode?.toUpperCase();

    final voteOrderedCodes =
        detectedResult?.allVotes.keys
            .map((code) => code.toUpperCase())
            .where((code) => code != detectedIsoCode)
            .toList(growable: false) ??
        [];

    // Put default first, then detected if different, then votes
    final rootCodes = <String>[];
    if (defaultIsoCode.isNotEmpty) {
      rootCodes.add(defaultIsoCode);
    }
    if (detectedIsoCode != null &&
        detectedIsoCode.isNotEmpty &&
        detectedIsoCode != defaultIsoCode) {
      rootCodes.add(detectedIsoCode);
    }
    rootCodes.addAll(
      voteOrderedCodes.where((code) => !rootCodes.contains(code)),
    );

    if (strategy == DetectedCountryOrderStrategy.detectedCountryFirst) {
      return _orderCountriesByCodesThenAlphabetical(
        sortedCountries,
        rootCodes.take(1).toList(),
      );
    }

    final includeNeighbors =
        strategy ==
        DetectedCountryOrderStrategy.signalVotesThenNeighborsThenDistance;

    final prioritizedCodes = <String>[...rootCodes];

    if (includeNeighbors) {
      prioritizedCodes.addAll(
        _interleavedRootAndNeighborCodesFor(
          rootCodes,
          sortedCountries,
        ).where((code) => !prioritizedCodes.contains(code)),
      );
    } else {
      final remainingCodes = sortedCountries
          .map((country) => country.alpha2Code.toUpperCase())
          .where((code) => !prioritizedCodes.contains(code))
          .toList(growable: false);

      if (detectedIsoCode != null && detectedIsoCode.isNotEmpty) {
        prioritizedCodes.addAll(
          CountryDetector.rankCountriesByDistanceFrom(
            detectedIsoCode,
            remainingCodes,
          ),
        );
      } else if (defaultIsoCode.isNotEmpty) {
        prioritizedCodes.addAll(
          CountryDetector.rankCountriesByDistanceFrom(
            defaultIsoCode,
            remainingCodes,
          ),
        );
      } else {
        prioritizedCodes.addAll(remainingCodes);
      }
    }

    return _orderCountriesByCodesThenAlphabetical(
      sortedCountries,
      prioritizedCodes,
    );
  }

  List<Country> _sortCountries(List<Country> countries) {
    final comparator = widget.selectorConfig.countryComparator;
    if (comparator == null) {
      return List<Country>.from(countries);
    }

    final sorted = List<Country>.from(countries);
    sorted.sort(comparator);
    return sorted;
  }

  List<String> _neighborBucketCodesFor(
    List<String> rootCodes,
    List<Country> countries,
  ) {
    final countriesByCode = <String, Country>{
      for (final country in countries)
        country.alpha2Code.toUpperCase(): country,
    };
    final orderedCodes = <String>[];
    final seen = <String>{};

    for (final rootCode in rootCodes) {
      final neighbors =
          widget.countryNeighborResolver?.call(rootCode) ??
          CountryDetector.possibleBoundaryCountriesFor(rootCode);
      final eligibleNeighbors = neighbors
          .map((neighbor) => neighbor.toUpperCase())
          .where((neighbor) => countriesByCode.containsKey(neighbor))
          .where((neighbor) => _shouldPromoteNeighborCode(neighbor, rootCodes))
          .where((neighbor) => neighbor != rootCode)
          .toList(growable: false);
      final rankedNeighbors = CountryDetector.rankCountriesByDistanceFrom(
        rootCode,
        eligibleNeighbors,
      );
      for (final neighbor in rankedNeighbors) {
        final normalized = neighbor.toUpperCase();
        if (seen.add(normalized) && !rootCodes.contains(normalized)) {
          orderedCodes.add(normalized);
        }
      }
    }

    return orderedCodes;
  }

  List<String> _interleavedRootAndNeighborCodesFor(
    List<String> rootCodes,
    List<Country> countries,
  ) {
    final orderedCodes = <String>[];
    final seen = <String>{};

    for (final rootCode in rootCodes) {
      final normalizedRoot = rootCode.toUpperCase();
      if (seen.add(normalizedRoot)) {
        orderedCodes.add(normalizedRoot);
      }

      for (final neighborCode in _neighborBucketCodesFor([
        normalizedRoot,
      ], countries)) {
        final normalizedNeighbor = neighborCode.toUpperCase();
        if (seen.add(normalizedNeighbor)) {
          orderedCodes.add(normalizedNeighbor);
        }
      }
    }

    return orderedCodes;
  }

  bool _shouldPromoteNeighborCode(String candidate, List<String> rootCodes) {
    if (!_sensitiveNeighborCodes.contains(candidate)) {
      return true;
    }

    return rootCodes.contains(candidate);
  }

  List<Country> _orderCountriesByCodesThenAlphabetical(
    List<Country> countries,
    List<String> prioritizedCodes,
  ) {
    final byCode = <String, Country>{
      for (final item in countries) item.alpha2Code.toUpperCase(): item,
    };

    final ordered = <Country>[];
    final seen = <String>{};

    for (final code in prioritizedCodes) {
      final country = byCode[code];
      if (country != null && seen.add(code)) {
        ordered.add(country);
      }
    }

    final remaining = countries
        .where((item) {
          final code = item.alpha2Code.toUpperCase();
          return !seen.contains(code);
        })
        .toList(growable: false);

    final comparator = widget.selectorConfig.countryComparator;
    if (comparator != null) {
      remaining.sort(comparator);
    } else {
      remaining.sort((a, b) {
        final nameComparison = a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        );
        if (nameComparison != 0) {
          return nameComparison;
        }
        return a.alpha2Code.compareTo(b.alpha2Code);
      });
    }

    for (final item in remaining) {
      final code = item.alpha2Code.toUpperCase();
      if (seen.add(code)) {
        ordered.add(item);
      }
    }

    return ordered;
  }

  DetectedCountryOrderStrategy get _effectiveDetectedCountryOrderStrategy {
    return widget.detectedCountryOrderStrategy;
  }

  /// [initialiseWidget] sets initial values of the widget
  void initialiseWidget() {
    if (widget.initialValue == null || widget.initialValue!.nsn.isEmpty) {
      controller.text = '';
      phoneNumberControllerListener();
      return;
    }

    try {
      if (!widget.initialValue!.isValid()) {
        controller.text = '';
        phoneNumberControllerListener();
        return;
      }

      String phoneNumber = widget.initialValue!.formatNsn(
        isoCode: widget.initialValue?.isoCode,
        format: NsnFormat.international,
      );

      controller.text = widget.formatInput
          ? phoneNumber
          : phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    } catch (_) {
      controller.text = widget.initialValue!.nsn;
    }

    phoneNumberControllerListener();
  }

  /// Listener that validates changes from the widget, returns a bool to
  /// the `ValueCallback` [widget.onInputValidated]
  void phoneNumberControllerListener() {
    if (!mounted) {
      return;
    }

    if (controller.text.isEmpty) {
      final isValidWhenBlank = widget.ignoreBlank;
      widget.onInputChanged?.call(
        PhoneNumber(isoCode: country.alpha2Code, nsn: ''),
      );
      widget.onInputValidated?.call(isValidWhenBlank);
      setState(() {
        currentLength = 0;
        isNotValid = !isValidWhenBlank;
        errorText = _defaultValidator(controller.text) ?? "";
      });
      return;
    }

    String parsedPhoneNumberString = controller.text.replaceAll(
      RegExp(r'[^\d+]'),
      '',
    );

    late final PhoneNumber phoneNumber;
    try {
      phoneNumber = _parsePhoneNumberValue(parsedPhoneNumberString);
    } catch (_) {
      widget.onInputChanged?.call(
        _parsePhoneNumberValueOrFallback(parsedPhoneNumberString),
      );
      widget.onInputValidated?.call(false);
      setState(() {
        currentLength = parsedPhoneNumberString.replaceAll('+', '').length;
        isNotValid = true;
        errorText = _defaultValidator(controller.text) ?? "";
      });
      return;
    }

    if (phoneNumber.nsn.isEmpty || !phoneNumber.isValid()) {
      widget.onInputValidated?.call(false);
      isNotValid = true;
    } else {
      widget.onInputValidated?.call(true);
      isNotValid = false;
    }
    setState(() {
      currentLength = phoneNumber.nsn.length;
      errorText = _defaultValidator(controller.text) ?? "";
    });
    widget.onInputChanged?.call(phoneNumber);
  }

  String formatAcceptedLengths(List<int> acceptedLengths, int currentLength) {
    if (acceptedLengths.isEmpty) {
      return "$currentLength"; // fallback if nothing provided
    }

    // Work on a sorted copy for consistent display
    final sorted = [...acceptedLengths]..sort();

    if (sorted.length == 1) {
      // Single exact length
      return "$currentLength / ${sorted.first}";
    }

    // Check if consecutive range
    bool isConsecutive = true;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] != sorted[i - 1] + 1) {
        isConsecutive = false;
        break;
      }
    }

    if (isConsecutive) {
      // Display as range
      return "$currentLength / (${sorted.first}–${sorted.last})";
    }

    if (sorted.length <= 3) {
      // Small non-consecutive list → "or"
      final allButLast = sorted.take(sorted.length - 1).join(", ");
      final last = sorted.last;
      return "$currentLength / ($allButLast or $last)";
    }

    // Fallback: larger messy list → just show them as comma separated
    return "$currentLength / [${sorted.join(', ')}]";
  }

  Widget? buildExternalSelectorSection() {
    if (widget.selectorConfig.setSelectorButtonAsPrefixIcon) {
      return null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildSelectorButton(),
            if (widget.betweenTextFieldWidget != null)
              widget.betweenTextFieldWidget!,
          ],
        ),
        SizedBox(height: selectorButtonBottomPadding),
        if (widget.selectorButtonBottomWidget != null)
          widget.selectorButtonBottomWidget!,
      ],
    );
  }

  Widget? buildSelectorPrefix() {
    if (!widget.selectorConfig.setSelectorButtonAsPrefixIcon) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: buildSelectorButton(),
    );
  }

  List<TextInputFormatter> get inputFormatters {
    return [
      CountryCodeBlockerFormatter(
        onRejected: _showCountryCodeWarningMessage,
        onAccepted: _clearCountryCodeWarningMessage,
      ),
      FilteringTextInputFormatter.allow(
        RegExp('[${Patterns.plus}${Patterns.digits}${Patterns.punctuation}]'),
      ),
      widget.formatInput
          ? AsYouTypeFormatter(
              isoCode: country.alpha2Code,
              dialCode: country.dialCode,
              onInputFormatted: (_) {},
              acceptedLengths: widget.disableLengthCheck
                  ? const []
                  : acceptedLengths,
            )
          : LengthLimitingTextInputFormatter(15),
      if (!widget.formatInput) FilteringTextInputFormatter.digitsOnly,
    ];
  }

  /// Validate and returns a validation error when [FormState] validate is called.
  ///

  String? _defaultValidator(String? value) {
    // debugPrint("Validator called with: $value");
    final bool hasContent = value?.isNotEmpty ?? false;
    final bool shouldValidateBlank = !widget.ignoreBlank;
    final bool isInvalid = isNotValid && (hasContent || shouldValidateBlank);
    try {
      final isParsed = _parsePhoneNumberValue(value ?? "");
      if (isParsed.isValid()) {
        return null;
      }
    } catch (_) {
      return isInvalid ? widget.errorMessage : null;
    }
    return isInvalid ? widget.errorMessage : null;
  }

  /// Changes Selector Button Country and Validate Change.
  void onCountryChanged(Country country) {
    _hasUserSelectedCountry = true;
    setState(() {
      this.country = country;
      acceptedLengths = _acceptedLengthsFor(country.alpha2Code);
    });
    phoneNumberControllerListener();
  }

  void _phoneNumberSaved() {
    if (mounted) {
      widget.onSaved?.call(_parsePhoneNumberValueOrFallback(controller.text));
    }
  }

  PhoneNumber _parsePhoneNumberValue(String value) {
    final parsedPhoneNumberString = value.replaceAll(RegExp(r'[^\d+]'), '');

    try {
      return PhoneNumber.parse(
        parsedPhoneNumberString,
        destinationCountry: country.alpha2Code,
      );
    } catch (_) {
      return PhoneNumber.parse(
        parsedPhoneNumberString,
        callerCountry: country.alpha2Code,
      );
    }
  }

  PhoneNumber _parsePhoneNumberValueOrFallback(String value) {
    try {
      return _parsePhoneNumberValue(value);
    } catch (_) {
      final parsedPhoneNumberString = value.replaceAll(RegExp(r'[^\d+]'), '');
      final nsn = parsedPhoneNumberString.startsWith('+')
          ? parsedPhoneNumberString.replaceFirst(country.dialCode, '')
          : parsedPhoneNumberString;

      return PhoneNumber(isoCode: country.alpha2Code, nsn: nsn);
    }
  }

  /// Saved the phone number when form is saved
  void onSaved(String? value) {
    _phoneNumberSaved();
  }

  void _showCountryCodeWarningMessage() {
    if (_showCountryCodeWarning) {
      return;
    }

    setState(() {
      _showCountryCodeWarning = true;
    });
  }

  void _clearCountryCodeWarningMessage() {
    if (!_showCountryCodeWarning) {
      return;
    }

    setState(() {
      _showCountryCodeWarning = false;
    });
  }
}
