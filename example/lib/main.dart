import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var darkTheme = ThemeData.dark().copyWith(primaryColor: Colors.blue);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo',
      themeMode: ThemeMode.light,
      darkTheme: darkTheme,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Demo')),
        body: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final LabeledGlobalKey<FormState> formKey =
      LabeledGlobalKey<FormState>("phoneform");
  int count = 0;
  final TextEditingController controller = TextEditingController();
  PhoneNumber number = const PhoneNumber(isoCode: IsoCode.NG, nsn: "");

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InternationalPhoneNumberInput(
                label: const Text("Customer Phone Number"),
                errorMessage: "Wrong Input entered",
                selectorButtonBottomWidget: Container(
                  color: Colors.white,
                  height: 1,
                  width: 120,
                ),
                locale: "gu",
                betweenTextFieldWidget: const Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                onInputChanged: (PhoneNumber number) {
                  debugPrint(number.international);
                },
                selectorConfig: const SelectorConfig(
                  leadingPadding: 3,
                  trailingSpace: true,
                  setSelectorButtonAsPrefixIcon: true,
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.always,
                selectorTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 10),
                initialValue: number,
                textFieldController: controller,
                formatInput: true,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputBorder: const OutlineInputBorder(),
                onSaved: (PhoneNumber number) {
                  debugPrint('On Saved: $number');
                },
                inputDecoration:
                    const InputDecoration(labelStyle: TextStyle(fontSize: 13)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    debugPrint("validated");
                  } else {
                    debugPrint("An error");
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
              ElevatedButton(
                onPressed: () {
                  formKey.currentState?.save();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getPhoneNumber(String phoneNumber) {
    PhoneNumber number = PhoneNumber.parse(phoneNumber);

    setState(() {
      this.number = number;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
