import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/PushRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/attendance/attendance.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/router.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return Container(child: SplashScreenContent());
    return Provider<ApiService>(
        create: (context) => ApiService.create(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'MyriadPro',
              primarySwatch: MyColors.navy,
              primaryColor: Color(0xFF0061b0),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            initialRoute: '/',
            onGenerateRoute: RoutesGenerator.generateRoute,
            navigatorKey: navigatorKey,
            builder: EasyLoading.init(),
            home: SplashScreenContent()));
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
  Timer? timer;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();

    _firebaseMessaging.subscribeToTopic("messaging");
    _firebaseMessaging.getToken().then((value) {
      print(value);
    });
    //  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    //   print("message recieved");
    //   print(event.notification!.body);
    //   print(event.data.values);
    //  });
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   print('Message clicked!');
    // });
    getToken();
    getFCMToken();
    // WidgetsBinding.instance?.addPostFrameCallback((_) => getFCMToken());
    //getToken();
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
        'assets/images/splashscreen.jpg',
        fit: BoxFit.fill,
      ),
    );
  }

  getFCMToken() async 
  {
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      setState(() {
        print("token: $token");
        Strings.fcmToken = token!;
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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) 
    {
      setState(() 
      {

        print("message recieved inside get");
        print("data received ---  ${message.data}");
        print(message.data);
        print(jsonEncode(message.data));
        ProjectDocData peo = ProjectDocData.fromJson(message.data);
      var check =  jsonEncode(peo);

        print("Check--> $check");
         Strings.selectedProDocument.add(peo);
         print("dataaa ${Strings.selectedProDocument[0].documentId}");
        print(message.notification?.body);
        AppUtils.showToastErrorTop(
            "Notification: ${message.notification?.body}");
        if (Strings.pushNotify == true) {

          print("inside if listen message-----> $message");
          _showMyDialog(
              (message as dynamic)['data']['image'],
              (message as dynamic)['data']['title'],
              (message as dynamic)['data']['body'],
              PushRes.fromJson(
                  jsonDecode((message as dynamic)['data']['docDetails'])[0]));
        }
      });
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) 
        {
        //Map<String, dynamic> map = message?.data;
         Strings.testing = "myvalue";
         ProjectDocData peo = ProjectDocData.fromJson(message?.data);
         Strings.selectedProDocument.add(peo);
         Strings.fromNotificationComments = true;

          // message?.data.forEach((key, value) {
          //   print("key: $key, value: $value");
          //   Strings.testing = value;
            
          //  // String.selectedProDocument = message.data;
          // });

      if (message?.notification?.body != null) {
        if (message!.notification!.body!.contains("Signed")) 
        {
          Strings.FromNotification = true;
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) 
    {
      if (message.notification?.body != null) 
      {
        if (message.notification!.body!.contains("logout")) {
          Strings.FromNotification = true;
          checkLogin();
        }
        if (message.notification!.title!.contains("Commented")) 
        {
          print("Inside Commented");
          ProjectDocData peo = ProjectDocData.fromJson(message.data);
          Strings.selectedProDocument.clear();
         Strings.selectedProDocument.add(peo);
          Strings.fromNotificationComments = true;
          checkLogin();
        }
      }

      print("is login  ${Strings.isLogin}");
      print("Message--> ${message.notification?.body}");
      // setState(() {
      //     if (Strings.pushNotify == true) {
      //         print("inside messageopenedApp message-----> $message");
      //        _showMyDialog(
      //           (message as dynamic)['data']['image'],
      //           (message as dynamic)['data']['title'],
      //           (message as dynamic)['data']['body'],
      //           PushRes.fromJson(jsonDecode((message as dynamic)['data']['docDetails'])[0]));
      //     }
      //   });
    });

    // old firebase version

    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage-: $message");
    //     setState(() {
    //       if (Strings.pushNotify == true) {
    //         _showMyDialog(
    //             message['data']['image'],
    //             message['data']['title'],
    //             message['data']['body'],
    //             PushRes.fromJson(jsonDecode(message['data']['docDetails'])[0]));
    //       }
    //     });
    //   },

    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("l-: $message");
    //     setState(() {
    //       if (Strings.pushNotify == true) {
    //         _showMyDialog(
    //             message['data']['image'],
    //             message['data']['title'],
    //             message['data']['body'],
    //             PushRes.fromJson(jsonDecode(message['data']['docDetails'])[0]));
    //       }
    //     });
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("r-: $message");
    //     setState(() {
    //       if (Strings.pushNotify == true) {
    //         _showMyDialog(
    //             message['data']['image'],
    //             message['data']['title'],
    //             message['data']['body'],
    //             PushRes.fromJson(jsonDecode(message['data']['docDetails'])[0]));
    //       }
    //     });
    //   },
    // );
    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(
    //         sound: true, badge: true, alert: true, provisional: true));

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      provisional: true,
      sound: true,
    );

    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });
  }

  Future<void> _showMyDialog(imgurl, title, desc, doc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          new Icon(Icons.close, size: 22.0, color: Colors.black)
                        ]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  imgurl != ""
                      ? Align(
                          alignment: Alignment.center,
                          child: image(imgurl, 100.0, 100.0),
                        )
                      : SizedBox(),
                  imgurl != ""
                      ? SizedBox(
                          height: 20,
                        )
                      : SizedBox(),
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      var data = {
                        "document_id": doc.documentId,
                        "file": doc.file,
                        "file_name": doc.fileName,
                        // "user_id": 4,
                        // "name": "Super Admin",
                        // "created_at": "2021-05-03 08:09:51",
                        // "description": "Sample Images",
                        "commentsCount": 0
                      };
                      // Strings.selectedNotifyDocumentFlag = true;
                      // Strings.selectedNotifyDocument = [];
                      // Strings.selectedNotifyDocument
                      //     .add(ProjectDocData.fromJson(data));
                      Strings.category = false;
                      Strings.selectedProDocument = [];

                      Strings.selectedProDocument
                          .add(ProjectDocData.fromJson(data));
                      Strings.selectedProject.add(Data.fromJson({
                        "project_id": doc.projectId,
                        "project_name": doc.projectName
                      }));
                      Strings.isPushAvailable = true;
                      if (Strings.isLogin == true) {
                        Strings.isPushAvailable = false;
                        getUserCats(doc.projectId);
                      } else {
                        AppUtils.showToastErrorTop("Please login");
                      }
                    },
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        child: Center(
                            child: Text(
                          "View",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 30,
                        decoration: BoxDecoration(
                            color: Color(0xFF0061b0),
                            borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Future<void> _showMyDialog(imgurl, title, desc, doc) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: SingleChildScrollView(
  //             child: GestureDetector(
  //                 onTap: () {
  //                   Navigator.of(context).pop();
  //                   var data = {
  //                     "document_id": doc.documentId,
  //                     "file": doc.file,
  //                     "file_name": doc.fileName,
  //                     // "user_id": 4,
  //                     // "name": "Super Admin",
  //                     // "created_at": "2021-05-03 08:09:51",
  //                     // "description": "Sample Images",
  //                     "commentsCount": 0
  //                   };
  //                   // Strings.selectedNotifyDocumentFlag = true;
  //                   // Strings.selectedNotifyDocument = [];
  //                   // Strings.selectedNotifyDocument
  //                   //     .add(ProjectDocData.fromJson(data));
  //                   Strings.category = false;
  //                   Strings.selectedProDocument = [];

  //                   Strings.selectedProDocument
  //                       .add(ProjectDocData.fromJson(data));
  //                   Strings.selectedProject.add(Data.fromJson({
  //                     "project_id": doc.projectId,
  //                     "project_name": doc.projectName
  //                   }));
  //                   Strings.isPushAvailable = true;
  //                   if (Strings.isLogin == true) {
  //                     Strings.isPushAvailable = false;
  //                     getUserCats(doc.projectId);
  //                   } else {
  //                     AppUtils.showToastErrorTop("Please login");
  //                   }
  //                 },
  //                 child: Container(
  //                   width: MediaQuery.of(context).size.width * 0.4,
  //                   height: MediaQuery.of(context).size.height * 0.4,
  //                   child: GridView.count(
  //                     primary: false,
  //                     crossAxisCount: 1,
  //                     children: <Widget>[
  //                       Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Row(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 new Icon(Icons.close,
  //                                     size: 22.0, color: Colors.black),
  //                               ]),
  //                           Container(
  //                             child: image(imgurl, 100.0, 100.0),
  //                           ),
  //                         ],
  //                       ),
  //                       Container(
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           crossAxisAlignment: CrossAxisAlignment.center,
  //                           children: [
  //                             Text(
  //                               title,
  //                               style: TextStyle(
  //                                   fontSize: 18,
  //                                   color: Color(0xFF0061b0),
  //                                   fontWeight: FontWeight.w600),
  //                             ),
  //                             SizedBox(
  //                               height: 10,
  //                             ),
  //                             Text(
  //                               desc,
  //                               style: TextStyle(
  //                                   fontSize: 16, fontWeight: FontWeight.w500),
  //                             ),
  //                             SizedBox(
  //                               height: 10,
  //                             ),
  //                             Text(
  //                               "View",
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: Color(0xFF0061b0),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ))
  //             // Row(
  //             //   mainAxisAlignment: MainAxisAlignment.center,
  //             //   children: [
  //             //     Container(
  //             //       child: image(imgurl, 150.0, 150.0),
  //             //     ),
  //             //     Container(
  //             //         child: Text(
  //             //       title,
  //             //       style:
  //             //           TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  //             //     ))
  //             //   ],
  //             // )),

  //             ),
  //       );
  //     },
  //   );
  // }

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
            // Navigator.popAndPushNamed(context, "/comments");
          } else {
            Navigator.popAndPushNamed(context, "/login");
            //Navigator.popAndPushNamed(context, "/comments");

          }
        }
      }).catchError((onError) {
        Navigator.popAndPushNamed(context, "/login");
        // Navigator.popAndPushNamed(context, "/comments");
      });
    });
  }

  void checkLogin() {
    AppUtils.getStringPreferences('easyAccess').then((value) 
    {
      if (value != null) {
        print(value);

        if (value == "Y") {
          Navigator.pushNamed(context, "/verifypin");
          // Navigator.popAndPushNamed(context, "/comments");
        } else {
          Navigator.popAndPushNamed(context, "/login");
          //Navigator.popAndPushNamed(context, "/comments");

        }
      }
    }).catchError((onError) {
      Navigator.popAndPushNamed(context, "/login");
      // Navigator.popAndPushNamed(context, "/comments");
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

  getUserCats(proId) {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.fetchUsers(proId).then((response) {
      if (response.status!) {
        setState(() {
          Strings.users = response.data!;
        });
        final api = Provider.of<ApiService>(context, listen: false);
        api.fetchCats(proId).then((response) {
          AppUtils.dismissprogress();
          if (response.status!) {
            setState(() {
              Strings.categories = response.data!;
              Navigator.pushNamed(context, '/comments');
            });
          } else {
            print('error');
          }
        }).catchError((onError) {
          AppUtils.dismissprogress();
          print(onError.toString());
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
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
