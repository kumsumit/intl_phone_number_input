import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
// import 'package:intl_phone_number_input/src/models/country_list.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
// import 'package:intl_phone_number_input/src/providers/country_provider.dart';
import 'package:intl_phone_number_input/src/utils/formatter/as_you_type_formatter.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/widgets/selector_button.dart';
import 'package:phone_parser/phone_parser.dart';

/// Enum for [SelectorButton] types.
///
/// Available type includes:
///   * [PhoneInputSelectorType.DROPDOWN]
///   * [PhoneInputSelectorType.BOTTOM_SHEET]
///   * [PhoneInputSelectorType.DIALOG]
enum PhoneInputSelectorType { DROPDOWN, BOTTOM_SHEET, DIALOG }

/// A [TextFormField] for [InternationalPhoneNumberInput].
///
/// [initialValue] accepts a [PhoneNumber] this is used to set initial values
/// for phone the input field and the selector button
///
/// [selectorButtonOnErrorPadding] is a double which is used to align the selector
/// button with the input field when an error occurs
///
/// [countries] accepts list of string on Country isoCode, if specified filters
/// available countries to match the [countries] specified.
class InternationalPhoneNumberInput extends StatefulWidget {
  final SelectorConfig selectorConfig;
  final List<Country> countries;
  final Country defaultCountry;
  final List<Country> Function(String value) filterFunction;

  final ValueChanged<PhoneNumber>? onInputChanged;
  final ValueChanged<bool>? onInputValidated;

  final VoidCallback? onSubmit;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final ValueChanged<PhoneNumber>? onSaved;

  final Key? fieldKey;
  final TextEditingController? textFieldController;
  final TextInputType keyboardType;
  final TextInputAction? keyboardAction;

  final PhoneNumber? initialValue;
  final String? hintText;
  final Widget? label;
  final String? errorMessage;

  final double selectorButtonOnErrorPadding;

  /// Ignored if [setSelectorButtonAsPrefixIcon = true]
  final double spaceBetweenSelectorAndTextField;
  final Widget? selectorButtonBottomWidget;
  final Widget? betweenTextFieldWidget;
  // final int maxLength;

  final bool isEnabled;
  final bool formatInput;
  final bool autoFocus;
  final bool autoFocusSearch;
  final AutovalidateMode autoValidateMode;
  final bool ignoreBlank;
  final bool countrySelectorScrollControlled;

  final TextDirection textDirection;
  final TextStyle? textStyle;
  final TextStyle? selectorTextStyle;
  final TextStyle? flagStyle;
  final InputBorder? inputBorder;
  final InputDecoration? inputDecoration;
  final InputDecoration? searchBoxDecoration;
  final Color? cursorColor;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final EdgeInsets scrollPadding;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final double flagSize;

  /// Disable view Min/Max Length check
  final bool disableLengthCheck;

