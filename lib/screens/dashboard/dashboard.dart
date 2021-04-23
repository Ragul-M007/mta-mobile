import 'dart:ui';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  static const String routeName = "/dashboard";
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  FancyDrawerController _controller;

  BuildContext ctx;

  List<Data> _projectLists = [];
  List<Data> _searchLists = [];
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
    WidgetsBinding.instance.addPostFrameCallback((_) => getProjects());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  getProjects() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(ctx, listen: false);

    api.projects().then((response) {
      AppUtils.dismissprogress();
      //print('projectResponse status ${response.toJson()}');

      if (response.status) {
        // Navigator.pushNamed(ctx, "/dashboard");
        setState(() {
          _projectLists = response.data;
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
      //getProjects();
    });
  }

  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: Container(
        decoration:
            Drawables.menudecorationImage("assets/images/Menubg.png", 0.0),
        child: FancyDrawerWrapper(
            backgroundColor: Colors.transparent,
            controller: _controller,
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
                            "assets/images/logo.jpeg", 50.0)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "MTA Architects",
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
              menuoption(
                ontab: () {
                  menuRedirect(routename: "/attendance", currentmenu: 2);
                },
                selectedmenuvalue: 2,
                menutitle: "Attendance",
              ),
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
              menuoption(
                ontab: () {
                  menuRedirect(routename: "/privacypolicy", currentmenu: 6);
                },
                selectedmenuvalue: 6,
                menutitle: "Privacy Policy",
              ),
              menuoption(
                ontab: () {
                  menuRedirect(routename: "/dashboard", currentmenu: 7);
                },
                selectedmenuvalue: 7,
                menutitle: "News & Highlights",
              ),
              menuoption(
                ontab: () {
                  menuRedirect(routename: "/settings", currentmenu: 8);
                },
                selectedmenuvalue: 8,
                menutitle: "Settings",
              ),
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
                        child: image(Strings.baseImageUrl + Strings.profilePic,
                            40.0, 40.0))
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
                                      decoration: InputDecoration.collapsed(
                                        hintText: ' Search',
                                      ),
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          setState(() {
                                            _searchLists = [];
                                          });
                                          return;
                                        }
                                        _searchLists = [];
                                        _projectLists.forEach((projectDetail) {
                                          if (projectDetail.projectName
                                              .contains(value))
                                            _searchLists.add(projectDetail);
                                        });

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
                        _controller.toggle();
                      },
                    ),
                  ),
                ),
                body: Builder(builder: (BuildContext newContext) {
                  ctx = newContext;
                  return _projectLists != null
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10),
                                                      child: image(
                                                          Strings.baseImageUrl +
                                                              _searchLists[
                                                                      index]
                                                                  .projectImg,
                                                          65.0,
                                                          65.0),
                                                    ),
                                                    Container()
                                                  ],
                                                )),
                                          ),
                                          footer: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 10, 0, 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: Text(
                                                      _searchLists[index]
                                                          .projectName,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Icon(Icons.pin_drop,
                                                          color: Color(
                                                              0xFF0061b0)),
                                                      SizedBox(width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          _searchLists[index]
                                                                  .address +
                                                              ' , ' +
                                                              _searchLists[
                                                                      index]
                                                                  .city,
                                                          overflow:
                                                              TextOverflow.clip,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )),
                                        ),
                                      ),
                                    );
                                  },
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
                                        onTapProject(_projectLists[index]);
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
                                                    10, 10, 10, 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 10),
                                                      child: image(
                                                          Strings.baseImageUrl +
                                                              _projectLists[
                                                                      index]
                                                                  .projectImg,
                                                          65.0,
                                                          65.0),
                                                    ),
                                                    Container()
                                                  ],
                                                )),
                                          ),
                                          footer: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 0, 0, 20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: Text(
                                                      _projectLists[index]
                                                          .projectName,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
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
                                                            fit: BoxFit.fill,
                                                          ),
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .all(new Radius
                                                                      .circular(
                                                                  50.0)),
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          _projectLists[index]
                                                                  .address +
                                                              ' , ' +
                                                              _projectLists[
                                                                      index]
                                                                  .city,
                                                          overflow:
                                                              TextOverflow.clip,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        )
                      : SizedBox();
                }))),
      ),
    );
  }

  onTapProject(Data projectList) {
    Strings.selectedProject = [];
    Strings.selectedProject.add(projectList);
    Navigator.pushNamed(context, '/categories');
  }

  menuRedirect({@required String routename, int currentmenu}) {
    setState(() {
      Strings.currentmenuvalue = currentmenu;
    });
    if (routename == "/login") {
      AppUtils.clearAllPreferences();
      //Navigator.pop(context);
      Navigator.popAndPushNamed(context, routename);
    } else {
      //Navigator.pop(context);
      Navigator.pushNamed(context, routename);
    }
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
}
