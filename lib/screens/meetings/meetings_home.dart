// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/models/MeetingsDataRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/dashboard/teamsDashboard.dart';
import 'package:mta/screens/meetings/create_meeting.dart';
import 'package:mta/screens/meetings/meeting_details.dart';
import 'package:mta/screens/meetings/meeting_history.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/customcolor.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

FancyDrawerController? _controller;

class Meetings extends StatelessWidget {
  const Meetings({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: Meetingscontent(),
    );
  }
}

class Meetingscontent extends StatefulWidget {
  static const String routeName = "/meetings";
  const Meetingscontent({super.key});

  @override
  State<Meetingscontent> createState() => _MeetingscontentState();
}

class _MeetingscontentState extends State<Meetingscontent>
    with SingleTickerProviderStateMixin {
  List<MeetingsData> tempLists = [];
  List<MeetingsData> meetingsData = [];

  bool meetingCraetionAccess = false;

  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();

  void initState() {
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {
          Strings.currentmenuvalue = 2;
        });
      });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getProfile());
  }

  getProfile() {
    AppUtils.showprogress();

    getMeetings();
    final api = Provider.of<ApiService>(context, listen: false);
    api.getMeetingAccess(Strings.userID!).then((response) {
      AppUtils.dismissprogress();
      print('profileResponse status ${response.data}');
      meetingCraetionAccess = response.data!.access!;
      setState(() {});
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  getMeetings() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final formattedDate = formatter.format(now);
    final api = Provider.of<ApiService>(context, listen: false);
    api.getUpcomingMeeting(formattedDate).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        setState(() {
          tempLists = response.data ?? [];
        });
      }else{
       setState(() {
          tempLists = [];
        });
      }
      print(">>>:${tempLists}");
      meetingsData = tempLists;
      setState(() {});
    }).catchError((onError) {
      // AppUtils.dismissprogress();
      print(onError.toString());
      //getProjects();
    });
  }

  // void dispose() {
  //   super.dispose();
  //   Strings.fromNotificationNewMeeting = false;
  // }

  @override
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
                  menuoption(
                    ontab: () {
                      Strings.fromProjects = false;
                      menuRedirect(
                          routename: "/teamsDashboard", currentmenu: 1);
                    },
                    selectedmenuvalue: 1,
                    menutitle: "Teams",
                  ),
                  menuoption(
                    ontab: () {
                      menuRedirect(routename: "/meetings", currentmenu: 2);
                    },
                    selectedmenuvalue: 2,
                    menutitle: "Meetings",
                  ),
                  menuoption(
                    ontab: () {
                      Strings.fromProjects = true;
                      menuRedirect(routename: "/projects", currentmenu: 3);
                    },
                    selectedmenuvalue: 3,
                    menutitle: "Projects",
                  ),
                  menuoption(
                    ontab: () {
                      menuRedirect(routename: "/attendance", currentmenu: 4);
                    },
                    selectedmenuvalue: 4,
                    menutitle: "Attendance",
                  ),
                  menuoption(
                    ontab: () {
                      menuRedirect(routename: "/profile", currentmenu: 5);
                    },
                    selectedmenuvalue: 5,
                    menutitle: "Profile",
                  ),
                  menuoption(
                    ontab: () {
                      menuRedirect(routename: "/notification", currentmenu: 6);
                    },
                    selectedmenuvalue: 6,
                    menutitle: "Notification",
                  ),
                  menuoption(
                    ontab: () {
                      menuRedirect(routename: "/contactus", currentmenu: 7);
                    },
                    selectedmenuvalue: 7,
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
                      menuRedirect(
                          routename: "/newshighlights", currentmenu: 8);
                    },
                    selectedmenuvalue: 8,
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
                                AppUtils.savePreferences("easyAccess", "N");
                                menuRedirect(
                                    routename: "/login", currentmenu: 9);
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
                child: WillPopScope(
                  onWillPop: () {
                    if (Strings.fromNotificationNewMeeting) {
                      Strings.fromNotificationNewMeeting = false;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamsDashboard(),
                        ),
                        (route) => false,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                    throw '';
                  },
                  child: Scaffold(
                    backgroundColor: Colors.grey[300],
                    appBar: AppBar(
                      iconTheme: IconThemeData(color: Colors.black),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.0))),
                      elevation: 3,
                      title: Text(
                        "Meetings",
                        style: Drawables.adddoccontentstyle(
                            Colors.black, 16.0, FontWeight.bold),
                      ),
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
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => MeetingHistory()));
                              },
                              icon: Icon(
                                Icons.history,
                                size: 25.0,
                                // color: const Color(0xFF979797),
                              )),
                        )
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
                                          onChanged: (search) {
                                            if (tempLists.isNotEmpty) {
                                              setState(() {
                                                meetingsData = tempLists
                                                    .where((user) => user.title!
                                                        .toLowerCase()
                                                        .contains(search
                                                            .toLowerCase()))
                                                    .toList();
                                              });
                                            }
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
                    ),
                    floatingActionButton: meetingCraetionAccess
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => CreateMeeting(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              child: Image.asset(
                                "assets/icons/gridicons_create.png",
                                height: 20,
                              ),
                              backgroundColor:
                                  CustomColors.appthemecolor.withOpacity(0.8),
                            ),
                          )
                        : Container(),
                    body: meetingsData.length > 0
                        ? ListView.builder(
                            itemCount: meetingsData.length,
                            padding: EdgeInsets.all(20),
                            itemBuilder: (BuildContext ctx, int index) {
                              return Padding(
                                padding: EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                MeetingDetails(
                                                    fromHistory: false,
                                                    meeting_id:
                                                        meetingsData[index]
                                                            .meetingId!)))
                                        .whenComplete(() => getMeetings());
                                  },
                                  child: Container(
                                    height: 60,
                                    child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(14, 4, 15, 4),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.53,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          meetingsData[index]
                                                              .title!,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: Drawables
                                                              .adddoccontentstyle(
                                                                  Colors
                                                                      .black87,
                                                                  14.0,
                                                                  FontWeight
                                                                      .w400)),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              AppUtils().getMeetingDateFormat(
                                                                  meetingsData[
                                                                          index]
                                                                      .start!,
                                                                  meetingsData[
                                                                          index]
                                                                      .end!,
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: Drawables
                                                                  .adddoccontentstyle(
                                                                      CustomColors
                                                                          .meetingSubtitleFontColor,
                                                                      12.0,
                                                                      FontWeight
                                                                          .w400)),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width <
                                                                  376
                                                              ? Container()
                                                              : Icon(
                                                                  Icons
                                                                      .schedule,
                                                                  size: 14,
                                                                  color: CustomColors
                                                                      .meetingSubtitleFontColor,
                                                                )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: 75,
                                              height: 30,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      CustomColors.primarycolor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  launchLink(meetingsData[index]
                                                              .type ==
                                                          "1"
                                                      ? meetingsData[index]
                                                          .location!
                                                      : meetingsData[index]
                                                          .meetingLink!);
                                                },
                                                child: (meetingsData[index]
                                                            .type !=
                                                        "1")
                                                    ? Text(
                                                        'JOIN',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                Platform.isIOS
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .w700,
                                                            fontSize: 12,
                                                            color:
                                                                Colors.white),
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .directions_outlined,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                              ),
                                            ),
                                          ],
                                        )),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            })
                        : Center(child: Text("No Meetings Found")),
                  ),
                ))));
  }

  menuRedirect({@required String? routename, int? currentmenu}) {
    setState(() {
      if (currentmenu != null) Strings.currentmenuvalue = currentmenu;
    });
    if (routename == "/login") {
      //AppUtils.clearAllPreferences();
      Strings.isLogin = false;
      Navigator.popAndPushNamed(context, "/login");
      // Navigator.popAndPushNamed(context, routename);
    } else {
      Navigator.pushNamed(context, routename!);
    }
  }

  launchLink(String url) async {
    if (url != null && Strings.urlRegex.hasMatch(url)) {
      if (!await launchUrl(Uri.parse(url))) {
        throw Exception('Could not launch $url');
      }
    } else {
      AppUtils.showToastError("Invalid URL");
    }
  }
}
