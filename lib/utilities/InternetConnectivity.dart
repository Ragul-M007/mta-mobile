import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mta/screens/splashscreen.dart';
import 'package:mta/utilities/strings.dart';
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  Stream<ConnectivityResult> get connectivityStream =>
      Connectivity().onConnectivityChanged;
}
getConnectivity() => ConnectivityService().connectivityStream.listen(
        (ConnectivityResult result) async {
          if (result == ConnectivityResult.none) {
            _showNoInternetDialog();
          } else {
            if (Strings.internetDialog == true) {
              Navigator.pop(navigatorKey.currentContext!);
              Strings.internetDialog = false;
            }
          }
        },
      );

  _showNoInternetDialog() 
  {
    Strings.internetDialog = true;

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        "Connection Lost",
        textAlign:TextAlign.center,
        style: TextStyle(
          
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 18),
      ),
      content: Text(
        "No Internet Available!",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14),
      ),
    );
    showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentContext!,
        builder: (_) => WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: alert,
            ));
  }