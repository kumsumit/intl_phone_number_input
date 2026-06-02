import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/widgets/macos/selector_button.dart';
import 'package:macos_ui/macos_ui.dart';

void main() {
  testWidgets('dropdown selector uses a field-height native macOS button', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final countries = [
      Country(
        name: 'India',
        alpha2Code: 'IN',
        alpha3Code: 'IND',
        dialCode: '+91',
      ),
      Country(
        name: 'United States',
        alpha2Code: 'US',
        alpha3Code: 'USA',
        dialCode: '+1',
      ),
    ];

    await tester.pumpWidget(
      MacosApp(
        home: Center(
          child: MacosSelectorButton(
            countries: countries,
            country: countries.first,
            selectorConfig: const SelectorConfig(),
            autoFocusSearchField: false,
            onCountryChanged: (_) {},
            isEnabled: true,
            isScrollControlled: true,
            flagSize: 20,
            filterFunction: null,
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(PushButton), findsOneWidget);
    expect(
      tester.getSize(find.byType(PushButton)).height,
      greaterThanOrEqualTo(34),
    );

    await tester.tap(find.byType(PushButton));
    await tester.pumpAndSettle();

    expect(find.text('Select country or region'), findsOneWidget);
    expect(
      tester
          .widget<MacosSearchField>(find.byType(MacosSearchField))
          .placeholder,
      'Search country or calling code',
    );
  });
}
