import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CupertinoInputWidgetView extends StatelessWidget {
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

  const CupertinoInputWidgetView({
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
    final theme = CupertinoTheme.of(context);
    final field = FormField<String>(
      key: fieldKey,
      initialValue: controller.text,
      autovalidateMode: autovalidateMode,
      validator: validator,
      onSaved: onSaved,
      builder: (fieldState) {
        final resolvedErrorText = fieldState.errorText ?? errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              DefaultTextStyle(style: theme.textTheme.textStyle, child: label!),
              const SizedBox(height: 8),
            ],
            CupertinoTextField(
              controller: controller,
              onTap: onTap,
              cursorColor: cursorColor,
              focusNode: focusNode,
              enabled: enabled,
              autofocus: autofocus,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              style: textStyle,
              placeholder: placeholder,
              prefix: prefix,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              onEditingComplete: onEditingComplete,
              onSubmitted: onFieldSubmitted,
              scrollPadding: scrollPadding,
              inputFormatters: inputFormatters,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemBackground.resolveFrom(
                  context,
                ),
                border: Border.all(
                  color: resolvedErrorText == null
                      ? CupertinoColors.separator.resolveFrom(context)
                      : CupertinoColors.systemRed.resolveFrom(context),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              autofillHints: autofillHints,
              onChanged: fieldState.didChange,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: resolvedErrorText == null
                      ? const SizedBox.shrink()
                      : Text(
                          resolvedErrorText,
                          style: theme.textTheme.textStyle.copyWith(
                            color: CupertinoColors.systemRed.resolveFrom(
                              context,
                            ),
                            fontSize: 12,
                          ),
                        ),
                ),
                Text(counterText, style: theme.textTheme.tabLabelTextStyle),
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
