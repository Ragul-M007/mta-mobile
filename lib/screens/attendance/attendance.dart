import 'dart:ui';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/AddAttendanceReq.dart';
import 'package:mta/models/FetchAttendanceRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/customcolor.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

FancyDrawerController _controller;

var now = DateTime.now();
var month = now.month.toString().padLeft(2, '0');
var day = now.day.toString().padLeft(2, '0');
var monthMatch = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];
String dropdownValue = monthMatch[int.parse(month) - 1];

class Attendance extends StatelessWidget {
  const Attendance({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: AttendanceContent(),
    );
  }
}

class AttendanceContent extends StatefulWidget {
  static const String routeName = "/attendance";
  @override
  _AttendanceContentState createState() => _AttendanceContentState();
}

class _AttendanceContentState extends State<AttendanceContent>
    with SingleTickerProviderStateMixin {
  CalendarController _calendarController;
  bool isgridView = true;
  List<AttendanceData> _attendance;

  void initState() {
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {
          Strings.currentmenuvalue = 2;
        });
      });
    _calendarController = CalendarController();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => getAttendance());
  }

  menuopen() {
    print("menuopen");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Material(
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
              backgroundColor:
                  isgridView ? Color(0xFF0061b0) : Colors.grey[300],
              appBar: mainappbar(
                  ontab: menuopen,
                  title: "Employee Attendance",
                  controller: _controller),
              body: isgridView
                  ? gridView()
                  : Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(child: Container()),
                                InkWell(
                                  child: Row(
                                    children: [
                                      Text("Grid View",
                                          style: Drawables.adddoccontentstyle(
                                              Colors.black87,
                                              14.0,
                                              FontWeight.w500)),
                                      SizedBox(width: 5.0),
                                      Icon(
                                        Icons.grid_view,
                                        color: Color(0xFF0061b0),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      isgridView = true;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              style: const TextStyle(color: Color(0xFF0061b0)),
                              underline: Container(
                                height: 3,
                                color: Color(0xFF0061b0),
                              ),
                              onChanged: (String newValue) {
                                setState(() {
                                  dropdownValue = newValue;
                                });
                              },
                              items: <String>[
                                "Jan",
                                "Feb",
                                "Mar",
                                "Apr",
                                "May",
                                "Jun",
                                "Jul",
                                "Aug",
                                "Sep",
                                "Oct",
                                "Nov",
                                "Dec"
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          _attendance != null
                              ? Expanded(
                                  child: ListView.builder(
                                    itemCount: 1,
                                    padding: EdgeInsets.all(5),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return new Padding(
                                          padding: EdgeInsets.all(5),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border(
                                                  left: BorderSide(
                                                    color: Colors.red,
                                                    width: 4.0,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                      width: 4,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                      )),
                                                  Container(
                                                    width: 110,
                                                    child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 15,
                                                                vertical: 35),
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      10.0),
                                                          child: Center(
                                                              child: Text(
                                                            "23 Feb \n Sun",
                                                            style: Drawables
                                                                .adddoccontentstyle(
                                                                    Colors
                                                                        .black87,
                                                                    14.0,
                                                                    FontWeight
                                                                        .w400),
                                                          )),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                          .grey[
                                                                      200]),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                        )),
                                                  ),
                                                  Expanded(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        RichText(
                                                          text: TextSpan(
                                                            text:
                                                                'Start Time -',
                                                            style: Drawables
                                                                .adddoccontentstyle(
                                                                    Colors
                                                                        .black54,
                                                                    13.0,
                                                                    FontWeight
                                                                        .w400),
                                                            children: <
                                                                TextSpan>[
                                                              TextSpan(
                                                                text: _attendance[
                                                                        0]
                                                                    .checkTime,
                                                                style: Drawables
                                                                    .adddoccontentstyle(
                                                                        Colors
                                                                            .black54,
                                                                        13.0,
                                                                        FontWeight
                                                                            .w700),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: 3.0),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.pin_drop,
                                                              color: Color(
                                                                  0xFF0061b0),
                                                              size: 16.0,
                                                            ),
                                                            SizedBox(
                                                                width: 5.0),
                                                            Text(
                                                                _attendance[0]
                                                                    .locationName,
                                                                style: Drawables
                                                                    .adddoccontentstyle(
                                                                        Colors
                                                                            .grey,
                                                                        12.0,
                                                                        FontWeight
                                                                            .w400)),
                                                          ],
                                                        ),
                                                        Icon(Icons.more_vert,
                                                            color: Colors.grey,
                                                            size: 14.0),
                                                        RichText(
                                                          text: TextSpan(
                                                            text: 'End Time -',
                                                            style: Drawables
                                                                .adddoccontentstyle(
                                                                    Colors
                                                                        .black54,
                                                                    13.0,
                                                                    FontWeight
                                                                        .w400),
                                                            children: <
                                                                TextSpan>[
                                                              TextSpan(
                                                                text: _attendance[
                                                                        1]
                                                                    .checkTime,
                                                                style: Drawables
                                                                    .adddoccontentstyle(
                                                                        Colors
                                                                            .black54,
                                                                        13.0,
                                                                        FontWeight
                                                                            .w700),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(height: 3.0),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.pin_drop,
                                                              color: Color(
                                                                  0xFF0061b0),
                                                              size: 16.0,
                                                            ),
                                                            Text(
                                                              _attendance[1]
                                                                  .locationName,
                                                              style: Drawables
                                                                  .adddoccontentstyle(
                                                                      Colors
                                                                          .grey,
                                                                      12.0,
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 3.0),
                                                        Text(
                                                          "9 Hrs",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF0061b0),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                                ],
                                              ),
                                            ),
                                          ));
                                    },
                                  ),
                                )
                              : SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                ),
                          bottombutton()
                        ],
                      ),
                    ),
            )),
      ),
    );
  }

  Widget bottombutton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
            onTap: () {
              checkInOut("IN");
            },
            child: Container(
              child: Center(
                child: Text(
                  "Check In",
                  style: Drawables.adddoccontentstyle(
                      Colors.white, 14.0, FontWeight.w600),
                ),
              ),
              decoration: BoxDecoration(
                color: CustomColors.primarycolor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0)),
              ),
            ),
          )),
          Expanded(
              child: GestureDetector(
            onTap: () {
              checkInOut("OUT");
            },
            child: Container(
              child: Center(
                child: Text(
                  "Check Out",
                  style: Drawables.adddoccontentstyle(
                      Colors.white, 14.0, FontWeight.w600),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius:
                    BorderRadius.only(topRight: Radius.circular(10.0)),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget gridView() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    InkWell(
                      child: Row(
                        children: [
                          Text(
                            "List View",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 5.0),
                          Icon(
                            Icons.list_sharp,
                            color: Colors.white,
                          )
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          isgridView = false;
                        });
                      },
                    )
                  ],
                ),
              ),
              Container(
                // color: Color.fromRGBO(36, 58, 142,1),
                child: TableCalendar(
                  rowHeight: 30,
                  calendarController: _calendarController,
                  startDay: DateTime.now(),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    centerHeaderTitle: true,
                    titleTextStyle: TextStyle(color: Colors.white),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white)),
                  calendarStyle: CalendarStyle(
                    weekendStyle: TextStyle(color: Colors.white),
                    outsideWeekendStyle: TextStyle(color: Colors.white),
                    todayStyle: TextStyle(
                      color: Colors.white,
                    ),
                    todayColor: Colors.white,
                    selectedColor: Colors.white,
                    selectedStyle: TextStyle(color: Colors.black),
                    weekdayStyle: TextStyle(color: Colors.white),
                    outsideDaysVisible: true,
                    outsideStyle: TextStyle(color: Colors.grey),
                  ),
                  onDaySelected: (day, events, holidays) {
                    print(day);
                    print(events);
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(
              0, MediaQuery.of(context).size.height * .45, 0, 0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: _attendance != null
                    ? ListView.builder(
                        itemCount: 1,
                        padding: EdgeInsets.all(5),
                        itemBuilder: (BuildContext context, int index) {
                          return new Padding(
                              padding: EdgeInsets.all(5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.red,
                                        width: 4.0,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                          )),
                                      Container(
                                        width: 110,
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 35),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10.0),
                                              child: Center(
                                                  child: Text(
                                                "23 Feb \n Sun",
                                                style: Drawables
                                                    .adddoccontentstyle(
                                                        Colors.black87,
                                                        14.0,
                                                        FontWeight.w400),
                                              )),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey[200]),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            )),
                                      ),
                                      Expanded(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                text: 'Start Time -',
                                                style: Drawables
                                                    .adddoccontentstyle(
                                                        Colors.black54,
                                                        13.0,
                                                        FontWeight.w400),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: _attendance[0]
                                                        .checkTime,
                                                    style: Drawables
                                                        .adddoccontentstyle(
                                                            Colors.black54,
                                                            13.0,
                                                            FontWeight.w700),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 3.0),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.pin_drop,
                                                  color: Color(0xFF0061b0),
                                                  size: 16.0,
                                                ),
                                                SizedBox(width: 5.0),
                                                Text(
                                                    _attendance[1].locationName,
                                                    style: Drawables
                                                        .adddoccontentstyle(
                                                            Colors.grey,
                                                            12.0,
                                                            FontWeight.w400)),
                                              ],
                                            ),
                                            Icon(Icons.more_vert,
                                                color: Colors.grey, size: 14.0),
                                            RichText(
                                              text: TextSpan(
                                                text: 'End Time -',
                                                style: Drawables
                                                    .adddoccontentstyle(
                                                        Colors.black54,
                                                        13.0,
                                                        FontWeight.w400),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: _attendance[1]
                                                        .checkTime,
                                                    style: Drawables
                                                        .adddoccontentstyle(
                                                            Colors.black54,
                                                            13.0,
                                                            FontWeight.w700),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 3.0),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.pin_drop,
                                                  color: Color(0xFF0061b0),
                                                  size: 16.0,
                                                ),
                                                Text(
                                                  _attendance[1].locationName,
                                                  style: Drawables
                                                      .adddoccontentstyle(
                                                          Colors.grey,
                                                          12.0,
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 3.0),
                                            Text(
                                              "9 Hrs",
                                              style: TextStyle(
                                                  color: Color(0xFF0061b0),
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ))
                                    ],
                                  ),
                                ),
                              ));
                        },
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.95,
                      ),
              ),
              bottombutton(),
            ],
          ),
        ),
      ],
    );
  }

  menuRedirect({@required String routename, int currentmenu}) {
    setState(() {
      Strings.currentmenuvalue = currentmenu;
    });
    if (routename == "/login") {
      AppUtils.clearAllPreferences();
      Navigator.popAndPushNamed(context, routename);
    } else {
      Navigator.pushNamed(context, routename);
    }
  }

  getAttendance() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);

    api.getAttendance(Strings.userID, "27-04-2021").then((response) {
      AppUtils.dismissprogress();
      print('Response status ${response.toJson()}');
      setState(() {
        if (response.data.length > 0) {
          _attendance = response.data;
        }
      });
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  checkInOut(action) {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    AddAttendanceReq req = AddAttendanceReq();
    req.checkTime = "2PM";
    req.checkType = action;
    req.latLng = "27.2046,77.4977";
    req.locationName = "Mulanur";
    api.addAttendance(req).then((response) {
      AppUtils.dismissprogress();
      print('Response status ${response.toJson()}');
      AppUtils.showToast(response.message);
      setState(() {});
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }
}
