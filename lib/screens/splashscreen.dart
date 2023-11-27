import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/router.dart';
import 'package:mta/utilities/strings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:notification_permissions/notification_permissions.dart';

import '../models/FetchCatsRes.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) 
  {
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

    getFCMToken();
    getusername();
    getuserid();
    requestNotificationPermissions();
   // getConnectivity();
  }

  Future<void> requestNotificationPermissions() async {
    print("inside request");
    final status = await Permission.notification.request();

    AppUtils.getStringPreferences('showNotificationAlert').then((res) {
      if (res == "null") {
        AppUtils.savePreferences('showNotificationAlert', "true");
        if (status.isGranted) {
          getToken();
          print("Notification permissions granted");
        } else if (status.isDenied) {
          permissionDialog();
          print("Notification permissions denied");
        } else if (status.isPermanentlyDenied) {
// //print(
//     "Notification permissions permanently denied, open app settings");
          permissionDialog();
          // await openAppSettings();
        }
      } else {
        getToken();
      }
    });
  }

  permissionDialog() {
    return showDialog(
      context: context,
      builder: (ctx) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          title: Icon(
            Icons.notifications_outlined,
            size: 35,
            color: Colors.grey,
          ),
          content: Text(
            "Allow Notifications from notification settings",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100,
                    height: 33,
                    child: ElevatedButton(
                        onPressed: () {
                          getToken();
                          Navigator.of(ctx).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                        //   style: ElevatedButton.styleFrom(
                        //   primary: Colors.white,
                        // ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 243, 229, 104)),
                            textStyle: MaterialStateProperty.all(
                                TextStyle(color: Colors.white)))),
                  ),
                  //SizedBox(width: 15),
                  SizedBox(
                    width: 120,
                    height: 33,
                    child: ElevatedButton(
                      onPressed: () {
                        NotificationPermissions.requestNotificationPermissions(
                                iosSettings: const NotificationSettingsIos(
                                    sound: true, badge: true, alert: true))
                            .whenComplete(() {
                          Navigator.of(ctx).pop();
                          getToken();
                        });
                      },
                      child: Text(
                        "Open Settings",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Strings.ctx = context;
    return Container(
      child: Image.asset(
        'assets/images/splashscreen.jpg',
        fit: BoxFit.fill,
      ),
    );
  }

  getFCMToken() async {
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      setState(() {
        print("token: $token");
        Strings.fcmToken = token!;
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print("message recieved inside get");
      // print("data received ---  ${message.notification!.body}");
      // //  _showMyDialog("", message.notification!.title ?? "", message.notification!.body ?? "", "doc");
      // print(message.data);
      // print("Direct data data -->${jsonEncode(message.data)}");
      // ProjectDocData peo = ProjectDocData.fromJson(message.data);
      // var check = jsonEncode(peo);

      // print("Check--> $check");
      // Strings.selectedProDocument.add(peo);
      // print("dataaa ${Strings.selectedProDocument[0].documentId}");
      // print(message.notification?.body);
      AppUtils.showToastErrorTop("You have a new notification!");
      print("dataaa ${jsonEncode(message.data)}");

      if (Strings.pushNotify == true) {
        print("inside if listen message-----> $message");
      }
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message?.notification?.title != null) {
        if (message!.notification!.title!.contains("Signed")) {
          Strings.FromNotification = true;
        } else if (message.notification!.title!.contains("Commented") ||
            message.notification!.title!.contains("Replied")) {
          print("inside");
          ProjectDocData peo = ProjectDocData.fromJson(message.data);
          Strings.selectedProDocument.add(peo);
          Strings.fromNotificationComments = true;
          print(jsonEncode(peo));
          int id = int.parse(peo.notiId!);
          Strings.notificationID = id;
          Strings.projectId = int.parse(peo.projectId ?? "000");
        } else if (message.notification!.title!.contains("Documents")) {
          DocumentData peo = DocumentData.fromJson(message.data);
          Strings.selectedProject.clear();
          Strings.selectedProject.add(Data.fromJson({
            "project_img": "",
            "project_name": peo.projectName,
            "project_id": (peo.projectId != "null" && peo.projectId != null)
                ? int.parse(peo.projectId ?? "0")
                : null
          }));
          Strings.selectedCategory.clear();
          Strings.selectedCategory.add(FectchCatsData.fromJson({
            "category_id": (peo.categoryId != "null" && peo.categoryId != null)
                ? int.parse(peo.categoryId ?? "0")
                : null,
            "category_name": peo.categoryName,
            "project_id": (peo.projectId != "null" && peo.projectId != null)
                ? int.parse(peo.projectId ?? "0")
                : null
          }));

          if (peo.categoryId != "null" && peo.categoryId != null) {
            Strings.category = true;
          } else {
            Strings.category = false;
          }
          Strings.fromNotificationDocuments = true;
          int id = int.parse(peo.notiId!);
          Strings.notificationID = id;
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification?.body != null) {
        print(message.notification?.body);
        if (message.notification!.title!.contains("logout")) {
          Strings.FromNotification = true;
          await checkLogin();
        } else if (message.notification!.title!.contains("Commented") ||
            message.notification!.title!.contains("Replied")) {
          print("test inside");
          print(message.data);
          ProjectDocData peo = ProjectDocData.fromJson(message.data);
          Strings.selectedProDocument.clear();
          Strings.selectedProDocument.add(peo);
          Strings.fromNotificationComments = true;
          print(jsonEncode(peo));
          await checkLogin();
          int id = int.parse(peo.notiId!);
          Strings.projectId = int.parse(peo.projectId ?? "000");
          Strings.notificationID = id;
        } else if (message.notification!.title!.contains("Documents")) {
          DocumentData peo = DocumentData.fromJson(message.data);
          Strings.selectedProject.clear();

          Strings.selectedProject.add(Data.fromJson({
            "project_img": "",
            "project_name": peo.projectName,
            "project_id": (peo.projectId != "null" && peo.projectId != null)
                ? int.parse(peo.projectId ?? "0")
                : null
          }));
          Strings.selectedCategory.clear();
          Strings.selectedCategory.add(FectchCatsData.fromJson({
            "category_id": (peo.categoryId != "null" && peo.categoryId != null)
                ? int.parse(peo.categoryId ?? "0")
                : null,
            "category_name": peo.categoryName,
            "project_id": (peo.projectId != "null" && peo.projectId != null)
                ? int.parse(peo.projectId ?? "0")
                : null
          }));

          if (peo.categoryId != "null" && peo.categoryId != null) {
            Strings.category = true;
          } else {
            Strings.category = false;
          }
          Strings.fromNotificationDocuments = true;
          checkLogin();
          int id = int.parse(peo.notiId!);
          Strings.notificationID = id;
        }
      }
    });

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

  _showMyDialog(imgurl, title, desc, doc) async {
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
    timer = new Timer(const Duration(milliseconds: 500), () 
    {
      AppUtils.getStringPreferences('easyAccess').then((value) 
      {
        if (value != null) 
        {
          print("value inside--> $value");
          if (value == "Y") {
            print("test");
            Navigator.popAndPushNamed(context, "/verifypin");
            // Navigator.popAndPushNamed(context, "/comments");
          } else {
            Navigator.popAndPushNamed(context, "/login");
            //Navigator.popAndPushNamed(context, "/comments");
          }
        }
      }).catchError((onError) {
        print(onError);
        Navigator.popAndPushNamed(context, "/login");
        // Navigator.popAndPushNamed(context, "/comments");
      });
    });
  }

  checkLogin() 
  {
    AppUtils.getStringPreferences('easyAccess').then((value) {
      print("Checking $value");
      if (value != null) {
        print(value);

        if (value == "Y") {
          // Navigator.pushNamed(context, "/verifypin",);
          navigatorKey.currentState?.pushNamed('/verifypin');

          // Navigator.popAndPushNamed(context, "/comments");
        } else {
          navigatorKey.currentState?.pushNamed('/login');
          //Navigator.popAndPushNamed(context, "/comments");

        }
      }
    }).catchError((onError) {
      print("inside catch error: " + onError.message);
      //Navigator.popAndPushNamed(context, "/login");
      // Navigator.popAndPushNamed(context, "/comments");
    });
  }

  updateNotification(notificationId) {
    final api = Provider.of<ApiService>(context, listen: false);
    api.updateNotificationStatus(notificationId).then((response) {
      if (response.status!) {
        AppUtils.showToastError("Unable to update status");
      } else {
        AppUtils.dismissprogress();
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError("Unable to connect to server");
      print(onError.toString());
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
    print("checkk");
    AppUtils.getStringPreferences('username').then((value) {
      print("username $value");
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
