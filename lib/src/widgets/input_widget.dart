import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/src/models/country_list.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/providers/country_provider.dart';
import 'package:intl_phone_number_input/src/utils/formatter/as_you_type_formatter.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/utils/test/test_helper.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/utils/widget_view.dart';
import 'package:intl_phone_number_input/src/widgets/selector_button.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

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
/// [locale] accepts a country locale which will be used to translation, if the
/// translation exist
///
/// [countries] accepts list of string on Country isoCode, if specified filters
/// available countries to match the [countries] specified.
class InternationalPhoneNumberInput extends StatefulWidget {
  final SelectorConfig selectorConfig;

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

  final String? locale;
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

  final List<String>? countries;
  final bool isFlagEmoji;
  final double flagSize;

  /// Disable view Min/Max Length check
  final bool disableLengthCheck;

  InternationalPhoneNumberInput({
    Key? key,
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
    this.locale,
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
    this.countries,
    this.selectorButtonBottomWidget,
    this.betweenTextFieldWidget,
    this.label,
    this.disableLengthCheck = false,
    this.flagSize = 20,
    this.isFlagEmoji = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InternationalPhoneNumberInput> {
  TextEditingController? controller;
  double selectorButtonBottomPadding = 0;
  int currentLength = 0;
  int minLength = 0;
  int maxLength = 15;
  Country? country;
  List<Country> countries = [];
  bool isNotValid = true;

  @override
  void initState() {
    super.initState();
    loadCountries();
    controller = widget.textFieldController ?? TextEditingController();
    initialiseWidget();
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    locale: locale,
                    isEnabled: widget.isEnabled,
                    autoFocusSearchField: widget.autoFocusSearch,
                    isScrollControlled: widget.countrySelectorScrollControlled,
                    flagSize: widget.flagSize,
                    isFlagEmoji: widget.isFlagEmoji,
                  ),
                  if (widget.betweenTextFieldWidget != null)
                    widget.betweenTextFieldWidget!,
                ],
              ),
              SizedBox(
                height: selectorButtonBottomPadding,
              ),
              if (widget.selectorButtonBottomWidget != null)
                widget.selectorButtonBottomWidget!
            ],
          ),
          SizedBox(width: widget.spaceBetweenSelectorAndTextField),
        ],
        Flexible(
          child: TextFormField(
            textDirection: widget.textDirection,
            key: widget.fieldKey ?? Key(TestHelper.TextInputKeyValue),
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
              // LengthLimitingTextInputFormatter(
              //   // 15
              //   maxLength
              //     // PhoneNumber(isoCode:IsoCode.IN, nsn: nsn).
              //     ),
              FilteringTextInputFormatter.allow(RegExp(
                  '[${Patterns.plus}${Patterns.digits}${Patterns.punctuation}]')),
              widget.formatInput
                  ? AsYouTypeFormatter(
                      isoCode: country?.alpha2Code ?? 'IN',
                      dialCode: country?.dialCode ?? '+91',
                      onInputFormatted: (TextEditingValue value) {
                        controller!.value = value;
                      },
                      maxLength: maxLength)
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
          ),
        )
      ],
    );

    // return _InputWidgetView(
    //   state: this,
    // );
  }

  @override
  void didUpdateWidget(InternationalPhoneNumberInput oldWidget) {
    loadCountries(previouslySelectedCountry: country);
    if (oldWidget.initialValue != widget.initialValue) {
      if (country!.alpha2Code != widget.initialValue?.isoCode.name) {
        loadCountries();
      }
      initialiseWidget();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// [initialiseWidget] sets initial values of the widget
  void initialiseWidget() {
    if (widget.initialValue != null &&
        widget.initialValue!.nsn.isNotEmpty &&
        widget.initialValue!.isValid()) {
      String phoneNumber = widget.initialValue!.getFormattedNsn();

      controller!.text = widget.formatInput
          ? phoneNumber
          : phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      phoneNumberControllerListener();
    }
  }

  /// loads countries from [Countries.countryList] and selected Country
  void loadCountries({Country? previouslySelectedCountry}) {
    if (this.mounted) {
      List<Country> countries =
          CountryProvider.getCountriesData(countries: widget.countries);

      Country country = previouslySelectedCountry ??
          Utils.getInitialSelectedCountry(
              countries, widget.initialValue?.isoCode.name ?? 'IN');
      // Remove potential duplicates
      countries = countries.toSet().toList();

      final CountryComparator countryComparator =
          widget.selectorConfig.countryComparator ??
              (a, b) {
                return a.nameTranslations![locale]
                    .toString()
                    .compareTo(b.nameTranslations![locale].toString());
              };
      countries.sort(countryComparator);
      setState(() {
        this.countries = countries;
        this.country = country;
        // maxLength = country.maxLength;
      });
    }
  }

  /// Listener that validates changes from the widget, returns a bool to
  /// the `ValueCallback` [widget.onInputValidated]
  void phoneNumberControllerListener() {
    if (this.mounted) {
      String parsedPhoneNumberString =
          controller!.text.replaceAll(RegExp(r'[^\d+]'), '');
      String normalizedPhoneNumber =
          '${this.country?.dialCode}$parsedPhoneNumberString';

      if (this.country != null && this.country!.alpha2Code != null) {
        final phoneNumber = PhoneNumber.parse(parsedPhoneNumberString,
            destinationCountry:
                this.country?.alpha2Code!.toEnum(IsoCode.values));
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
        });
        if (widget.onInputChanged != null) {
          widget.onInputChanged!(phoneNumber);
        }
      } else {
        setState(() {
          currentLength = normalizedPhoneNumber.replaceAll(" ", "").length;
        });
      }
    }
  }

  /// Creates or Select [InputDecoration]
  InputDecoration getInputDecoration(InputDecoration? decoration) {
    InputDecoration value = decoration != null
        ? decoration.copyWith(
            counterText: maxLength == minLength
                ? "$currentLength / $maxLength"
                : "$currentLength / ($minLength - $maxLength)",
          )
        : InputDecoration(
            label: widget.label,
            counterText: maxLength == minLength
                ? "$currentLength / $maxLength"
                : "$currentLength / ($minLength - $maxLength)",
            border: widget.inputBorder ?? UnderlineInputBorder(),
            hintText: widget.hintText,
          );

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
          locale: locale,
          isEnabled: widget.isEnabled,
          autoFocusSearchField: widget.autoFocusSearch,
          isScrollControlled: widget.countrySelectorScrollControlled,
          flagSize: widget.flagSize,
          isFlagEmoji: widget.isFlagEmoji,
        ),
      ));
    }

    return value;
  }

  /// Validate the phone number when a change occurs
  void onChanged(String value) {
    phoneNumberControllerListener();
  }

  /// Validate and returns a validation error when [FormState] validate is called.
  ///
  /// Also updates [selectorButtonBottomPadding]
  String? validator(String? value) {
    bool isValid =
        this.isNotValid && (value!.isNotEmpty || widget.ignoreBlank == false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (isValid && widget.errorMessage != null) {
        setState(() {
          this.selectorButtonBottomPadding =
              widget.selectorButtonOnErrorPadding;
        });
      } else {
        setState(() {
          this.selectorButtonBottomPadding = 0;
        });
      }
    });

    return isValid ? widget.errorMessage : null;
  }

  /// Changes Selector Button Country and Validate Change.
  void onCountryChanged(Country? country) {
    setState(() {
      this.country = country;
      if (country != null) {
        final minMax = MinMaxUtils.getMaxMinLengthByIsoCode(
            country.alpha2Code!.toEnum(IsoCode.values), PhoneNumberType.mobile);
        this.minLength = minMax.minLength;
        this.maxLength = minMax.maxLength;
      }
    });
    phoneNumberControllerListener();
  }

  void _phoneNumberSaved() {
    if (this.mounted) {
      String parsedPhoneNumberString =
          controller!.text.replaceAll(RegExp(r'[^\d+]'), '');

      String phoneNumber =
          '${this.country?.dialCode ?? ''}' + parsedPhoneNumberString;

      widget.onSaved?.call(
        PhoneNumber.parse(phoneNumber,
            callerCountry: this.country!.alpha2Code?.toEnum(IsoCode.values)),
      );
    }
  }

  /// Saved the phone number when form is saved
  void onSaved(String? value) {
    _phoneNumberSaved();
  }

  /// Corrects duplicate locale
  String? get locale {
    if (widget.locale == null) return "en";

    if (widget.locale!.toLowerCase() == 'nb' ||
        widget.locale!.toLowerCase() == 'nn') {
      return 'no';
    }
    return widget.locale;
  }
}

