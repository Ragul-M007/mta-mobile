import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AppUtils {
  // Field Focus

  static void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  //////////////////////////////////////////////////////////////////////////////////////////
  /// Shared Preferences starts here
//////////////////////////////////////////////////////////////////////////////////////////

  static savePreferences(String key, dynamic value) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPrefs.setBool(key, value);
    } else if (value is String) {
      sharedPrefs.setString(key, value);
    } else if (value is int) {
      sharedPrefs.setInt(key, value);
    } else if (value is List<String>) {
      sharedPrefs.setStringList(key, value);
    }
  }

  static Future<String> getStringPreferences(String key) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    String pref = sharedPrefs.getString(key) ?? "null";
    return pref;
  }

  static Future<int> getIntPreferences(String key) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getInt(key) ?? 0;
  }

  static Future<bool> getBoolPreferences(String key) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool(key) ?? false;
  }

  static Future<bool> clearPreferences(String key) async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return await sharedPrefs.remove(key);
  }

  static Future<bool> clearAllPreferences() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    return await sharedPrefs.clear();
  }

  //  toast message

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0);
  }

  static void snackBar(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static void showprogress() {
    // showProgressDialog(
    //     backgroundColor: Colors.white.withOpacity(0),
    //     textStyle: TextStyle(color: Colors.black));
    print('showProgress');
    EasyLoading.show();
  }

  static void dismissprogress() {
    //dismissProgressDialog();
    print('dismiss');

    EasyLoading.dismiss();
  }
}
