import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MaterialInputWidgetView extends StatelessWidget {
  final Widget? selectorSection;
  final double selectorSpacing;
  final TextDirection textDirection;
  final Key? fieldKey;
  final TextEditingController controller;
  final VoidCallback? onTap;
  final Color? cursorColor;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final TextStyle? textStyle;
  final InputDecoration decoration;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode autovalidateMode;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final EdgeInsets scrollPadding;
  final List<TextInputFormatter> inputFormatters;

  const MaterialInputWidgetView({
    super.key,
    this.selectorSection,
    required this.selectorSpacing,
    required this.textDirection,
    this.fieldKey,
    required this.controller,
    this.onTap,
    this.cursorColor,
    this.focusNode,
    required this.enabled,
    required this.autofocus,
    required this.keyboardType,
    this.textInputAction,
    this.textStyle,
    required this.decoration,
    required this.textAlign,
    required this.textAlignVertical,
    this.onEditingComplete,
    this.onFieldSubmitted,
    required this.autovalidateMode,
    this.autofillHints,
    this.validator,
    this.onSaved,
    required this.scrollPadding,
    required this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (selectorSection != null) ...[
          selectorSection!,
          SizedBox(width: selectorSpacing),
        ],
        Flexible(
          child: TextFormField(
            textDirection: textDirection,
            key: fieldKey,
            controller: controller,
            onTap: onTap,
            cursorColor: cursorColor,
            focusNode: focusNode,
            enabled: enabled,
            autofocus: autofocus,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: textStyle,
            decoration: decoration,
            textAlign: textAlign,
            textAlignVertical: textAlignVertical,
            onEditingComplete: onEditingComplete,
            onFieldSubmitted: onFieldSubmitted,
            autovalidateMode: autovalidateMode,
            autofillHints: autofillHints,
            validator: validator,
            onSaved: onSaved,
            scrollPadding: scrollPadding,
            inputFormatters: inputFormatters,
          ),
        ),
      ],
    );
  }
}
