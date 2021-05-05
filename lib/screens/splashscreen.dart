import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    getToken();
    getFCMToken();
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

  getFCMToken() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage-: $message");
        // AppUtils.showToast(message['notification']['body']);
        setState(() {
          _showMyDialog(message['data']['image'], message['data']['title'],
              message['data']['body']);
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("l-: $message");

        _showMyDialog(message['data']['image'], message['data']['title'],
            message['data']['body']);
      },
      onResume: (Map<String, dynamic> message) async {
        print("r-: $message");

        _showMyDialog(message['data']['image'], message['data']['title'],
            message['data']['body']);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        print("token: $token");
        Strings.fcmToken = token;
        //  var  payload = jsonEncode(<String, dynamic>{
        //                                      "token": token,
        //                                      "device": 'Android'
        //                                    });
        //  service.postToken(payload);
        // Strings.fcmToken = token;
      });
      // setState(() {
      //   _homeScreenText = "Push Messaging token: $token";
      // });
      // print(_homeScreenText);
    });
  }

  Future<void> _showMyDialog(imgurl, title, desc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: GridView.count(
                      primary: false,
                      crossAxisCount: 1,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  new Icon(Icons.close,
                                      size: 22.0, color: Colors.black),
                                ]),
                            Container(
                              child: image(imgurl, 100.0, 100.0),
                            ),
                          ],
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF0061b0),
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                desc,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              // ,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       child: image(imgurl, 150.0, 150.0),
              //     ),
              //     Container(
              //         child: Text(
              //       title,
              //       style:
              //           TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              //     ))
              //   ],
              // )),

              ),
        );
      },
    );
  }

  Widget image(String img, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: new BoxDecoration(
        color: const Color(0xff7c94b6),
        image: new DecorationImage(
          image: new NetworkImage(img),
          fit: BoxFit.fill,
        ),
        borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
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
