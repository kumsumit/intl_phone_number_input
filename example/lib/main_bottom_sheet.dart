import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

void main() => runApp(const MyBottomSheetApp());

class MyBottomSheetApp extends StatelessWidget {
  const MyBottomSheetApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(title: const Text('Demo')), body: const MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'NG';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InternationalPhoneNumberInput(
            locale: 'hi',
            onInputChanged: (PhoneNumber number) {
              debugPrint(number.phoneNumber);
            },
            onInputValidated: (bool value) {
              debugPrint(value.toString());
            },
            ignoreBlank: true,
            autoValidateMode: AutovalidateMode.disabled,
            initialValue: PhoneNumber(isoCode: 'NG'),
            textFieldController: controller,
            inputBorder: const OutlineInputBorder(),
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState != null) {
                formKey.currentState!.validate();
              }
            },
            child: const Text('Validate'),
          ),
          ElevatedButton(
            onPressed: () {
              getPhoneNumber('+15417543010');
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'US');

    String parsableNumber = await PhoneNumber.getParsableNumber(number);
    controller.text = parsableNumber;

    setState(() {
      initialCountry = number.isoCode ?? "IN";
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
