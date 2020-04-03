import 'dart:convert';

import 'package:app/helper/prefkeys.dart';
import 'package:app/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
    firestoreRef = Firestore.instance;
    firebaseAuth = FirebaseAuth.instance;

    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }

    user = prefs.getString(PrefKeys.user) != null
        ? User.fromJson(jsonDecode(prefs.getString(PrefKeys.user)))
        : null;

    if (user != null) userId = user.id;

    return prefs;
  }

  static updateUser(User _user) async {
    await prefs.setString(PrefKeys.user, jsonEncode(_user.toJson()));
    user = _user;
  }


}
