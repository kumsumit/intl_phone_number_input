import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosInputWidgetView extends StatelessWidget {
  final Widget? selectorSection;
  final double selectorSpacing;
  final Widget? label;
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

  const MacosInputWidgetView({
    super.key,
    this.selectorSection,
    required this.selectorSpacing,
    this.label,
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
    final theme = MacosTheme.of(context);
    final field = FormField<String>(
      key: fieldKey,
      initialValue: controller.text,
      autovalidateMode: autovalidateMode,
      validator: validator,
      onSaved: onSaved,
      builder: (fieldState) {
        final resolvedErrorText = fieldState.errorText ?? errorText;
        final BoxDecoration decoration = BoxDecoration(
          color: MacosDynamicColor.resolve(
            MacosColors.controlBackgroundColor,
            context,
          ),
          border: Border.all(
            color: resolvedErrorText == null
                ? MacosDynamicColor.resolve(MacosColors.separatorColor, context)
                : MacosColors.systemRedColor,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(7.0),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              DefaultTextStyle(style: theme.typography.callout, child: label!),
              const SizedBox(height: 6),
            ],
            MacosTextField(
              controller: controller,
              onTap: onTap,
              cursorColor: cursorColor,
              focusNode: focusNode,
              enabled: enabled,
              autofocus: autofocus,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              style: textStyle ?? theme.typography.body,
              placeholder: placeholder,
              prefix: prefix,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              onEditingComplete: onEditingComplete,
              onSubmitted: onFieldSubmitted,
              scrollPadding: scrollPadding,
              inputFormatters: inputFormatters,
              padding: const EdgeInsets.all(7.0), // Standard macOS padding
              // MacosTextField handles its own native decoration/focus ring,
              // but we can color it for error states:
              focusedDecoration: decoration.copyWith(
                border: Border.all(
                  color: resolvedErrorText == null
                      ? theme.primaryColor
                      : MacosColors.systemRedColor,
                  width: 1.5,
                ),
              ),
              autofillHints: autofillHints,
              onChanged: fieldState.didChange,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: resolvedErrorText == null
                      ? const SizedBox.shrink()
                      : Text(
                          resolvedErrorText,
                          style: theme.typography.caption1.copyWith(
                            color: MacosColors.systemRedColor,
                          ),
                        ),
                ),
                Text(
                  counterText,
                   style: theme.typography.caption1.copyWith(
                     color: MacosColors.disabledControlTextColor,
                   ),
                ),
              ],
            ),
          ],
        );
      },
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (selectorSection != null) ...[
          // Using a constrained box or padding to ensure the selector
          // aligns with the macOS input height
          selectorSection!,
          SizedBox(width: selectorSpacing),
        ],
        Flexible(
          child: Directionality(textDirection: textDirection, child: field),
        ),
      ],
    );
  }
}
