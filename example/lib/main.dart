import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
        appBar: AppBar(title: Text('Demo')),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  int count = 0;
  final TextEditingController controller = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'NG');

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
                errorMessage: "Wrong Input entered",
                selectorButtonBottomWidget: Container(
                  color: Colors.white,
                  height: 1,
                  width: 120,
                ),
                betweenTextFieldWidget: Icon(
                  Icons.arrow_drop_down_sharp,
                  color: Colors.white,
                ),
                locale: "hi",
                onInputChanged: (PhoneNumber number) {
                  print(number.phoneNumber);
                },
                selectorConfig: SelectorConfig(
                  // countryComparator: (a, b) {
                  //   return a.nameTranslations!["hi"]
                  //       .toString()
                  //       .compareTo(b.nameTranslations!["hi"].toString());
                  // },
                  setSelectorButtonAsPrefixIcon: true,
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.always,
                selectorTextStyle: TextStyle(color: Colors.black),
                initialValue: number,
                textFieldController: controller,
                formatInput: true,
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputBorder: OutlineInputBorder(),
                onSaved: (PhoneNumber number) {
                  print('On Saved: $number');
                },
                // inputDecoration: InputDecoration(
                //     labelText: 'Your Name',
                //     border: const OutlineInputBorder(),
                //     // Display the number of entered characters
                //     counterText: '$count /  '),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    print("validated");
                  } else {
                    print("An error");
                  }
                },
                child: Text('Validate'),
              ),
              ElevatedButton(
                onPressed: () {
                  getPhoneNumber('+15417543010');
                },
                child: Text('Update'),
              ),
              ElevatedButton(
                onPressed: () {
                  formKey.currentState?.save();
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'US');

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
