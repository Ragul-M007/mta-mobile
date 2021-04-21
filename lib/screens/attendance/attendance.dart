import 'dart:ui';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:table_calendar/table_calendar.dart';

class Attendance extends StatefulWidget {
  static const String routeName = "/attendance";
  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance>
    with SingleTickerProviderStateMixin {
  FancyDrawerController _controller;
  CalendarController _calendarController;
  bool isgridView = false;

  int selectedMenu = 2;
  void initState() {
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {});
      });
    _calendarController = CalendarController();
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => getLocation());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0061b0),
        ),
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
                      decoration: new BoxDecoration(
                        color: const Color(0xff7c94b6),
                        image: new DecorationImage(
                          image: new AssetImage("assets/images/logo.jpeg"),
                          fit: BoxFit.fill,
                        ),
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(50.0)),
                      ),
                    ),
                    // CircleAvatar(
                    //   child: Image(
                    //     image: new AssetImage("assets/images/logo.jpeg"),
                    //   ),
                    // ),
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
              InkWell(
                onTap: () {
                  menuRedirect("1");
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selectedMenu == 1
                        ? const Color(0XFF1c72b9)
                        : const Color(0xFF0061b0),
                  ),
                  padding: EdgeInsets.fromLTRB(30, 8, 0, 8),
                  child: Text(
                    "Projects",
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedMenu == 1
                          ? Colors.white
                          : const Color(0xFF519bd7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  menuRedirect("2");
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selectedMenu == 2
                        ? const Color(0XFF1c72b9)
                        : const Color(0xFF0061b0),
                  ),
                  padding: EdgeInsets.fromLTRB(30, 8, 0, 8),
                  child: Text(
                    "Attendance",
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedMenu == 2
                          ? Colors.white
                          : const Color(0xFF519bd7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  menuRedirect("3");
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selectedMenu == 3
                        ? const Color(0XFF1c72b9)
                        : const Color(0xFF0061b0),
                  ),
                  padding: EdgeInsets.fromLTRB(30, 8, 0, 8),
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedMenu == 3
                          ? Colors.white
                          : const Color(0xFF519bd7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  menuRedirect("4");
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selectedMenu == 4
                        ? const Color(0XFF1c72b9)
                        : const Color(0xFF0061b0),
                  ),
                  padding: EdgeInsets.fromLTRB(30, 8, 0, 8),
                  child: Text(
                    "Notification",
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedMenu == 4
                          ? Colors.white
                          : const Color(0xFF519bd7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  menuRedirect("5");
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selectedMenu == 5
                        ? const Color(0XFF1c72b9)
                        : const Color(0xFF0061b0),
                  ),
                  padding: EdgeInsets.fromLTRB(30, 8, 0, 8),
                  child: Text(
                    "Contact Us",
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedMenu == 5
                          ? Colors.white
                          : const Color(0xFF519bd7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  menuRedirect("6");
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selectedMenu == 6
                        ? const Color(0XFF1c72b9)
                        : const Color(0xFF0061b0),
                  ),
                  padding: EdgeInsets.fromLTRB(30, 8, 0, 8),
                  child: Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedMenu == 6
                          ? Colors.white
                          : const Color(0xFF519bd7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  menuRedirect("7");
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selectedMenu == 7
                        ? const Color(0XFF1c72b9)
                        : const Color(0xFF0061b0),
                  ),
                  padding: EdgeInsets.fromLTRB(30, 8, 0, 8),
                  child: Text(
                    "News & Highlights",
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedMenu == 7
                          ? Colors.white
                          : const Color(0xFF519bd7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  menuRedirect("8");
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selectedMenu == 8
                        ? const Color(0XFF1c72b9)
                        : const Color(0xFF0061b0),
                  ),
                  padding: EdgeInsets.fromLTRB(30, 8, 0, 8),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedMenu == 8
                          ? Colors.white
                          : const Color(0xFF519bd7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  menuRedirect("9");
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selectedMenu == 9
                        ? const Color(0XFF1c72b9)
                        : const Color(0xFF0061b0),
                  ),
                  padding: EdgeInsets.fromLTRB(30, 8, 0, 8),
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 17,
                      color: selectedMenu == 9
                          ? Colors.white
                          : const Color(0xFF519bd7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
            child: Scaffold(
              backgroundColor: isgridView ? Colors.blue : Colors.grey[300],
              appBar: AppBar(
                title: Text("Employee attendance"),
                leading: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    _controller.toggle();
                  },
                ),
              ),
              body: isgridView
                  ? gridView()
                  : Padding(
                      padding: EdgeInsets.all(5),
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
                                      Text("Grid View"),
                                      Icon(
                                        Icons.grid_view,
                                        color: Colors.blue,
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
                            child: Text("dropdown button"),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: 10,
                              padding: EdgeInsets.all(5),
                              itemBuilder: (BuildContext context, int index) {
                                return new Padding(
                                    padding: EdgeInsets.all(5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Container(
                                        height: 150,
                                        color: Colors.white,
                                        child: Row(
                                          children: [
                                            Container(
                                                width: 10,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                )),
                                            Container(
                                              width: 110,
                                              child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 35),
                                                  child: Container(
                                                    child: Center(
                                                        child: Text(
                                                      "23 Feb \n Sun",
                                                    )),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                  )),
                                            ),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      text: 'Start Time -',
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style,
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: ' 9:30 AM',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.pin_drop,
                                                        color: Colors.blue,
                                                      ),
                                                      Text(
                                                          "Gandhipuram, coimbatore",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 13)),
                                                    ],
                                                  ),
                                                  Icon(Icons.more_vert),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: 'End Time -',
                                                      style:
                                                          DefaultTextStyle.of(
                                                                  context)
                                                              .style,
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: ' 9:30 AM',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.pin_drop,
                                                        color: Colors.blue,
                                                      ),
                                                      Text(
                                                        "Gandhipuram, coimbatore",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    "9 Hrs",
                                                    style: TextStyle(
                                                        color: Colors.blue),
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
                        ],
                      ),
                    ),
            )),
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
                          Text("LisView View"),
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
                  rowHeight: 35,
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
                    weekendStyle: TextStyle(color: Colors.red),
                    outsideWeekendStyle: TextStyle(color: Colors.red),
                    todayStyle: TextStyle(
                      color: Colors.white,
                    ),
                    todayColor: Colors.black,
                    selectedColor: Colors.red,
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
              0, MediaQuery.of(context).size.height * .50, 0, 0),
          width: double.infinity,
          // height:MediaQuery.of(context).size.height * .5 ,
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
                child: ListView.builder(
                  itemCount: 10,
                  padding: EdgeInsets.all(5),
                  itemBuilder: (BuildContext context, int index) {
                    return new Padding(
                        padding: EdgeInsets.all(5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Container(
                            height: 130,
                            color: Colors.white,
                            child: Row(
                              children: [
                                Container(
                                    width: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                    )),
                                Container(
                                  width: 110,
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 35),
                                      child: Container(
                                        child: Center(
                                            child: Text(
                                          "23 Feb \n Sun",
                                        )),
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(10)),
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
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: ' 9:30 AM',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.pin_drop,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          Text("Gandhipuram, coimbatore",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13)),
                                        ],
                                      ),
                                      Icon(
                                        Icons.more_vert,
                                        size: 20,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'End Time -',
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: ' 9:30 AM',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.pin_drop,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          Text(
                                            "Gandhipuram, coimbatore",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "9 Hrs",
                                        style: TextStyle(color: Colors.blue),
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
              ),
              Container(
                width: double.infinity,
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                      child: Center(
                        child: Text("Check out"),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(10.0)),
                      ),
                    )),
                    Expanded(
                        child: Container(
                      child: Center(
                        child: Text("Check in"),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius:
                            BorderRadius.only(topRight: Radius.circular(10.0)),
                      ),
                    )),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  menuRedirect(option) {
    selectedMenu = int.parse(option);
    if (option == "1") {
      Navigator.pushNamed(context, "/dashboard");
    } else if (option == "2") {
      Navigator.pushNamed(context, "/attendance");
    } else if (option == "3") {
      Navigator.pushNamed(context, "/profile");
    } else if (option == "4") {
      Navigator.pushNamed(context, "/notification");
    } else if (option == "5") {
      Navigator.pushNamed(context, "/contactus");
    } else if (option == "6") {
      Navigator.pushNamed(context, "/privacypolicy");
    } else if (option == "7") {
      Navigator.pushNamed(context, "/news");
    } else if (option == "8") {
      Navigator.pushNamed(context, "/settings");
    } else if (option == "9") {
      AppUtils.clearAllPreferences();
      Navigator.popAndPushNamed(context, "/login");
    }
  }
}
