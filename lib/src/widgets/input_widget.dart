import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:intl_phone_number_input/src/models/country_list.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
// import 'package:intl_phone_number_input/src/providers/country_provider.dart';
import 'package:intl_phone_number_input/src/utils/formatter/as_you_type_formatter.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/utils/widget_view.dart';
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
    Key? key,
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
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => InputWidgetState();
}

class InputWidgetState extends State<InternationalPhoneNumberInput> {
  late TextEditingController controller;
  double selectorButtonBottomPadding = 0;
  int currentLength = 0;
  List<int> acceptedLengths = [];
  late Country country;
  List<Country> countries = [];
  bool isNotValid = true;
  String errorText = "";

  @override
  void dispose() {
    controller.removeListener(phoneNumberControllerListener);
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // loadCountries();
    country = widget.defaultCountry;
    countries = widget.countries;
    controller = widget.textFieldController ?? TextEditingController();
    initialiseWidget();
    controller.addListener(phoneNumberControllerListener);
    setState(() {
      if (widget.initialValue != null) {
        if (MetadataFinder.findMetadataLengthForIsoCode(
          widget.initialValue!.isoCode,
        ).isNotEmpty) {
          this.acceptedLengths =
              MetadataFinder.findMetadataLengthForIsoCode(
                widget.initialValue!.isoCode,
              )["mobile"] ??
              [];
        }
      }
    });
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      // debugPrint("Main setState");
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    errorText = validator(controller.text) ?? "";
    this.selectorButtonBottomPadding = errorText.isEmpty
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
                      acceptedLengths: acceptedLengths,
                    )
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );

    // return _InputWidgetView(
    //   state: this,
    // );
  }

  // @override
  // void didUpdateWidget(InternationalPhoneNumberInput oldWidget) {
  //   if (oldWidget.initialValue != widget.initialValue) {
  //     if (country.alpha2Code != widget.initialValue?.isoCode) {
  //       // loadCountries();
  //     }
  //     initialiseWidget();
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

  /// [initialiseWidget] sets initial values of the widget
  void initialiseWidget() {
    if (widget.initialValue != null &&
        widget.initialValue!.nsn.isNotEmpty &&
        widget.initialValue!.isValid()) {
      String phoneNumber = widget.initialValue!.formatNsn(
        isoCode: widget.initialValue?.isoCode,
      );

      controller.text = widget.formatInput
          ? phoneNumber
          : phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      phoneNumberControllerListener();
    }
  }

  // /// loads countries from [Countries.countryList] and selected Country
  void loadCountries({Country? previouslySelectedCountry}) {
    if (this.mounted) {
      // List<Country> countries = CountryProvider.getCountriesData(
      //   countries: widget.countries,
      // );

      Country country =
          previouslySelectedCountry ??
          Utils.getInitialSelectedCountry(
            countries,
            widget.initialValue?.isoCode ?? 'IN',
          );
      // Remove potential duplicates
      countries = countries.toSet().toList();

      final CountryComparator countryComparator =
          widget.selectorConfig.countryComparator ??
          (a, b) {
            return a.name.compareTo(b.name);
          };
      countries.sort(countryComparator);
      setState(() {
        // debugPrint("Countries setState");
        this.countries = countries;
        this.country = country;
      });
    }
  }

  /// Listener that validates changes from the widget, returns a bool to
  /// the `ValueCallback` [widget.onInputValidated]
  void phoneNumberControllerListener() {
    if (this.mounted && controller.text.isNotEmpty) {
      String parsedPhoneNumberString = controller.text.replaceAll(
        RegExp(r'[^\d+]'),
        '',
      );
      // String normalizedPhoneNumber =
      //     '${this.country.dialCode}$parsedPhoneNumberString';

      final phoneNumber = PhoneNumber.parse(
        parsedPhoneNumberString,
        destinationCountry: this.country.alpha2Code,
      );
      if (phoneNumber.nsn.isEmpty || !phoneNumber.isValid()) {
        if (widget.onInputValidated != null) {
          widget.onInputValidated!(false);
        }
        this.isNotValid = true;
      } else {
        if (widget.onInputValidated != null) {
          widget.onInputValidated!(true);
        }
        this.isNotValid = false;
      }
      setState(() {
        currentLength = phoneNumber.nsn.length;
        errorText = validator(controller.text) ?? "";
      });
      if (widget.onInputChanged != null) {
        widget.onInputChanged!(phoneNumber);
      }
    }
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

  /// Validate the phone number when a change occurs
  void onChanged(String value) {
    phoneNumberControllerListener();
  }

  /// Validate and returns a validation error when [FormState] validate is called.
  ///

  String? validator(String? value) {
    // debugPrint("Validator called with: $value");
    final bool hasContent = value?.isNotEmpty ?? false;
    final bool shouldValidateBlank = !widget.ignoreBlank;
    final bool isInvalid =
        this.isNotValid && (hasContent || shouldValidateBlank);
    final isParsed = PhoneNumber.parse(
      value ?? "",
      callerCountry: country.alpha2Code,
    );
    if (isParsed.isValid()) {
      return null;
    }
    return isInvalid ? widget.errorMessage : null;
  }

  /// Changes Selector Button Country and Validate Change.
  void onCountryChanged(Country country) {
    setState(() {
      this.country = country;
      this.acceptedLengths =
          MetadataFinder.findMetadataLengthForIsoCode(
            country.alpha2Code,
          )["mobile"] ??
          [];
    });
    phoneNumberControllerListener();
  }

  void _phoneNumberSaved() {
    if (this.mounted) {
      String parsedPhoneNumberString = controller.text.replaceAll(
        RegExp(r'[^\d+]'),
        '',
      );

      String phoneNumber = '${this.country.dialCode}' + parsedPhoneNumberString;

      widget.onSaved?.call(
        PhoneNumber.parse(phoneNumber, callerCountry: this.country.alpha2Code),
      );
    }
  }

  /// Saved the phone number when form is saved
  void onSaved(String? value) {
    _phoneNumberSaved();
  }
}

