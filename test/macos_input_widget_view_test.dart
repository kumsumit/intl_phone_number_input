import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/src/widgets/macos/input_widget_view.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets('dark phone field keeps hint and counter readable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MacosApp(
        theme: MacosThemeData.dark(),
        home: Center(
          child: SizedBox(
            width: 360,
            child: MacosInputWidgetView(
              selectorSpacing: 12,
              controller: TextEditingController(),
              enabled: true,
              autofocus: false,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              autovalidateMode: AutovalidateMode.disabled,
              scrollPadding: const EdgeInsets.all(20),
              inputFormatters: const [],
              counterText: '0 / 10',
              textDirection: TextDirection.ltr,
              placeholder: 'Phone number',
            ),
          ),
        ),
      ),
    );

    final textField = tester.widget<MacosTextField>(
      find.byType(MacosTextField),
    );
    expect(textField.decoration?.color, const Color(0xFF2D2F4D));
    expect(textField.placeholderStyle?.color, const Color(0xFFB7BAD5));
    expect(
      tester.widget<Text>(find.text('0 / 10')).style?.color,
      const Color(0xFFC3C6DE),
    );
  });
}
