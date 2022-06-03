import 'dart:io';
import 'dart:ui';

import 'package:ext_storage/ext_storage.dart';
import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';

class Dashboard extends StatefulWidget {
  static const String routeName = "/dashboard";
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  FancyDrawerController? _controller;

  BuildContext? ctx;

  List<Data> _projectLists = [];
  List<Data> _searchLists = [];
  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();
  String? filepath;
  var dio = Dio();

  String _errText = "";
  void initState() {
    super.initState();
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 100))
      ..addListener(() {
        setState(() {
          // print(Strings.authToken);
          Strings.currentmenuvalue = 1;
        });
      });
    super.initState();
    getPermission();
    WidgetsBinding.instance!.addPostFrameCallback((_) => getProjects());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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

  getProjects() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(ctx!, listen: false);

    api.projects(Strings.userID!).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        setState(() {
          _projectLists = response.data!;
        });
        if (Strings.isPushAvailable == true) {
          Strings.isPushAvailable = false;
          getUserCats(Strings.selectedProject[0].projectId);
        }
      } else {
        setState(() {
          // _errText = "No Projects found !";
          _errText = response.message!;
        });
        // if (response.message != null) {
        //   AppUtils.showToastError(response.message);
        // }
        if (Strings.isPushAvailable == true) {
          Strings.isPushAvailable = false;
          getUserCats(Strings.selectedProject[0].projectId);
        }
        // else {
        //   AppUtils.showToastError("No Projects found !");
        // }
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
      //getProjects();
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
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
              'Do you want to exit an App',
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
                onPressed: () => exit(0),
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
        )) ??
        false;
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onWillPop();
        return false;
      },
      child: Provider<ApiService>(
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
                          menuRedirect(
                              routename: "/attendance", currentmenu: 2);
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
                              backgroundImage: (
                                  Strings.profilePic !=
                                      "")
                              ? NetworkImage(Strings.baseImageUrl +
                                  (Strings.profilePic ??
                                      ""))
                              :  AssetImage("assets/icons/account.png",)
                                      as ImageProvider,
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
                    bottom: PreferredSize(
                        preferredSize: Size.fromHeight(kToolbarHeight),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Container(
                            //  padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: const Color(0xFFeceeef),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Material(
                                color: const Color(0xFFeceeef),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        focusNode: searchField,
                                        controller: _searchFieldController,
                                        decoration: InputDecoration.collapsed(
                                          hintText: ' Search',
                                        ),
                                        onChanged: (value) 
                                        {
                                          if (value.isEmpty) {
                                            setState(() {
                                              _searchLists = [];
                                            });
                                            return;
                                          }
                                          _searchLists = [];
                                          _projectLists
                                              .forEach((projectDetail) {
                                            if (projectDetail.projectName!
                                                .toLowerCase()
                                                .startsWith(
                                                    value.toLowerCase()))
                                              _searchLists.add(projectDetail);
                                            
                                          });
                                          print(_searchLists.length);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.black,
                                      ),
                                      onTap: () {},
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
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
                          searchField.unfocus();
                          _controller?.toggle();
                        },
                      ),
                    ),
                  ),
                  body: Builder(builder: (BuildContext newContext) {
                    ctx = newContext;
                    return _projectLists.length > 0
                        ? Padding(
                            padding: EdgeInsets.all(20),
                            child: _searchLists.length != 0
                                ? GridView.builder(
                                    itemCount: _searchLists.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          onTapProject(_searchLists[index]);
                                        },
                                        child: new Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: new GridTile(
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      10, 10, 10, 0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          _downloadfile(
                                                              _projectLists[
                                                                      index]
                                                                  .projectImg,
                                                              _projectLists[
                                                                      index]
                                                                  .projectName,
                                                              _projectLists[
                                                                      index]
                                                                  .description,
                                                              _projectLists[
                                                                      index]
                                                                  .status);
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10),
                                                          child: image(
                                                              Strings.baseImageUrl +
                                                                  _searchLists[
                                                                          index]
                                                                      .projectImg!,
                                                              65.0,
                                                              65.0),
                                                        ),
                                                      ),
                                                      Container()
                                                    ],
                                                  )),
                                            ),
                                            footer: GestureDetector(
                                              onTap: () {
                                                onTapProject(
                                                    _searchLists[index]);
                                              },
                                              child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      10, 10, 0, 20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5),
                                                        child: Text(
                                                          _searchLists[index]
                                                              .projectName!,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Icon(Icons.pin_drop,
                                                              color: Color(
                                                                  0xFF0061b0)),
                                                          SizedBox(width: 5),
                                                          Expanded(
                                                            child: Text(
                                                              _searchLists[
                                                                          index]
                                                                      .address! +
                                                                  ' , ' +
                                                                  _searchLists[
                                                                          index]
                                                                      .city!,
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  )),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : _searchFieldController.text != ""
                                    ? Align(
                                        alignment: Alignment.topCenter,
                                        child: Text(
                                          "No results found",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )
                                    : GridView.builder(
                                        itemCount: _projectLists.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return GestureDetector(
                                            onTap: () {
                                              onTapProject(
                                                  _projectLists[index]);
                                            },
                                            child: new Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              child: new GridTile(
                                                child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10, 10, 10, 10),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              _downloadfile(
                                                                  _projectLists[
                                                                          index]
                                                                      .projectImg,
                                                                  _projectLists[
                                                                          index]
                                                                      .projectName,
                                                                  _projectLists[
                                                                          index]
                                                                      .description,
                                                                  _projectLists[
                                                                          index]
                                                                      .status);
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 10),
                                                              child: image(
                                                                  Strings.baseImageUrl +
                                                                      _projectLists[
                                                                              index]
                                                                          .projectImg!,
                                                                  65.0,
                                                                  65.0),
                                                            ),
                                                          ),
                                                          Container()
                                                        ],
                                                      )),
                                                ),
                                                footer: GestureDetector(
                                                  onTap: () {
                                                    onTapProject(
                                                        _projectLists[index]);
                                                  },
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10, 0, 0, 20),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 5),
                                                            child: Text(
                                                              _projectLists[
                                                                      index]
                                                                  .projectName!,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Container(
                                                                width: 20.0,
                                                                height: 20.0,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  image:
                                                                      new DecorationImage(
                                                                    image: new AssetImage(
                                                                        "assets/icons/pin.png"),
                                                                    fit: BoxFit
                                                                        .fill,
                                                                  ),
                                                                  borderRadius:
                                                                      new BorderRadius
                                                                          .all(new Radius
                                                                              .circular(
                                                                          50.0)),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 5),
                                                              Expanded(
                                                                child: Text(
                                                                  _projectLists[
                                                                              index]
                                                                          .address! +
                                                                      ' , ' +
                                                                      _projectLists[
                                                                              index]
                                                                          .city!,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      )),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          )
                        : Container(
                            height: MediaQuery.of(context).size.height * .75,
                            child: Padding(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _errText,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(20),
                            ));
                  }))),
        ),
      ),
    );
  }

  onTapProject(Data projectList) {
    Strings.selectedProject = [];
    Strings.selectedProject.add(projectList);
    Navigator.pushNamed(context, '/categories');
  }

  menuRedirect({@required String? routename, int? currentmenu}) {
    setState(() {
      Strings.currentmenuvalue = currentmenu!;
    });
    if (routename == "/login") {
      //AppUtils.clearAllPreferences();
      //Navigator.pop(context);
      Strings.isLogin = false;
      Navigator.popAndPushNamed(context, "/login");
    } else {
      //Navigator.pop(context);
      Navigator.pushNamed(context, routename!);
    }
  }

  Widget image(String img, double width, double height) {
    try
    {
        return Container(
      width: width,
      height: height,
      decoration: new BoxDecoration(
        color: const Color(0xff7c94b6),
        
          image: new DecorationImage(
          image: 
            NetworkImage(img)
            ,
          fit: BoxFit.fill,
        )
        ,
        borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
      ),
    );
    }
    catch(err)
    {
      return Container(
      width: width,
      height: height,
      decoration: new BoxDecoration(
        color: const Color(0xff7c94b6),
        
          image: new DecorationImage(
          image: new AssetImage("assets/images/logo.jpeg"),
          fit: BoxFit.fill,
        )
        ,
        borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
      ),
    );
    }
    
    
  }

  void getPermission() async {
    // print("getPermission");
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    //await Permission.storage.request();
    // await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  void _downloadfile(serverURL, title, desc, status) async {
    _showMyDialogProject(
        context, Strings.baseImageUrl + serverURL, title, desc, status);
  }

  Future<void> _showMyDialogProject(
      context, imgurl, title, desc, status) async {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        new Icon(Icons.close, size: 22.0, color: Colors.black)
                      ]),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Status : " + status,
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0061b0),
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: new BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: new DecorationImage(
                              image: new NetworkImage(imgurl),
                              fit: BoxFit.fill,
                            ),
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(5.0)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Description : " + desc,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
          ),
        );
      },
    );
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
                                backgroundImage: (
                                    Strings.profilePic !=
                                        "")
                                ? NetworkImage(Strings.baseImageUrl +
                                    (Strings.profilePic ??
                                        ""))
                                :  AssetImage("assets/icons/account.png")
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

  Future<void> openFile(filePath) async {
    print(filePath);
    final _result = await OpenFile.open(filePath);
  }

  Future<String> downloadFile(String url, String fileName, String dir) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    try {
      myUrl = Strings.baseImageUrl + url;
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      print(myUrl);
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else
        filePath = 'Error code: ' + response.statusCode.toString();
    } catch (ex) {
      filePath = 'Can not fetch url';
    }

    return filePath;
  }
}
