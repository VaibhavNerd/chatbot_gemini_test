import 'package:chatbot/pages/homepage_1.dart';
import 'package:chatbot/system/auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';

import '../backend/saving_data.dart';
import '../component/component.dart'; // Import EasyLocalization

class Login extends StatelessWidget {
  Login({super.key});
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textEditingController1 = TextEditingController();
  var output;
  var box = Hive.box(boxName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( backgroundColor:  const Color.fromARGB(255, 53, 53, 53),
        title: Text('appTitle'.tr()), // Access localized string
        actions: [
          InkWell(
            onTap: () {
              Locale currentLocale = context.locale;
              Locale newLocale = currentLocale == Locale('hi', 'IN')
                  ? Locale('en', 'US')
                  : Locale('hi', 'IN');
              context.setLocale(newLocale);
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Text(
                context.locale == const Locale('hi', 'IN') ? "ENG" : "HIN",
                style: const TextStyle(color: Colors.white),
              ), // Adjust the color as needed
            ),
          ),
          SizedBox(width: 10), // Add some spacing between the icon and edge
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 53, 53, 53),
      body: ListView(children: [
        Container(
            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 100),
            padding: const EdgeInsets.fromLTRB(0, 60, 0, 4),
            child: Image.asset('./assets/gemini.png')),
        Center(
            child: Text(
              'appTitle'.tr(), // Access localized string
              style: TextStyle(
                  color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
            )),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Textfield(
            text: 'enterFirstName'.tr(), // Access localized string
            controller: textEditingController,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Textfield(
            text: 'enterSecondName'.tr(), // Access localized string
            controller: textEditingController1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Butt(
            text: 'enterButton'.tr(), // Access localized string
            onpressed: () {
              if (textEditingController.text.isNotEmpty &&
                  textEditingController1.text.isNotEmpty) {
                savingUser(textEditingController.text.trim(),
                    textEditingController1.text.trim());
                boxUser.put('islogin', true);
                pushing(context);
                textEditingController.clear();
                textEditingController1.clear();
              }
            },
          ),
        ),
      ]),
    );
  }
}

pushing(context) {
  final route = MaterialPageRoute(builder: (builder) => HomePage());
  Navigator.pushAndRemoveUntil(context, route, (route) => false);
}
