import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/router.dart';
import 'package:mta/utilities/strings.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return Container(child: SplashScreenContent());
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'MyriadPro',
          primarySwatch: MyColors.navy,
          primaryColor: Color(0xFF0061b0),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        onGenerateRoute: RoutesGenerator.generateRoute,
        builder: EasyLoading.init(),
        home: SplashScreenContent());
  }
}

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Drawables.bgOrangeGradient;
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}

class SplashScreenContent extends StatefulWidget {
  @override
  _SplashScreenContentState createState() => _SplashScreenContentState();
}

class _SplashScreenContentState extends State<SplashScreenContent> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    getToken();
    //  AppUtils.getStringPreferences('token').then((value) {
    //   if (value != "null") {
    //     Strings.authToken = "Bearer " + value;
    //     Navigator.pushNamed(context, "/login");
    //   } else {
    //     Navigator.pushNamed(context, "/login");
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        'assets/images/background1.png',
        fit: BoxFit.fill,
      ),
    );
  }

  void getToken() {
    timer = new Timer(const Duration(milliseconds: 4000), () {
      AppUtils.getStringPreferences('easyAccess').then((value) {
        if (value != null) {
          print(value);
          if (value == "Y") {
            Navigator.pushNamed(context, "/verifypin");
          } else {
            Navigator.popAndPushNamed(context, "/login");
          }
        }
      }).catchError((onError) {
        Navigator.popAndPushNamed(context, "/login");
      });
    });
  }

  void getuserid() {
    AppUtils.getIntPreferences('userId').then((value) {
      Strings.userID = value;
      print('userID >>$value');
    });
  }

  void getmailid() {
    AppUtils.getStringPreferences('mailId').then((value) {
      if (value != "null") {
        Strings.useremailID = value;
        print('usermailID >>$value');
      }
    });
  }

  void getusername() {
    AppUtils.getStringPreferences('username').then((value) {
      if (value != "null") {
        Strings.username = value;
        print('username >>$value');
      }
    });
  }
}

class MyColors {
  static const MaterialColor navy = MaterialColor(
    0xFF8686f1,
    <int, Color>{
      50: Color(0xFF8686f1),
      100: Color(0xFF8686f1),
      200: Color(0xFF8686f1),
      300: Color(0xFF8686f1),
      400: Color(0xFF8686f1),
      500: Color(0xFF8686f1),
      600: Color(0xFF8686f1),
      700: Color(0xFF8686f1),
      800: Color(0xFF8686f1),
      900: Color(0xFF8686f1),
    },
  );
}
