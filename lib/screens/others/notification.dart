import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mta/utilities/app_drawer.dart';
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
    _msgList.clear();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => getNotification());
  }

  menuopen() {}

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Scaffold(
          drawer: AppDrawer(),
          backgroundColor: Colors.grey[300],
          appBar: mainappbar(ontab: menuopen, title: "Notification"),
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
                              if (_msgList[index].title!.contains("Commented")) {
                                Strings.selectedProDocument.clear();
                                var dat = jsonEncode(_msgList[index].docDetail);
                                print("qwerty $dat");
                                var decoded = jsonDecode(dat);
                                ProjectDocData peo =
                                    ProjectDocData.fromJson(decoded);
                                print(jsonEncode(peo));
                                Strings.selectedProDocument.add(peo);
        
                                if (_msgList[index].docDetail?.projectComments ==
                                    true) {
                                  Strings.projectId =
                                      _msgList[index].docDetail?.projectId!;
                                  updateNotification(
                                      _msgList[index].notiId, "projectComments");
                                } else {
                                  updateNotification(
                                      _msgList[index].notiId, "comments");
                                }
                              } else if (_msgList[index]
                                  .title!
                                  .contains("Replied")) {
                                Strings.selectedProDocument.clear();
                                var dat = jsonEncode(_msgList[index].docDetail);
                                print("uiiii");
                                var decoded = jsonDecode(dat);
                                ProjectDocData peo =
                                    ProjectDocData.fromJson(decoded);
                                print(jsonEncode(peo));
                                Strings.selectedProDocument.add(peo);
        
                                if (_msgList[index].docDetail?.projectComments ==
                                    "true") {
                                  Strings.projectId =
                                      _msgList[index].docDetail?.projectId!;
                                  updateNotification(
                                      _msgList[index].notiId, "projectReplies");
                                } else {
                                  updateNotification(
                                      _msgList[index].notiId, "replies");
                                }
                              } else {
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
                                    peo.categoryId != null) {
                                  Strings.selectedCategory.clear();
                                  Strings.selectedCategory
                                      .add(FectchCatsData.fromJson({
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
                                                style:
                                                    Drawables.adddoccontentstyle(
                                                        Color(0xFF0061b0),
                                                        16.0,
                                                        FontWeight.w600)),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(_msgList[index].description!,
                                                style:
                                                    Drawables.adddoccontentstyle(
                                                        Colors.black87,
                                                        14.0,
                                                        FontWeight.w500)),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                DateFormat.jm().format(
                                                    DateTime.parse(_msgList[index]
                                                        .createdAt!)),
                                                style:
                                                    Drawables.adddoccontentstyle(
                                                        Colors.grey,
                                                        14.0,
                                                        FontWeight.w500)),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                                DateFormat.MMMMEEEEd().format(
                                                    DateTime.parse(_msgList[index]
                                                        .createdAt!)),
                                                style:
                                                    Drawables.adddoccontentstyle(
                                                        Colors.grey,
                                                        14.0,
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      _msgList[index].imgUrl != null
                                          ? Image.asset(
                                              getFileExt(_msgList[index].imgUrl!),
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
    );
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

  updateNotification(notificationId, toComments) {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.updateNotificationStatus(notificationId).then((response) {
      if (response.status!) {
        AppUtils.dismissprogress();

        if (toComments == "comments") {
          Navigator.of(context).pushNamed('/comments');
        } else if (toComments == "replies") {
          Strings.fromNotificationReply = true;
          Navigator.of(context).pushNamed('/replies');
        } else if (toComments == "projectComments") {
          Navigator.of(context).pushNamed('/projectComments');
        } else if (toComments == "projectReplies") {
          Strings.fromNotificationReply = true;
          Navigator.of(context).pushNamed('/projectCommentReplies');
        } else {
          // Strings.fromNotificationDocuments = true;
          Navigator.of(context).pushNamed('/viewdoclist');
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
