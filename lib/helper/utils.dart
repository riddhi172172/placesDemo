
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {


  static double getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double keyboardClose(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static double getDeviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static getAssetsImg(String name) {
    return "assets/images/" + name + ".png";
  }

  static showToast(String message) {
//    _scaffoldKey.currentState.showSnackBar(SnackBar(
//      content: Text(message),
//      duration: const Duration(milliseconds: 2000),
//    ));

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 3,
        backgroundColor: Colors.black87,
        textColor: Colors.white);
  }

  static Future<bool> isInternetConnectedWithAlert() async {
    bool isConnected = false;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      isConnected = true;
    } else {
      showToast("Please check your internet connectivity.");
      isConnected = false;
    }
    return isConnected;
  }

  static String getText(BuildContext context, String text) {
//    return AppLocalizations.of(context).text(text) ?? text;
  return text;
  }

  static Future<bool> isInternetConnected() async {
    bool isConnected = false;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      isConnected = true;
    } else {
      isConnected = false;
    }
    return isConnected;
  }


  static showSnackBar(GlobalKey<ScaffoldState> _scaffoldKey, String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