  InternationalPhoneNumberInput({
    super.key,
    required this.countries,
    required this.defaultCountry,
    required this.filterFunction,
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
    this.hintText = 'Phone number',
    this.errorMessage = 'Invalid phone number',
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
    this.inputBorder,
    this.inputDecoration,
    this.searchBoxDecoration,
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
  State<StatefulWidget> createState() => InputWidgetState();
}

class InputWidgetState extends State<InternationalPhoneNumberInput> {
  late TextEditingController controller;
  bool _ownsController = false;
  double selectorButtonBottomPadding = 0;
  int currentLength = 0;
  List<int> acceptedLengths = [];
  late Country country;
  List<Country> countries = [];
  bool isNotValid = true;
  String errorText = "";

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    country = widget.defaultCountry;
    countries = widget.countries;
    _attachController(widget.textFieldController);
    acceptedLengths = _acceptedLengthsFor(widget.initialValue?.isoCode);
    initialiseWidget();
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
    errorText = validator(controller.text) ?? "";
    selectorButtonBottomPadding = errorText.isEmpty
        ? widget.selectorButtonOnErrorPadding
        : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (!widget.selectorConfig.setSelectorButtonAsPrefixIcon) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectorButton(
                    country: country,
                    countries: countries,
                    onCountryChanged: onCountryChanged,
                    selectorConfig: widget.selectorConfig,
                    selectorTextStyle: widget.selectorTextStyle,
                    flagStyle: widget.flagStyle,
                    searchBoxDecoration: widget.searchBoxDecoration,
                    isEnabled: widget.isEnabled,
                    autoFocusSearchField: widget.autoFocusSearch,
                    isScrollControlled: widget.countrySelectorScrollControlled,
                    flagSize: widget.flagSize,
                    filterFunction: widget.filterFunction,
                  ),
                  if (widget.betweenTextFieldWidget != null)
                    widget.betweenTextFieldWidget!,
                ],
              ),
              SizedBox(height: selectorButtonBottomPadding),
              if (widget.selectorButtonBottomWidget != null)
                widget.selectorButtonBottomWidget!,
            ],
          ),
          SizedBox(width: widget.spaceBetweenSelectorAndTextField),
        ],
        Flexible(
          child: TextFormField(
            textDirection: widget.textDirection,
            key: widget.fieldKey,
            controller: controller,
            onTap: widget.onTap,
            cursorColor: widget.cursorColor,
            focusNode: widget.focusNode,
            enabled: widget.isEnabled,
            autofocus: widget.autoFocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.keyboardAction,
            style: widget.textStyle,
            decoration: getInputDecoration(widget.inputDecoration),
            textAlign: widget.textAlign,
            textAlignVertical: widget.textAlignVertical,
            onEditingComplete: widget.onSubmit,
            onFieldSubmitted: widget.onFieldSubmitted,
            autovalidateMode: widget.autoValidateMode,
            autofillHints: widget.autofillHints,
            validator: widget.validator ?? validator,
            onSaved: onSaved,
            scrollPadding: widget.scrollPadding,
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
              FilteringTextInputFormatter.allow(
                RegExp(
                  '[${Patterns.plus}${Patterns.digits}${Patterns.punctuation}]',
                ),
              ),
              widget.formatInput
                  ? AsYouTypeFormatter(
                      isoCode: country.alpha2Code,
                      dialCode: country.dialCode,
                      onInputFormatted: (TextEditingValue value) {
                        controller.value = value;
                      },
                      acceptedLengths:
                          widget.disableLengthCheck ? const [] : acceptedLengths,
                    )
                  : FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
      ],
    );

  }

  @override
  void didUpdateWidget(covariant InternationalPhoneNumberInput oldWidget) {
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
    final defaultCountryChanged = oldWidget.defaultCountry != widget.defaultCountry;
    final initialValueChanged = oldWidget.initialValue != widget.initialValue;
    final formatChanged = oldWidget.formatInput != widget.formatInput;

    if (!countriesChanged &&
        !defaultCountryChanged &&
        !initialValueChanged &&
        !formatChanged) {
      return;
    }

    final nextCountries = widget.countries;
    final nextCountry = _resolveCountryForUpdate(nextCountries);

    setState(() {
      countries = nextCountries;
      country = nextCountry;
      acceptedLengths = _acceptedLengthsFor(nextCountry.alpha2Code);
    });

    if (initialValueChanged || formatChanged) {
      initialiseWidget();
    } else {
      phoneNumberControllerListener();
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
    try {
      final lengths = MetadataFinder.findMetadataLengthForIsoCode(
        isoCode ?? country.alpha2Code,
      );
      return lengths["mobile"] ?? [];
    } catch (_) {
      return [];
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
      widget.onInputValidated?.call(isValidWhenBlank);
      setState(() {
        currentLength = 0;
        isNotValid = !isValidWhenBlank;
        errorText = validator(controller.text) ?? "";
      });
      return;
    }

    String parsedPhoneNumberString = controller.text.replaceAll(
      RegExp(r'[^\d+]'),
      '',
    );

    late final PhoneNumber phoneNumber;
    try {
      phoneNumber = PhoneNumber.parse(
        parsedPhoneNumberString,
        destinationCountry: country.alpha2Code,
      );
    } catch (_) {
      widget.onInputValidated?.call(false);
      setState(() {
        currentLength = parsedPhoneNumberString.replaceAll('+', '').length;
        isNotValid = true;
        errorText = validator(controller.text) ?? "";
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
      errorText = validator(controller.text) ?? "";
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

  /// Creates or Select [InputDecoration]
  InputDecoration getInputDecoration(InputDecoration? decoration) {
    InputDecoration value = (decoration != null
        ? decoration.copyWith(
            counterText: formatAcceptedLengths(acceptedLengths, currentLength),
          )
        : InputDecoration(
            label: widget.label,
            counterText: formatAcceptedLengths(acceptedLengths, currentLength),
            border: widget.inputBorder ?? const UnderlineInputBorder(),
            hintText: widget.hintText,
          ));

    if (widget.selectorConfig.setSelectorButtonAsPrefixIcon) {
      return value.copyWith(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SelectorButton(
            country: country,
            countries: countries,
            onCountryChanged: onCountryChanged,
            selectorConfig: widget.selectorConfig,
            selectorTextStyle: widget.selectorTextStyle,
            flagStyle: widget.flagStyle,
            searchBoxDecoration: widget.searchBoxDecoration,
            isEnabled: widget.isEnabled,
            autoFocusSearchField: widget.autoFocusSearch,
            isScrollControlled: widget.countrySelectorScrollControlled,
            flagSize: widget.flagSize,
            filterFunction: widget.filterFunction,
          ),
        ),
      );
    }

    return value;
  }

  /// Validate and returns a validation error when [FormState] validate is called.
  ///

  String? validator(String? value) {
    // debugPrint("Validator called with: $value");
    final bool hasContent = value?.isNotEmpty ?? false;
    final bool shouldValidateBlank = !widget.ignoreBlank;
    final bool isInvalid =
        isNotValid && (hasContent || shouldValidateBlank);
    try {
      final isParsed = PhoneNumber.parse(
        value ?? "",
        callerCountry: country.alpha2Code,
      );
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
    setState(() {
      this.country = country;
      acceptedLengths = _acceptedLengthsFor(country.alpha2Code);
    });
    phoneNumberControllerListener();
  }

  void _phoneNumberSaved() {
    if (mounted) {
      String parsedPhoneNumberString = controller.text.replaceAll(
        RegExp(r'[^\d+]'),
        '',
      );

      String phoneNumber = '${country.dialCode}$parsedPhoneNumberString';

      widget.onSaved?.call(
        PhoneNumber.parse(phoneNumber, callerCountry: country.alpha2Code),
      );
    }
  }

  /// Saved the phone number when form is saved
  void onSaved(String? value) {
    _phoneNumberSaved();
  }
}
