import 'package:flutter/widgets.dart';

/// Makes country names visible in selectors above the phone field.
class SelectorLayout extends InheritedWidget {
  const SelectorLayout({super.key, required super.child});

  static bool showCountryNameOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SelectorLayout>() != null;

  @override
  bool updateShouldNotify(SelectorLayout oldWidget) => false;
}
