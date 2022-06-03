import 'dart:ui';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/NewsRes.dart';
import 'package:mta/models/NotificationRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/others/pdfviewer.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

FancyDrawerController? _controller;
List<NotificationData> _msgList = [];

class PushNotification extends StatelessWidget {
  const PushNotification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: NotificationContent(),
    );
  }
}

class NotificationContent extends StatefulWidget {
  static const String routeName = "/notification";
  @override
  _NotificationContentState createState() => _NotificationContentState();
}

class _NotificationContentState extends State<NotificationContent>
    with TickerProviderStateMixin {
  void initState() {
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {
          Strings.currentmenuvalue = 4;
        });
      });

    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) => getNotification());
  }

  menuopen() {}

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Material(
        child: Container(
      decoration:
          Drawables.menudecorationImage("assets/images/Menubg.png", 0.0),
      child: FancyDrawerWrapper(
        backgroundColor: Colors.transparent,
        controller: _controller!,
        drawerItems: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 30),
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: [
                new Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: Drawables.menudecorationImage(
                        "assets/images/logo.jpg", 50.0)),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "MTA Connect",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )
              ],
            ),
          ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/dashboard", currentmenu: 1);
            },
            selectedmenuvalue: 1,
            menutitle: "Projects",
          ),
          (Strings.roleId == 1 || Strings.roleId == 2 || Strings.roleId == 5)
              ? menuoption(
                  ontab: () {
                    menuRedirect(routename: "/attendance", currentmenu: 2);
                  },
                  selectedmenuvalue: 2,
                  menutitle: "Attendance",
                )
              : SizedBox(),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/profile", currentmenu: 3);
            },
            selectedmenuvalue: 3,
            menutitle: "Profile",
          ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/notification", currentmenu: 4);
            },
            selectedmenuvalue: 4,
            menutitle: "Notification",
          ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/contactus", currentmenu: 5);
            },
            selectedmenuvalue: 5,
            menutitle: "Contact Us",
          ),
          // menuoption(
          //   ontab: () {
          //     menuRedirect(routename: "/privacypolicy", currentmenu: 6);
          //   },
          //   selectedmenuvalue: 6,
          //   menutitle: "Privacy Policy",
          // ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/newshighlights", currentmenu: 7);
            },
            selectedmenuvalue: 7,
            menutitle: "News & Highlights",
          ),
          // menuoption(
          //   ontab: () {
          //     menuRedirect(routename: "/settings", currentmenu: 8);
          //   },
          //   selectedmenuvalue: 8,
          //   menutitle: "Settings",
          // ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/login", currentmenu: 9);
            },
            selectedmenuvalue: 9,
            menutitle: "Logout",
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: mainappbar(
              ontab: menuopen, title: "Notification", controller: _controller),
          body: Column(
            children: [
              _msgList.length > 0
                  ? Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemBuilder: (BuildContext ctx, int index) {
                          return GestureDetector(
                            onTap: () async {
                              var dataUrl;
                              if (_msgList[index].imgUrl != null &&
                                  _msgList[index].imgUrl != "") 
                                {
                                if (_msgList[index].imgUrl!.contains(".pdf")) 
                                {
                                    Strings.pdfDoc = Strings.baseImageUrl + _msgList[index].imgUrl!;
                                     Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => Pdfviewer()));
                                   // dataUrl = 'https://docs.google.com/viewer?url=${Strings.baseImageUrl + (_msgList[index].imgUrl ?? "")}';
                                } else 
                                {
                                    dataUrl = Strings.baseImageUrl + _msgList[index].imgUrl!;
                                }
                              }
                              if(dataUrl!= null && dataUrl != "")
                              {
                                FlutterWebBrowser.openWebPage(
                                url: dataUrl,
                                customTabsOptions: const CustomTabsOptions(
                                  colorScheme: CustomTabsColorScheme.dark,
                                  // toolbarColor: Strings,
                                  // secondaryToolbarColor: Colors.green,
                                  // navigationBarColor: Colors.amber,
                                  shareState: CustomTabsShareState.on,
                                  instantAppsEnabled: true,
                                  showTitle: true,
                                  urlBarHidingEnabled: true,
                                ),
                                safariVCOptions:
                                    const SafariViewControllerOptions(
                                  barCollapsingEnabled: true,
                                  preferredBarTintColor: Colors.green,
                                  preferredControlTintColor: Colors.amber,
                                  dismissButtonStyle:
                                      SafariViewControllerDismissButtonStyle
                                          .close,
                                  modalPresentationCapturesStatusBarAppearance:
                                      true,
                                ),
                              );
                              }

                              var data = {
                                "document_id":
                                    _msgList[index].docDetail?[0].documentId,
                                "file": _msgList[index].docDetail?[0].file,
                                "file_name":
                                    _msgList[index].docDetail?[0].fileName,
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
                                "project_id":
                                    _msgList[index].docDetail?[0].projectId,
                                "project_name":
                                    _msgList[index].docDetail?[0].projectName
                              }));
                              // getUserCats(
                              //     _msgList[index].docDetail?[0].projectId);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_msgList[index].title!,
                                                style: Drawables
                                                    .adddoccontentstyle(
                                                        Color(0xFF0061b0),
                                                        16.0,
                                                        FontWeight.w600)),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(_msgList[index].description!,
                                                style: Drawables
                                                    .adddoccontentstyle(
                                                        Colors.black87,
                                                        14.0,
                                                        FontWeight.w500)),
                                                        SizedBox(height: 5,),
                                                        Text(_msgList[index].createdAt!,
                                                style: Drawables
                                                    .adddoccontentstyle(
                                                        Colors.black87,
                                                        14.0,
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      _msgList[index].imgUrl != ""
                                          ? Container(
                                              width: 40.0,
                                              height: 40.0,
                                              decoration: new BoxDecoration(
                                                color: const Color(0xff7c94b6),
                                                image: new DecorationImage(
                                                  image: new NetworkImage(
                                                      Strings.baseImageUrl +
                                                          (_msgList[index]
                                                                  .imgUrl ??
                                                              "")),
                                                  fit: BoxFit.fill,
                                                ),
                                                borderRadius: new BorderRadius
                                                        .all(
                                                    new Radius.circular(50.0)),
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFFffffff),
                                ),
                              ),
                            ),
                          );

                          // return Text("hi");
                        },
                        itemCount: _msgList.length,
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    ));
  }

  menuRedirect({@required String? routename, int? currentmenu}) {
    setState(() {
      Strings.currentmenuvalue = currentmenu!;
    });
    if (routename == "/login") {
      //AppUtils.clearAllPreferences();
      //Navigator.popAndPushNamed(context, routename);
      Navigator.popAndPushNamed(context, "/login");
    } else {
      Navigator.pushNamed(context, routename!);
    }
  }

  getNotification() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.notification().then((response) {
      AppUtils.dismissprogress();
      print('categoiresResponse status ${response.toJson()}');
      if (response.status!) {
        setState(() {
          _msgList = response.data!;
        });
      } else {
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
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
