import 'dart:io';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/splashscreen.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

FancyDrawerController? _controller;
FocusNode name = new FocusNode();
ImagePicker _picker = ImagePicker();

class WebpageView extends StatefulWidget {
  static const String routeName = "/webview";

  @override
  _WebpageViewState createState() => _WebpageViewState();
}

class _WebpageViewState extends State<WebpageView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 100))
      ..addListener(() {
        setState(() {
          // print(Strings.authToken);
          Strings.currentmenuvalue = 3;
        });
      });
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Container(child: LoginContent());

    return Provider<ApiService>(
        create: (context) => ApiService.create(),
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
              menuoption(
                ontab: () {
                  menuRedirect(routename: "/dashboard", currentmenu: 1);
                },
                selectedmenuvalue: 1,
                menutitle: "Projects",
              ),
              (Strings.roleId == 1 ||
                      Strings.roleId == 2 ||
                      Strings.roleId == 5)
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
              backgroundColor: const Color(0xFFececed),
              appBar: AppBar(
                backgroundColor: Colors.white,
                actions: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 20, 5),
                      child: GestureDetector(
                          onTap: () {
                            print(Strings.baseImageUrl + Strings.profilePic!);
                            _showMyDialog(
                                context,
                                Strings.baseImageUrl + Strings.profilePic!,
                                Strings.username);
                          },
                          child: CircleAvatar(
                            backgroundImage: (Strings.profilePic != "")
                                ? NetworkImage(Strings.baseImageUrl +
                                    (Strings.profilePic ?? ""))
                                : AssetImage(
                                    "assets/icons/account.png",
                                  ) as ImageProvider,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                          )
                          // Strings.profilePic == null
                          //     ? Image.asset(
                          //         "assets/images/user.png",
                          //         height: 40,
                          //         width: 40,
                          //       )
                          //     : Image.network(
                          //         Strings.baseImageUrl + Strings.profilePic!,
                          //         height: 40,
                          //         width: 40,
                          //       ),
                          // image.(
                          //     Strings.baseImageUrl + Strings.profilePic!,
                          //     40.0,
                          //     40.0),
                          ))
                ],
                leading: SizedBox(
                  height: 25.0,
                  width: 25.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: 25.0,
                      color: const Color(0xFF979797),
                    ),
                    onPressed: () {
                      _controller?.toggle();
                    },
                  ),
                ),
              ),
              body: ProfileContent(),
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
      //Navigator.pop(context);
      //Navigator.popAndPushNamed(context, routename);
      Strings.isLogin = false;
      Navigator.popAndPushNamed(context, "/login");
    } else {
      //Navigator.pop(context);
      Navigator.pushNamed(context, routename!);
    }
  }
}

class ProfileContent extends StatefulWidget {
  @override
  _ProfileContentState createState() => _ProfileContentState();
}

Future<void> _showMyDialog(context, imgurl, title) async {
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
                width: MediaQuery.of(context).size.width * 0.75,
                // height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    new Icon(Icons.close, size: 22.0, color: Colors.black),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF0061b0),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: (Strings.profilePic != "")
                            ? NetworkImage(Strings.baseImageUrl +
                                (Strings.profilePic ?? ""))
                            : AssetImage("assets/icons/account.png")
                                as ImageProvider,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                      ),
                    )
                  ],
                ),
                // decoration: new BoxDecoration(
                //   color: Colors.transparent,
                //   image: new DecorationImage(
                //     image: new NetworkImage(imgurl),
                //     fit: BoxFit.contain,
                //   ),
                //   borderRadius:
                //       new BorderRadius.all(new Radius.circular(10.0)),
                // ),
              )),
        ),
      );
    },
  );
}

class _ProfileContentState extends State<ProfileContent> {
  @override
  void initState() {
    super.initState();
    AppUtils.showprogress();

    // WidgetsBinding.instance.addPostFrameCallback((_) => getProfile());
  }

  @override
  Widget build(BuildContext context) 
  {
    return Container(
        child: WebView(
      initialUrl: 'https://www.mtaarch.com/',
      javascriptMode: JavascriptMode.unrestricted,
      onPageFinished: (finish) {
        AppUtils.dismissprogress();
            },
    ));
  }
}
