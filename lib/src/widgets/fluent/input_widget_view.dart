import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

class FluentInputWidgetView extends StatelessWidget {
  static const double _stackedLayoutBreakpoint = 650;

  final Widget? selectorSection;
  final double selectorSpacing;
  final String label;
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
  final String? placeholder;
  final Widget? prefix;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode autovalidateMode;
  final String? Function(String?)? validator;
  final FormFieldSetter<String>? onSaved;
  final EdgeInsets scrollPadding;
  final List<TextInputFormatter> inputFormatters;
  final String? errorText;
  final String counterText;
  final TextDirection textDirection;
  final Iterable<String>? autofillHints;

  const FluentInputWidgetView({
    super.key,
    this.selectorSection,
    required this.selectorSpacing,
    required this.label,
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
    this.placeholder,
    this.prefix,
    required this.textAlign,
    required this.textAlignVertical,
    this.onEditingComplete,
    this.onFieldSubmitted,
    required this.autovalidateMode,
    this.validator,
    this.onSaved,
    required this.scrollPadding,
    required this.inputFormatters,
    this.errorText,
    required this.counterText,
    required this.textDirection,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    // Using InfoLabel to handle the header correctly
    final field = InfoLabel(
      label: label,
      child: TextFormBox(
        key: fieldKey,
        controller: controller,
        placeholder: placeholder,
        prefix: prefix,
        onTap: onTap,
        cursorColor: cursorColor,
        focusNode: focusNode,
        enabled: enabled,
        autofocus: autofocus,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: textStyle ?? theme.typography.body,
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onFieldSubmitted,
        autovalidateMode: autovalidateMode,
        validator: validator,
        onSaved: onSaved,
        scrollPadding: scrollPadding,
        inputFormatters: inputFormatters,
        autofillHints: autofillHints,
        suffix: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: Text(
            counterText,
            style: theme.typography.caption?.copyWith(
              color: theme.resources.textFillColorDisabled,
            ),
          ),
        ),
      ),
    );

    final directedField = Directionality(
      textDirection: textDirection,
      child: field,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final stackedLayoutBreakpoint = _stackedLayoutBreakpoint * textScale;
        final shouldStack =
            selectorSection != null &&
            constraints.maxWidth < stackedLayoutBreakpoint;

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: selectorSection!,
              ),
              SizedBox(height: selectorSpacing),
              directedField,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (selectorSection != null) ...[
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: selectorSection!,
              ),
              SizedBox(width: selectorSpacing),
            ],
            Flexible(child: directedField),
          ],
        );
      },
    );
  }
}
