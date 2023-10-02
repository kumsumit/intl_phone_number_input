import 'package:flutter_test/flutter_test.dart';
import 'package:intl_phone_number_input/src/utils/formatter/as_you_type_formatter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("AsYouTypeFormatter Test", () {
    test("Assert Test AsYouTypeFormatter", () {
      expect(() {
        AsYouTypeFormatter(
          isoCode: "",
          dialCode: "",
          onInputFormatted: (_) {},
          maxLength: 15
        );
      }, throwsAssertionError);
      expect(() {
        AsYouTypeFormatter(
          isoCode: "",
          dialCode: "",
          onInputFormatted: (_) {},
          maxLength: 15
        );
      }, throwsAssertionError);
    });
  });
}