class InputWidgetView
    extends WidgetView<InternationalPhoneNumberInput, InputWidgetState> {
  final InputWidgetState state;

  InputWidgetView({Key? key, required this.state})
    : super(key: key, state: state);

  @override
  Widget build(BuildContext context) {
    final countryCode = state.country.alpha2Code;
    final dialCode = state.country.dialCode;
    final acceptedLengths = state.acceptedLengths;

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
                    country: state.country,
                    countries: state.countries,
                    onCountryChanged: state.onCountryChanged,
                    selectorConfig: widget.selectorConfig,
                    selectorTextStyle: widget.selectorTextStyle,
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
              SizedBox(height: state.selectorButtonBottomPadding),
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
            controller: state.controller,
            cursorColor: widget.cursorColor,
            focusNode: widget.focusNode,
            enabled: widget.isEnabled,
            autofocus: widget.autoFocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.keyboardAction,
            style: widget.textStyle,
            decoration: state.getInputDecoration(widget.inputDecoration),
            textAlign: widget.textAlign,
            textAlignVertical: widget.textAlignVertical,
            onEditingComplete: widget.onSubmit,
            onFieldSubmitted: widget.onFieldSubmitted,
            autovalidateMode: widget.autoValidateMode,
            autofillHints: widget.autofillHints,
            validator: widget.validator ?? state.validator,
            onSaved: state.onSaved,
            scrollPadding: widget.scrollPadding,
            inputFormatters: [
              // LengthLimitingTextInputFormatter(
              //     // widget.maxLength
              //     state.maxLength),
              FilteringTextInputFormatter.allow(
                RegExp(
                  '[${Patterns.plus}${Patterns.digits}${Patterns.punctuation}]',
                ),
              ),
              widget.formatInput
                  ? AsYouTypeFormatter(
                      isoCode: countryCode,
                      dialCode: dialCode,
                      onInputFormatted: (TextEditingValue value) {
                        state.controller.value = value;
                      },
                      acceptedLengths: acceptedLengths,
                    )
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: state.onChanged,
          ),
        ),
      ],
    );
  }
}
