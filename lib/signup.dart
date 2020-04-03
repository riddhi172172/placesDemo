import 'dart:async';
import 'dart:convert';

import 'package:app/DashboardPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

//import 'package:q_pluz_app/customview/pinview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper/color_res.dart';
import 'helper/constant.dart';
import 'helper/string_res.dart';
import 'helper/utils.dart';
import 'injection/dependency_injection.dart';
import 'model/user.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key key, this.user, this.verificationId}) : super(key: key);

  final User user;
  final String verificationId;

  @override
  SignUpScreenState createState() => new SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;

  bool _isIos;
  String _errorMessage;

  void createRecord(FirebaseUser user) async {
    widget.user.id = user.uid;

    await Injector.firestoreRef
        .collection(Const.usersCollection)
        .document(user.uid)
        .setData(widget.user.toJson())
        .then((data) {
      Injector.updateUser(widget.user);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(),
            ),
            ModalRoute.withName("/signup"));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardPage(),
        ),
      );
    });
  }

  void _signInWithPhoneNumber(String smsCode, BuildContext context) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );

    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((AuthResult authResult) async {
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(authResult.user.uid == currentUser.uid);
      print('signed in with phone number successful: user -> ' +
          authResult.user.toString());

      if (authResult.user != null) {
        createRecord(authResult.user);
      } else {
        Utils.showSnackBar(
            _scaffoldKey, Utils.getText(context, StringRes.alertSignInFailed));
      }
    }).catchError((e) {
      Utils.showSnackBar(_scaffoldKey, e.message.toString() + "");
    });
  }

  @override
  void initState() {
    super.initState();
  }

  String pin;
  TextEditingController controller = TextEditingController();

  String thisText = "";
  int pinLength = 6;

  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      key: _scaffoldKey,
//      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
                image: AssetImage('assets/images/bg_login.png'),
                fit: BoxFit.fill)),
        child: Stack(
          children: <Widget>[
            ListView(
              reverse: true,
              padding: EdgeInsets.only(
                  left: 65,
                  top: 0,
                  right: 65,
                  bottom: MediaQuery.of(context).size.height * 0.22),
              children: <Widget>[
                Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 80,
                    color: ColorRes.colorPrimary),
                SizedBox(
                  height: 15,
                ),
                Text(
                  Utils.getText(context, StringRes.confirmYourPhone),
                  style: TextStyle(
                    color: ColorRes.fontDarkGrey,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  Utils.getText(context, StringRes.helloEnter6Digit),
                  style: TextStyle(
                    color: ColorRes.fontGrey,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.user.phone ?? "",
                  style: TextStyle(
                    color: Color(int.parse("0xFF535353")),
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                PinCodeTextField(
                  autofocus: false,
                  controller: controller,
                  hideCharacter: false,
                  highlight: true,
                  highlightColor: ColorRes.colorPrimary,
                  defaultBorderColor: Colors.black,
                  hasTextBorderColor: ColorRes.colorPrimary,
                  maxLength: pinLength,
                  hasError: hasError,
                  wrapAlignment: WrapAlignment.center,
                  /* maskCharacter: "😎",*/

                  onTextChanged: (text) {
                    setState(() {
                      hasError = false;
                    });
                  },
                  onDone: (text) {
                    pin = text;
                    print("DONE $text");
                  },
                  pinBoxDecoration:
                      ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                  pinBoxWidth: Utils.getDeviceWidth(context) / 15,
                  pinTextStyle: TextStyle(fontSize: 24.0),
                  pinTextAnimatedSwitcherTransition:
                      ProvidedPinBoxTextAnimation.scalingTransition,
                  pinTextAnimatedSwitcherDuration:
                      Duration(milliseconds: 300),
                ),
                SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  color: ColorRes.colorPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  onPressed: () {
                    if (pin == null || pin.isEmpty) {
                      Utils.showSnackBar(_scaffoldKey,
                          Utils.getText(context, StringRes.pleaseEnterOTP));
                    } else {
                      _signInWithPhoneNumber(pin, context);
                    }
                  },
                  child: Text(
                    Utils.getText(context, StringRes.getStarted),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ].reversed.toList(),
            ),
            isLoading
                ? Center(
                    child: new CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          ColorRes.colorPrimary),
                    ),
                  )
                : Container(),
            InkResponse(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Image(
                  image: AssetImage('assets/images/ic_back.png'),
                  color: ColorRes.colorPrimary,
                  height: 30,
                  width: 30,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );

//
  }
}
