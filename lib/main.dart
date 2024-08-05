import 'package:chatbot/backend/saving_data.dart';
import 'package:chatbot/bloc/bloc.dart';
import 'package:chatbot/pages/homepage_1.dart';
import 'package:chatbot/pages/login.dart';
import 'package:chatbot/system/auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:hive_flutter/adapters.dart';

const APIKEY = 'AIzaSyCn4ex8bLcDOx0rMcCTbiDa4BZRzA_98vE';

void main() async {

  await Hive.initFlutter();
  await EasyLocalization.ensureInitialized();
  await Hive.openBox(boxName);
  await Hive.openBox(userData);

  Gemini.init(apiKey: APIKEY);

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('hi', 'IN')],
      path: 'assets/translations', // Path to the translation files
      fallbackLocale: Locale('en', 'US'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MessageBloc(),
        child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            home: (boxUser.isEmpty || !boxUser.get('islogin'))
                ? Login()
                : HomePage()));
  }
}
