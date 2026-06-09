import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mta/utilities/app_drawer.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/chat/ChatGroups.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart';

import '../../utilities/checkResponsive.dart';
import '../../utilities/circleImage.dart';

class Dashboard extends StatefulWidget {
  static const String routeName = "/dashboard";
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  BuildContext? ctx;

  List<Data> _projectLists = [];
  List<Data> _searchLists = [];
  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();
  WebViewController controller = WebViewController();
  String? filepath;
  var dio = Dio();

  String _errText = "No Projects Found";
  void initState() {
    super.initState();
    if (Strings.roleId == 7) {
      AppUtils.showprogress();
    }

    super.initState();
    getPermission();
    if (Strings.roleId != 7) {
      WidgetsBinding.instance.addPostFrameCallback((_) => getProjects());
    }
    configureWebview();
  }

  configureWebview() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            AppUtils.dismissprogress();
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse('https://www.mtaarch.com/'));
  }

  @override
  void dispose() {
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

    api.fetchProjectByTeams(Strings.selectedTeamId!).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        setState(() {
          print("messagee from api ${response.message}");
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
          Navigator.pushNamed(context, "/teamsDashboard");
          throw 'Screen Change';
        },
        child: Provider<ApiService>(
            create: (context) => ApiService.create(),
            child: SafeArea(
              child: Scaffold(
                  drawer: AppDrawer(),
                  backgroundColor: const Color(0xFFececed),
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    bottom: Strings.roleId != 7
                        ? PreferredSize(
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
                                            onChanged: (value) {
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
                            ))
                        : PreferredSize(
                            preferredSize: Size.zero, child: SizedBox()),
                    leading: SizedBox(
                      height: 25.0,
                      width: 25.0,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 25.0,
                          color: const Color(0xFF979797),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(ctx!, "/teamsDashboard");
                        },
                      ),
                    ),
                  ),
                  body: Builder(builder: (BuildContext newContext) {
                    print("check length ${_searchLists.length}");
                    ctx = newContext;
                    return Strings.roleId != 7
                        ? _projectLists.length > 0
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: 20, bottom: 20, left: 6, right: 6),
                                child: _searchLists.length != 0
                                    ? GridView.builder(
                                        itemCount: _searchLists.length,
                                        gridDelegate: Responsive.isMobile(context)
                                            ? SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 2,
                                                mainAxisSpacing: 8)
                                            : MediaQuery.of(context)
                                                        .orientation ==
                                                    Orientation.portrait
                                                ? SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                    crossAxisSpacing: 8,
                                                    mainAxisSpacing: 8)
                                                : SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 5,
                                                    crossAxisSpacing: 8,
                                                    mainAxisSpacing: 8),
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
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10, 10, 10, 10),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              _downloadfile(
                                                                  _searchLists[
                                                                          index]
                                                                      .projectImg,
                                                                  _searchLists[
                                                                          index]
                                                                      .projectName,
                                                                  _searchLists[
                                                                          index]
                                                                      .description,
                                                                  _searchLists[
                                                                          index]
                                                                      .status);
                                                            },
                                                            child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 10),
                                                                child: CircleImageFromNetwork(
                                                                    imageUrl: Strings
                                                                            .baseImageUrl +
                                                                        _searchLists[
                                                                                index]
                                                                            .projectImg!,
                                                                    width: 40,
                                                                    height: 40,
                                                                    defaultImageUrl:
                                                                        "assets/images/background1.png",
                                                                    radius: 20)),
                                                          ),
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 8),
                                                            child: IconButton(
                                                                icon: (_searchLists[index]
                                                                                .unReadedUserId !=
                                                                            null &&
                                                                        _searchLists[
                                                                                index]
                                                                            .unReadedUserId!
                                                                            .contains(Strings
                                                                                .userID
                                                                                .toString()))
                                                                    ? Image.asset(
                                                                        'assets/images/chat.png')
                                                                    : Image.asset(
                                                                        'assets/images/zerochat.png'),
                                                                onPressed: () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              ChatGroups(
                                                                        projectId:
                                                                            _searchLists[index]
                                                                                .projectId!,
                                                                        fromTeamProjects:
                                                                            true,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                          )
                                                        ],
                                                      )),
                                                ),
                                                footer: GestureDetector(
                                                  onTap: () {
                                                    onTapProject(
                                                        _searchLists[index]);
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
                                                          Container(
                                                              margin: EdgeInsets
                                                                  .fromLTRB(0, 12,
                                                                      0, 0),
                                                              child: Text(
                                                                  _searchLists[
                                                                          index]
                                                                      .status!,
                                                                  style: TextStyle(
                                                                      fontSize: 14,
                                                                      color: _searchLists[index].status! == "Active"
                                                                          ? Colors.lightGreen
                                                                          : _searchLists[index].status! == "Completed"
                                                                              ? Colors.green
                                                                              : _searchLists[index].status! == "Cancelled"
                                                                                  ? Colors.red
                                                                                  : Color.fromARGB(255, 216, 195, 3)))),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom: 5,
                                                                    right: 8),
                                                            child: Text(
                                                              _searchLists[index]
                                                                  .projectName!,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                width: 14.0,
                                                                height: 14.0,
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
                                                                          .all(
                                                                          new Radius
                                                                              .circular(
                                                                              50.0)),
                                                                ),
                                                              ),
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
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
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
                                            gridDelegate: Responsive.isMobile(
                                                    context)
                                                ? SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 2,
                                                    mainAxisSpacing: 8)
                                                : MediaQuery.of(context)
                                                            .orientation ==
                                                        Orientation.portrait
                                                    ? SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 4,
                                                        crossAxisSpacing: 8,
                                                        mainAxisSpacing: 8)
                                                    : SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 5,
                                                        crossAxisSpacing: 8,
                                                        mainAxisSpacing: 8),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  onTapProject(
                                                      _projectLists[index]);
                                                },
                                                child: new Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: new GridTile(
                                                    child: Container(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.fromLTRB(
                                                                  10, 10, 10, 10),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
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
                                                                            top:
                                                                                10),
                                                                    child: CircleImageFromNetwork(
                                                                        imageUrl: Strings
                                                                                .baseImageUrl +
                                                                            _projectLists[index]
                                                                                .projectImg!,
                                                                        width: 40,
                                                                        height:
                                                                            40,
                                                                        defaultImageUrl:
                                                                            "assets/images/background1.png",
                                                                        radius:
                                                                            20)),
                                                              ),
                                                              Container(
                                                                width: 40,
                                                                height: 40,
                                                                margin: EdgeInsets
                                                                    .only(top: 8),
                                                                child: IconButton(
                                                                    icon: (_projectLists[index].unReadedUserId !=
                                                                                null &&
                                                                            _projectLists[index].unReadedUserId!.contains(Strings
                                                                                .userID
                                                                                .toString()))
                                                                        ? Image.asset(
                                                                            'assets/images/chat.png')
                                                                        : Image.asset(
                                                                            'assets/images/zerochat.png'),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder:
                                                                              (context) =>
                                                                                  ChatGroups(
                                                                            projectId:
                                                                                _projectLists[index].projectId!,
                                                                            fromTeamProjects:
                                                                                true,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }),
                                                              )
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
                                                              Container(
                                                                  margin: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          12,
                                                                          0,
                                                                          0),
                                                                  child: Text(
                                                                      _projectLists[
                                                                              index]
                                                                          .status!,
                                                                      style: TextStyle(
                                                                          fontSize: 14,
                                                                          color: _projectLists[index].status! == "Active"
                                                                              ? Colors.lightGreen
                                                                              : _projectLists[index].status! == "Completed"
                                                                                  ? Colors.green
                                                                                  : _projectLists[index].status! == "Cancelled"
                                                                                      ? Colors.red
                                                                                      : Color.fromARGB(255, 216, 195, 3)))),
                                                              Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        bottom: 5,
                                                                        right: 8),
                                                                child: Text(
                                                                  _projectLists[
                                                                          index]
                                                                      .projectName!,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 2,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ),
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    width: 14.0,
                                                                    height: 14.0,
                                                                    decoration:
                                                                        new BoxDecoration(
                                                                      image:
                                                                          new DecorationImage(
                                                                        image: new AssetImage(
                                                                            "assets/icons/pin.png"),
                                                                        fit: BoxFit
                                                                            .fill,
                                                                      ),
                                                                      borderRadius: new BorderRadius
                                                                          .all(
                                                                          new Radius
                                                                              .circular(
                                                                              50.0)),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: 5),
                                                                  Expanded(
                                                                    child: Text(
                                                                      _projectLists[index]
                                                                              .address! +
                                                                          ' , ' +
                                                                          _projectLists[index]
                                                                              .city!,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .clip,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10,
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .w400,
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
                                ))
                        : Container(child: WebViewWidget(controller: controller));
                  })),
            )));
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
    try {
      return Container(
        width: width,
        height: height,
        decoration: new BoxDecoration(
          color: const Color(0xff7c94b6),
          image: new DecorationImage(
            image: NetworkImage(img),
            fit: BoxFit.fill,
          ),
          borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
        ),
      );
    } catch (err) {
      return Container(
        width: width,
        height: height,
        decoration: new BoxDecoration(
          color: const Color(0xff7c94b6),
          image: new DecorationImage(
            image: new AssetImage("assets/images/logo.jpeg"),
            fit: BoxFit.fill,
          ),
          borderRadius: new BorderRadius.all(new Radius.circular(50.0)),
        ),
      );
    }
  }

  void getPermission() async {
    print("getPermission");
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

  Future<void> openFile(filePath) async {
    print(filePath);
    final _result = await OpenFilex.open(filePath);
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