class InputWidgetView
    extends WidgetView<InternationalPhoneNumberInput, _InputWidgetState> {
  final _InputWidgetState state;

  InputWidgetView({Key? key, required this.state})
      : super(key: key, state: state);

  @override
  Widget build(BuildContext context) {
    final countryCode = state.country?.alpha2Code ?? 'IN';
    final dialCode = state.country?.dialCode ?? 'IN';
    final maxLength = state.maxLength;

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
                    locale: state.locale,
                    isEnabled: widget.isEnabled,
                    autoFocusSearchField: widget.autoFocusSearch,
                    isScrollControlled: widget.countrySelectorScrollControlled,
                    flagSize: widget.flagSize,
                    isFlagEmoji: widget.isFlagEmoji,
                  ),
                  if (widget.betweenTextFieldWidget != null)
                    widget.betweenTextFieldWidget!,
                ],
              ),
              SizedBox(
                height: state.selectorButtonBottomPadding,
              ),
              if (widget.selectorButtonBottomWidget != null)
                widget.selectorButtonBottomWidget!
            ],
          ),
          SizedBox(width: widget.spaceBetweenSelectorAndTextField),
        ],
        Flexible(
          child: TextFormField(
            textDirection: widget.textDirection,
            key: widget.fieldKey ?? Key(TestHelper.TextInputKeyValue),
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
              FilteringTextInputFormatter.allow(RegExp(
                  '[${Patterns.plus}${Patterns.digits}${Patterns.punctuation}]')),
              widget.formatInput
                  ? AsYouTypeFormatter(
                      isoCode: countryCode,
                      dialCode: dialCode,
                      onInputFormatted: (TextEditingValue value) {
                        state.controller!.value = value;
                      },
                      maxLength: maxLength)
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: state.onChanged,
          ),
        )
      ],
    );
  }
}
