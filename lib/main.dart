import 'package:app/screens/dashboard.dart';
import 'package:app/screens/phone.dart';
import 'package:app/screens/signup.dart';
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
      routes: <String, WidgetBuilder>{
        '/signup': (BuildContext context) => SignUpScreen(),
        '/dashboard': (BuildContext context) => DashboardPage(),
      },
      // check if user is logged in the it will navigate to DashboardPage otherwise Phone authentication page
      home: Injector.user!=null?DashboardPage():PhoneScreen(),
    );
  }
}

