import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:mta/utilities/apputilities.dart';

mixin Validators {
  static bool phonenumbervalidation(String value) {
    if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%\s-]').hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }

  static bool usernamevalidation(String value) {
    if (RegExp(r'^[A-Za-z]\\w{5,29}$').hasMatch(value)) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> networkconnectvitiy() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      AppUtils.showToast('please check network connection');
      return false;
    }
  }

  Future<int> checkConnection() async {
    int returnVal;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        returnVal = 1;
      } else {
        returnVal = 0;
      }
    } on SocketException catch (_) {
      print('not connected');
      returnVal = 0;
    }
    return returnVal;
  }
}
