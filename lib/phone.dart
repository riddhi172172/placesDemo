
import 'package:app/signup.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dialogs/alert_dialog.dart';
import 'helper/color_res.dart';
import 'helper/constant.dart';
import 'helper/string_res.dart';
import 'helper/utils.dart';
import 'model/user.dart';

class PhoneScreen extends StatefulWidget {
  @override
  PhoneScreenState createState() => new PhoneScreenState();
}

class PhoneScreenState extends State<PhoneScreen> {
  TextEditingController _countryCodeController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  String verificationId;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;

  List<User> arrUsers = List();

  @override
  void initState() {
    TextEditingController _countryCodeController = TextEditingController();

    super.initState();

//    getExistingUsers();
  }

//  void getExistingUsers() {
//    Injector
//        .databaseRef
//        .child(Const.childUsers)
//        .onValue
//        .listen((category) {})
//        .onData((Event event) {
//      setState(() {
//        if (event.snapshot != null) {
//          print("category = " + event.snapshot.value.toString());
//
//          Map<dynamic, dynamic> mapOfMaps = Map.from(event.snapshot.value);
//
//          arrUsers.clear();
//
//          mapOfMaps.values.forEach((value) async {
//            User user = User.fromJson(Map.from(value));
//
//            arrUsers.add(user);
//          });
//        }
//      });
//    });
//  }

  Future<void> _sendCodeToPhoneNumber(
      BuildContext context, PhoneScreen widget, String phone) async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential authCredential) {
      setState(() {
        isLoading = false;
        print(
            'Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $authCredential');
        Utils.showSnackBar(_scaffoldKey,
            Utils.getText(context, StringRes.successPhoneVerification));
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        isLoading = false;

        showDialog(
          context: context,
          builder: (_) => AlertMessageDialog(
            text:
                "Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}",
          ),
        );

//        Utils.showSnackBar(_scaffoldKey,
//            "Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}");
        print(
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationId = verificationId;
      print("code sent to " +
          phone +
          "__________" +
          forceResendingToken.toString());

      isLoading = false;

      User user = User();
      user.phone = phone;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SignUpScreen(user: user, verificationId: verificationId),
        ),
      );
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      print("time out");
      Utils.showSnackBar(_scaffoldKey, "time out");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 10),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  String selectedCountryCode = "+968";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
          child: Container(
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
                  bottom: MediaQuery.of(context).size.height * 0.35),
              children: <Widget>[
                Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 80,
                    color: ColorRes.colorPrimary),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Row(
                    children: <Widget>[
                      new CountryCodePicker(
                        onChanged: _onCountryChange,
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: selectedCountryCode,
                        favorite: [selectedCountryCode],
                        // optional. Shows only country name and flag
                        showCountryOnly: false,
                        // optional. Shows only country name and flag when popup is closed.
//                        showOnlyCountryCodeWhenClosed: false,
                        // optional. aligns the flag and the Text left
                        alignLeft: false,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: TextField(
                          decoration: InputDecoration(
                              hintText:
                                  Utils.getText(context, StringRes.phoneNumber),
                              hintStyle: TextStyle(
                                  color: ColorRes.hintColor,
                                  fontFamily: Const.fontSansPro,
                                  fontWeight: FontWeight.w600)),
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(
                              fontFamily: Const.fontSansPro,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                MaterialButton(
                  color: ColorRes.colorPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  onPressed: () {
                    String code = selectedCountryCode;
                    String phone = _phoneNumberController.text.toString();

                    if (code.isEmpty) {
                      Utils.showSnackBar(
                          _scaffoldKey,
                          Utils.getText(
                              context, StringRes.alertEnterCountryCode));
                      return;
                    }

                    if (phone.isEmpty) {
                      Utils.showSnackBar(
                          _scaffoldKey,
                          Utils.getText(
                              context, StringRes.alertEnterPhoneNumber));
                      return;
                    }

                    String number = !code.startsWith("+")
                        ? ("+" + code + phone)
                        : (code + phone);

                    FocusScope.of(context).requestFocus(new FocusNode());

                    _sendCodeToPhoneNumber(context, widget, number);

                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Text(
                    Utils.getText(context, StringRes.login),
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ].reversed.toList(),
            ),
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
            isLoading
                ? Center(
                    child: new CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          ColorRes.colorPrimary),
                    ),
                  )
                : Container()
          ],
        ),
      )),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    //Todo : manipulate the selected country code here
    selectedCountryCode = countryCode.toString();
    print("New Country selected: " + countryCode.toString());
  }
}
