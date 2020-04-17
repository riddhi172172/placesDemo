import 'dart:convert';

import 'package:app/helper/prefkeys.dart';
import 'package:app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

//singleton class that will be called once app is opened

class Injector {
  static final Injector _singleton = new Injector._internal();

  static Firestore firestoreRef;
  static FirebaseAuth firebaseAuth;
  static User user;
  static String userId;
  static String selectedCountry;

  static SharedPreferences prefs;

  static Uuid uuid = Uuid();


  factory Injector() {
    return _singleton;
  }

  Injector._internal();

  static Future<SharedPreferences> getInstance() async {

    //init firebase instance for once

    firestoreRef = Firestore.instance;
    firebaseAuth = FirebaseAuth.instance;


    //init sharedPreference instance for once
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    // get user data form the prefs
    user = prefs.getString(PrefKeys.user) != null
        ? User.fromJson(jsonDecode(prefs.getString(PrefKeys.user)))
        : null;

    if (user != null) userId = user.id;

    return prefs;
  }


  //update the user in prefs and in singleton instance whenever needed
  static updateUser(User _user) async {
    await prefs.setString(PrefKeys.user, jsonEncode(_user.toJson()));
    user = _user;
  }


}
