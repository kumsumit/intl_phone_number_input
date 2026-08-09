import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosInputWidgetView extends StatelessWidget {
  static const double _stackedLayoutBreakpoint = 700;

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
    final isDark = theme.brightness == Brightness.dark;
    final field = FormField<String>(
      key: fieldKey,
      initialValue: controller.text,
      autovalidateMode: autovalidateMode,
      validator: validator,
      onSaved: onSaved,
      builder: (fieldState) {
        final resolvedErrorText = fieldState.errorText ?? errorText;
        final fieldBackground = isDark
            ? const Color(0xFF2D2F4D)
            : MacosDynamicColor.resolve(
                MacosColors.controlBackgroundColor,
                context,
              );
        final fieldBorder = isDark
            ? const Color(0xFF696D99)
            : MacosDynamicColor.resolve(MacosColors.separatorColor, context);
        final inputStyle = (textStyle ?? theme.typography.body).copyWith(
          color: isDark ? const Color(0xFFF4F4FF) : null,
        );
        final placeholderStyle = inputStyle.copyWith(
          color: isDark ? const Color(0xFFB7BAD5) : const Color(0xFF737473),
          fontWeight: FontWeight.w400,
        );
        final counterStyle = theme.typography.caption1.copyWith(
          color: isDark ? const Color(0xFFC3C6DE) : const Color(0xFF6C6D76),
          fontWeight: FontWeight.w500,
        );
        final BoxDecoration decoration = BoxDecoration(
          color: fieldBackground,
          border: Border.all(
            color: resolvedErrorText == null
                ? fieldBorder
                : MacosColors.systemRedColor,
            width: isDark ? 0.8 : 0.5,
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
              style: inputStyle,
              placeholder: placeholder,
              placeholderStyle: placeholderStyle,
              prefix: prefix,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              onEditingComplete: onEditingComplete,
              onSubmitted: onFieldSubmitted,
              scrollPadding: scrollPadding,
              inputFormatters: inputFormatters,
              padding: const EdgeInsets.all(7.0), // Standard macOS padding
              decoration: decoration,
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
                Text(counterText, style: counterStyle),
              ],
            ),
          ],
        );
      },
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
              selectorSection!,
              SizedBox(width: selectorSpacing),
            ],
            Flexible(child: directedField),
          ],
        );
      },
    );
  }
}
