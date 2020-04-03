import 'dart:io';

import 'package:app/screens/phone.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import '../helper/color_res.dart';
import '../injection/dependency_injection.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isUserLogin = true;
  int delay = 0;

  @override
  void initState() {
    super.initState();

    isUserLogin = Injector.user != null;

    navigateToNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            color: ColorRes.colorPrimary,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image(
                image: AssetImage('assets/images/splash_bottom.png'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Image(
              image: AssetImage('assets/images/logo.png'),
              height: 100.0,
            ),
          )
        ],
      ),
    );
  }

  void navigateToNext() {
    if (isUserLogin != null && isUserLogin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardPage(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PhoneScreen(),
        ),
      );
    }
  }
}
