import 'dart:convert';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FectchProjectDocRes.dart';
import 'package:mta/models/NotificationRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/others/pdfviewer.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:intl/intl.dart';
import '../../models/FetchCatsRes.dart';

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
  void initState() 
  {
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {
          Strings.currentmenuvalue = 5;
        });
      });
    _msgList.clear();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => getNotification());
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
                  "MTA Konnect",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )
              ],
            ),
          ),
          if (Strings.roleId != 6)
            menuoption(
              ontab: () {
                Strings.fromProjects = false;
                menuRedirect(routename: "/teamsDashboard", currentmenu: 1);
              },
              selectedmenuvalue: 1,
              menutitle: Strings.roleId == 7 ? "Home" : "Teams",
            ),
          if (Strings.roleId != 7)
            menuoption(
              ontab: () {
                Strings.fromProjects = true;
                menuRedirect(routename: "/projects", currentmenu: 2);
              },
              selectedmenuvalue: 2,
              menutitle: "Projects",
            ),
          if (Strings.roleId == 1 || Strings.roleId == 2 || Strings.roleId == 5)
            menuoption(
              ontab: () {
                menuRedirect(routename: "/attendance", currentmenu: 3);
              },
              selectedmenuvalue: 3,
              menutitle: "Attendance",
            ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/profile", currentmenu: 4);
            },
            selectedmenuvalue: 4,
            menutitle: "Profile",
          ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/notification", currentmenu: 5);
            },
            selectedmenuvalue: 5,
            menutitle: "Notification",
          ),
          menuoption(
            ontab: () {
              menuRedirect(routename: "/contactus", currentmenu: 6);
            },
            selectedmenuvalue: 6,
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
              showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                  title: Text(
                    "Are you sure ?",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF0061b0),
                        fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    'Do you want to logout from the App',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: new Text(
                        'No',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        menuRedirect(routename: "/login", currentmenu: 9);
                        AppUtils.savePreferences("easyAccess", "N");
                        AppUtils.removeDeviceId(context);
                      },
                      child: new Text(
                        'Yes',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
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
                                  _msgList[index].imgUrl != "") {
                                if (_msgList[index].imgUrl!.contains(".pdf")) {
                                  Strings.pdfDoc = Strings.baseImageUrl +
                                      _msgList[index].imgUrl!;
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Pdfviewer()));
                                  // dataUrl = 'https://docs.google.com/viewer?url=${Strings.baseImageUrl + (_msgList[index].imgUrl ?? "")}';
                                } else {
                                  dataUrl = Strings.baseImageUrl +
                                      _msgList[index].imgUrl!;
                                }
                              }
                              if (dataUrl != null && dataUrl != "") {
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

                              Strings.fromNotificationScren = true;
                              if (_msgList[index]
                                  .title!
                                  .contains("Commented")) 
                              {
                                Strings.selectedProDocument.clear();
                                var dat = jsonEncode(_msgList[index].docDetail);
                                print("qwerty $dat");
                                var decoded = jsonDecode(dat);
                                ProjectDocData peo =
                                    ProjectDocData.fromJson(decoded);
                                print(jsonEncode(peo));
                                Strings.selectedProDocument.add(peo);

                                if(_msgList[index].docDetail?.projectComments == true)
                                {
                                    Strings.projectId = _msgList[index].docDetail?.projectId!;
                                    updateNotification(_msgList[index].notiId, "projectComments");
                                }
                                else
                                {
                                      updateNotification(_msgList[index].notiId, "comments");
                                }
                               
                              } else if (_msgList[index]
                                  .title!
                                  .contains("Replied")) 
                              {
                                Strings.selectedProDocument.clear();
                                var dat = jsonEncode(_msgList[index].docDetail);
                                print("uiiii");
                                var decoded = jsonDecode(dat);
                                ProjectDocData peo =
                                    ProjectDocData.fromJson(decoded);
                                print(jsonEncode(peo));
                                Strings.selectedProDocument.add(peo);


                                if(_msgList[index].docDetail?.projectComments == "true")
                                {
                                    Strings.projectId = _msgList[index].docDetail?.projectId!;
                                    updateNotification(_msgList[index].notiId, "projectReplies");
                                }
                                else
                                {
                                    updateNotification(_msgList[index].notiId, "replies");
                                }
                                
                              } else 
                              {
                                var dat = jsonEncode(_msgList[index].docDetail);
                                var decoded = jsonDecode(dat);
                                ProjectDocData peo =
                                    ProjectDocData.fromJson(decoded);

                                Strings.selectedProject.add(Data.fromJson({
                                  "project_img": "",
                                  "project_name": peo.projectName,
                                  "project_id": (peo.projectId != "null" &&
                                          peo.projectId != null)
                                      ? int.parse(peo.projectId ?? "0")
                                      : null
                                }));

                                print("peoo ${jsonEncode(peo)}");

                                
                              

                                if (peo.categoryId != "null" &&
                                    peo.categoryId != null) 
                                    {
                                      Strings.selectedCategory.clear();
                                Strings.selectedCategory
                                    .add(FectchCatsData.fromJson(
                                      {
                                  "category_id": (peo.categoryId != "null" &&
                                          peo.categoryId != null)
                                      ? peo.categoryId
                                      : null,
                                  "category_name": peo.categoryName,
                                  "project_id": (peo.projectId != "null" &&
                                          peo.projectId != null)
                                      ? int.parse(peo.projectId ?? "0")
                                      : null
                                }));
                                  Strings.category = true;
                                } else {
                                  Strings.category = false;
                                    
                                }
                               // Strings.fromNotificationDocuments = true;
                                updateNotification(
                                    _msgList[index].notiId, "docs");
                              }

                              // var data = {
                              //   "document_id":
                              //       _msgList[index].docDetail?[0].documentId,
                              //   "file": _msgList[index].docDetail?[0].file,
                              //   "file_name":
                              //       _msgList[index].docDetail?[0].fileName,
                              //   // "user_id": 4,
                              //   // "name": "Super Admin",
                              //   // "created_at": "2021-05-03 08:09:51",
                              //   // "description": "Sample Images",
                              //   "commentsCount": 0
                              // };
                              // Strings.selectedNotifyDocumentFlag = true;
                              // Strings.selectedNotifyDocument = [];
                              // Strings.selectedNotifyDocument
                              //     .add(ProjectDocData.fromJson(data));
                              // Strings.category = false;
                              // Strings.selectedProDocument = [];

                              // Strings.selectedProDocument
                              //     .add(ProjectDocData.fromJson(data));
                              // Strings.selectedProject.add(Data.fromJson({
                              //   "project_id":
                              //       _msgList[index].docDetail?[0].projectId,
                              //   "project_name":
                              //       _msgList[index].docDetail?[0].projectName
                              // }));
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
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                DateFormat.jm().format(
                                                    DateTime.parse(
                                                        _msgList[index]
                                                            .createdAt!)),
                                                style: Drawables
                                                    .adddoccontentstyle(
                                                        Colors.grey,
                                                        14.0,
                                                        FontWeight.w500)),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                                DateFormat.MMMMEEEEd().format(
                                                    DateTime.parse(
                                                        _msgList[index]
                                                            .createdAt!)),
                                                style: Drawables
                                                    .adddoccontentstyle(
                                                        Colors.grey,
                                                        14.0,
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      _msgList[index].imgUrl != null
                                          ? Image.asset(
                                              getFileExt(
                                                  _msgList[index].imgUrl!),
                                              width: 30,
                                              height: 30,
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

  String getFileExt(String fileName) {
    var file = fileName.split(".");
    var fileExt = file[1];
    if (fileExt == "png" || fileExt == "PNG") {
      return "assets/icons/png.png";
    } else if (fileExt == "jpg" ||
        fileExt == "jepg" ||
        fileExt == "jpeg" ||
        fileExt == "JPG" ||
        fileExt == "JEPG" ||
        fileExt == "JPEG") {
      return "assets/icons/jpg.png";
    } else if (fileExt == "pdf" || fileExt == "PDF") {
      return "assets/icons/pdf.png";
    } else if (fileExt == "txt" || fileExt == "TXT") {
      return "assets/icons/txt.png";
    } else if (fileExt == "ppt" || fileExt == "PPT") {
      return "assets/icons/ppt.png";
    } else if (fileExt == "mpeg" || fileExt == "mpg") {
      return "assets/icons/mpg.png";
    } else if (fileExt == "wav" || fileExt == "mp3") {
      return "assets/icons/mp3.png";
    } else if (fileExt == "xls" ||
        fileExt == "xlsx" ||
        fileExt == "xlsm" ||
        fileExt == "xlsb" ||
        fileExt == "xltx") {
      return "assets/icons/xls.png";
    } else {
      return "assets/icons/doc.png";
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
        setState(() {
          _msgList.clear();
          AppUtils.showToastError(response.message!);
        });
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  updateNotification(notificationId, toComments) 
  {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.updateNotificationStatus(notificationId).then((response) {
      if (response.status!) {
        AppUtils.dismissprogress();

        if (toComments == "comments") {
          Navigator.of(context).pushReplacementNamed('/comments');
        } else if (toComments == "replies") {
          Strings.fromNotificationReply = true;
          Navigator.of(context).pushReplacementNamed('/replies');
        }else if(toComments == "projectComments") 
        {
          Navigator.of(context).pushReplacementNamed('/projectComments');
        }
        else if(toComments == "projectReplies"){
          Strings.fromNotificationReply = true;
          Navigator.of(context).pushReplacementNamed('/projectCommentReplies');
      }
        
        else {
         // Strings.fromNotificationDocuments = true;
          Navigator.of(context)
                    .pushReplacementNamed('/viewdoclist');
        }
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
