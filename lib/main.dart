import 'package:app/DashboardPage.dart';
import 'package:app/phone.dart';
import 'package:app/splash.dart';
import 'package:flutter/material.dart';

import 'injection/dependency_injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
}

Future setupLocator() async {
  await Injector.getInstance();
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plases Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Injector.user!=null?DashboardPage():PhoneScreen(),
    );
  }
}

