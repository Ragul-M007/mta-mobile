import 'dart:ffi';
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
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/services/base.dart';
import 'package:mta/models/FetchAttendenceChangedRes.dart';

FancyDrawerController? _controller;

double lat = 0.00;
double long = 0.00;
String location = '';
var now = DateTime.now();
var month = now.month.toString().padLeft(2, '0');
var day = now.day.toString().padLeft(2, '0');
var year = now.year.toString();
DateTime _focusedDay = DateTime.now();
DateTime? _selectedDay;
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
  const Attendance({Key? key}) : super(key: key);

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
 // CalendarController _calendarController;
  bool isgridView = true;
  bool isShowCheckInOut = true;
  List<AttendanceDataNew> _attendance = [];
  List<AttendanceData> _attendancemain = [];

  void initState() {
    _controller = FancyDrawerController(
        vsync: this, duration: Duration(milliseconds: 250))
      ..addListener(() {
        setState(() {
          Strings.currentmenuvalue = 2;
        });
      });
    //_calendarController = CalendarController();
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => getAttendance(day + "-" + month + "-" + year));
  }

  menuopen() {
    print("menuopen");
  }

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
                onPressed: () =>                   menuRedirect(routename: "/login", currentmenu: 9)
,
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
              backgroundColor:
                  isgridView ? Color.fromARGB(255, 47, 62, 75) : Colors.grey[300],
              appBar: mainappbar(
                  ontab: menuopen,
                  title: "Attendance",
                  controller: _controller),
              body: isgridView
                  ? gridView()
                  : Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.pin_drop,
                                  color: Color(0xFF0061b0),
                                  size: 26.0,
                                ),
                                SizedBox(width: 5.0),
                                Expanded(
                                    child: Container(
                                  child: Text(location,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87)),
                                )),
                                GestureDetector(
                                  onTap: () {
                                    getUserLocation();
                                  },
                                  child: Icon(
                                    Icons.refresh,
                                    color: Color(0xFF0061b0),
                                    size: 26.0,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 80,
                                      ),
                                      Text("Grid View",
                                          style: Drawables.adddoccontentstyle(
                                              Colors.black87,
                                              14.0,
                                              FontWeight.w600)),
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
                                      isShowCheckInOut = true;
                                      getAttendance(
                                          day + "-" + month + "-" + year);
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 0, 20),
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                              underline: Container(
                                height: 3,
                                color: Colors.transparent,
                              ),
                              onChanged: (String? newValue) {
                                var index = 0;
                                monthMatch.map((element) {
                                  // get index
                                  if (newValue != null)
                                  {
                                    index = monthMatch.indexOf(newValue);
                                  }
                                }).toList();
                                var selecetedMonth = index + 1;
                                var editedMonth = "";
                                if (selecetedMonth.toString().length == 1) {
                                  editedMonth = "0" + selecetedMonth.toString();
                                } else {
                                  selecetedMonth.toString();
                                }
                                getAttendance(editedMonth + "-" + year);
                                setState(() {
                                  if(newValue != null)
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
                          _attendance.length > 0
                              ? Expanded(
                                  child: ListView.builder(
                                    itemCount: _attendance.length,
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
                                                            getDateFormat(
                                                                    _attendance[
                                                                            index]
                                                                        .date ?? "",
                                                                    1) +
                                                                "\n" +
                                                                getDateFormat(
                                                                    _attendance[
                                                                            index]
                                                                        .date ?? "",
                                                                    2),
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
                                                                      200]!),
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
                                                                text: getTimeFormat(
                                                                    _attendance[
                                                                            index]
                                                                        .checkInTime ?? ""),
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
                                                            Expanded(
                                                              child: Text(
                                                                  _attendance[
                                                                          index]
                                                                      .checkInLocation ?? "",
                                                                  style: Drawables.adddoccontentstyle(
                                                                      Colors
                                                                          .grey,
                                                                      12.0,
                                                                      FontWeight
                                                                          .w400)),
                                                            ),
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
                                                                text: getTimeFormat(
                                                                    _attendance[
                                                                            index]
                                                                        .checkOutTime ?? ""),
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
                                                            Expanded(
                                                              child: Text(
                                                                _attendance[
                                                                        index]
                                                                    .checkOutLocation ?? "",
                                                                style: Drawables
                                                                    .adddoccontentstyle(
                                                                        Colors
                                                                            .grey,
                                                                        12.0,
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 3.0),
                                                        Text(
                                                          getHours(
                                                              _attendance[index]
                                                                  .checkInTime ?? "",
                                                              _attendance[index]
                                                                  .checkOutTime ?? ""),
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
                              : SizedBox(),
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
            onTap: () 
            {
              print("inside check");
              // checkInOut("IN");
              if (location == '' || location == null) 
              {
                AppUtils.showToastErrorTop(
                    "Unable to find your location, Please tap refersh icon to get your location");
              } 
              else 
              {

                if(_attendance.length != 0)
                {
                      var lastSignIn = _attendance.last;
                  print("last Signin --> ${lastSignIn.checkOutTime}");
                  if(lastSignIn.checkOutTime == "" || lastSignIn.checkOutTime == null)
                  {
                     Widget okButton = TextButton(
                      child: Text("OK"),
                      onPressed: () { 
                        Navigator.pop(context);
                      },
                      );

                    AlertDialog alert = AlertDialog(
                    title: Text("You haven't Checked out",style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0061b0),
                  fontWeight: FontWeight.w600)),
                    content: Text("Kindly Checkout from the Previous Session"),
                    actions: [
                      okButton,
                    ],
                    );

                    showDialog(
                    context: context,
                    builder: (BuildContext context) {
                    return alert;
                      },
                    );
                }
                else
                {
                _onWillPop("IN");
                }
              }
              else
              {
                  _onWillPop("IN");
              }

                
              }
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
              //checkInOut("OUT");
              if (location == '' || location == null) {
                AppUtils.showToastErrorTop(
                    "Unable to find your location, Please tap refersh icon to get your location");
              } else 
              {               
                 _onWillPop("OUT");
              }
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
                    Icon(
                      Icons.pin_drop,
                      color: Colors.grey,
                      size: 26.0,
                    ),
                    SizedBox(width: 5.0),
                    Expanded(
                        child: Container(
                      child: Text(location,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    )),
                    GestureDetector(
                      onTap: () {
                        getUserLocation();
                      },
                      child: Icon(
                        Icons.refresh,
                        color: Colors.grey,
                        size: 26.0,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    InkWell(
                      child: Row(
                        children: [
                          SizedBox(
                            height: 80,
                          ),
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
                          isShowCheckInOut = false;
                          dropdownValue = monthMatch[int.parse(month) - 1];
                          //getAttendance(month);
                          getAttendance(month + "-" + year);
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
                 // calendarController: _calendarController,
                 
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                   // centerHeaderTitle: true,
                    titleTextStyle: TextStyle(color: Colors.white),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white),
                      weekendStyle: TextStyle(color: Colors.red)),
                  calendarStyle: CalendarStyle(
                   // weekendStyle: TextStyle(color: Colors.white),
                    //outsideWeekendStyle: TextStyle(color: Colors.white),
                    holidayTextStyle: TextStyle(color: Colors.white),
                    withinRangeTextStyle: TextStyle(color: Colors.white),
                    todayTextStyle: TextStyle(
                      color: Colors.white,backgroundColor: Colors.red
                    ),
                   // todayColor: Colors.red,
                    selectedTextStyle: TextStyle(color: Colors.black,backgroundColor: Colors.white),
                    //selectedStyle: TextStyle(color: Colors.black),
                   // weekdayStyle: TextStyle(color: Colors.white),
                    outsideDaysVisible: false,
                   // outsideStyle: TextStyle(color: Colors.grey),
                  ),
                  selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                    var month1 = selectedDay.month.toString().padLeft(2, '0');
                    var day1 = selectedDay.day.toString().padLeft(2, '0');
                    var year1 = selectedDay.year.toString();
                    getAttendance(day1 + "-" + month1 + "-" + year1);
                    setState(() 
                    {
                       _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    if ((day1 + "-" + month1 + "-" + year1) ==
                        (day + "-" + month + "-" + year)) {
                      isShowCheckInOut = true;
                    } else {
                      isShowCheckInOut = false;
                    }
                  }, firstDay: DateTime.utc(2010, 10, 16), focusedDay: _focusedDay, lastDay: DateTime.utc(2030, 3, 14),
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
                child: _attendance.length > 0
                    ? ListView.builder(
                        itemCount: _attendance.length,
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
                                                getDateFormat(
                                                        _attendance[index].date ?? "",
                                                        1) +
                                                    "\n" +
                                                    getDateFormat(
                                                        _attendance[index].date ?? "",
                                                        2),
                                                style: Drawables
                                                    .adddoccontentstyle(
                                                        Colors.black87,
                                                        14.0,
                                                        FontWeight.w400),
                                              )),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey[200]!),
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
                                                    text: getTimeFormat(
                                                        _attendance[index]
                                                            .checkInTime ?? ""),
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
                                                Expanded(
                                                  child: Text(
                                                      _attendance[index]
                                                          .checkInLocation ?? "",
                                                      style: Drawables
                                                          .adddoccontentstyle(
                                                              Colors.grey,
                                                              12.0,
                                                              FontWeight.w400)),
                                                ),
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
                                                    text: getTimeFormat(
                                                        _attendance[index]
                                                            .checkOutTime ?? ""),
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
                                                Expanded(
                                                  child: Text(
                                                    _attendance[index]
                                                                .checkOutLocation
                                                                .toString() !=
                                                            "null"
                                                        ? _attendance[index]
                                                            .checkOutLocation
                                                            .toString()
                                                        : "",
                                                    style: Drawables
                                                        .adddoccontentstyle(
                                                            Colors.grey,
                                                            12.0,
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 3.0),
                                            Text(
                                              getHours(
                                                  _attendance[index]
                                                      .checkInTime.toString(),
                                                  _attendance[index]
                                                      .checkOutTime.toString()),
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
              isShowCheckInOut == true ? bottombutton() : SizedBox()
            ],
          ),
        ),
      ],
    );
  }

  menuRedirect({@required String? routename, int? currentmenu}) {
    setState(() {
      if (currentmenu != null)
      Strings.currentmenuvalue = currentmenu;
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

  getAttendance(String date) 
  {
    getUserLocation();
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);

    api.getAttendance(Strings.userID!, date).then((response) {
      AppUtils.dismissprogress();
      print('Response status ${response.toJson()}');
      
      if (response.status) 
      {
        setState(() {
          if (response.data.length > 0) 
          {
            print("response fetched");
            _attendancemain = response.data;
            formatAttendanceData();
          }
          else
          {
            _attendancemain = [];
          }
        });
      } else 
      {
        setState(() {
          _attendance = [];
        });
        AppUtils.showToastError(response.message);
      }
    }).catchError((onError) {
      print("catch");
      AppUtils.dismissprogress();
      setState(() {
        _attendance = [];
      });
      print("error on catch ${onError.toString()}");
    });
  }
  formatAttendanceData()
  {
    _attendance.clear();
    print("inside format");
    print(_attendancemain.length);
      for (var i = 0; i < _attendancemain.length; i++) 
      {
        print("inside if");
        if( _attendancemain[i].checkType == "IN")
        {
            AttendanceDataNew test = new AttendanceDataNew();
            print("inside Inn");
            print("i ${i}");
            test.checkInLocation = _attendancemain[i].locationName;
            test.checkInTime = _attendancemain[i].checkTime;
            test.userId = _attendancemain[i].userId;
            DateTime dateData = DateTime.parse(_attendancemain[i].checkTime);
            String formattedDate = DateFormat('yyyy-MM-dd').format(dateData);
            test.date = formattedDate;
             print("adding");
             if(i < _attendancemain.length-1)
             {
                    var j= i+1;
              
                    if(_attendancemain[j].checkType == "OUT")
                    {
                      print("in else");
                      test.checkOutLocation = _attendancemain[j].locationName;
                      test.checkOutTime = _attendancemain[j].checkTime;
                    }
                   else
                  {
                    test.checkOutLocation = "";
                    test.checkOutTime = "";
                  }
             }
          print("testing ${test.checkInLocation}");
           setState(() 
           {
                print("data while addinf");
            print("testing ${test.checkInLocation}");
            print("testing ${test.checkInTime}");
            print("testing ${test.date}");
           print("testing ${test.userId}");

                _attendance.add(test);
                print(_attendance.length);              
                printfn();
           });
       


        }
         

      }
     
      printfn();
      
  }
  printfn()
  {
          for (var i = 0; i < _attendance.length; i++) 
          {
            print("value of i--> ${i}");
               print("---------------Didplaying Details--------------------");
             print("checkinloc -- ${_attendance[i].checkInLocation}");
            print("checkintime -- ${_attendance[i].checkInTime}");
             print("checkinuser -- ${_attendance[i].userId}");
             print("checkoutloc -- ${_attendance[i].checkOutLocation}");
             print("checkouttime -- ${_attendance[i].checkOutTime}"); 
            print("date -- ${_attendance[i].date}"); 
            print("Length -->${_attendance.length}");
          }

  }

  
  Future<bool> _onWillPop(action) async 
  {
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
              action == "IN"
                  ? 'Your Check IN location is  \n' + '" ' + location + ' "'
                  : 'Your Check OUT location is  \n' + '" ' + location + ' "',
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
                onPressed: () =>
                    ({checkInOut(action), Navigator.of(context).pop(false)}),
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

  checkInOut(action) {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    AddAttendanceReq req = AddAttendanceReq();
    //req.checkTime = DateFormat().add_jm().format(DateTime.now()).toString();
    req.checkTime = DateTime.now().toString();
    req.checkType = action;
    req.latLng = lat.toString() + "," + long.toString();
    req.locationName = location;
    api.addAttendance(req).then((response) {
      print("checking out");
      AppUtils.dismissprogress();
      print('Response status ${response.toJson()}');
      if (response.status!) {
        AppUtils.showToastSuccess(response.message!);
        if (isgridView == true) {
          getAttendance(day + "-" + month + "-" + year);
        } else {
          dropdownValue = monthMatch[int.parse(month) - 1];
          getAttendance(month + "-" + year);
        }
        setState(() {});
      } else {
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      print("incatch");
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  String getDateFormat(String date, int condition) {
    if (date != "" && date != "null" && date != null) {
      DateTime dateNow = DateTime.parse(date);
      var formatedDate = DateFormat.MMMEd().format(dateNow);
      var splitDate = formatedDate.split(",");
      var modifiedDay = splitDate[0];
      var splitSecond = splitDate[1].split(" ");
      var modifiedDate = splitSecond[2];
      var modifiedMonth = splitSecond[1];
      if (condition == 1) {
        return modifiedDate + " " + modifiedMonth;
      } else {
        return modifiedDay;
      }
    } else {
      return "";
    }
  }

  String getTimeFormat(String date) {
    print("date--> ${date}");
    if (date != "" && date != "null" && date != null) {
      return DateFormat().add_jm().format(DateTime.parse(date)).toString();
    } else {
      return "";
    }
  }

  String getHours(String checkInTime, String checkOutTime) {
    // var startDate = DateTime.parse(DateTime.now().toString());
    // var endDate = DateTime.parse(DateTime.now().toString());
    if (checkInTime != "" &&
        checkOutTime != "" &&
        checkInTime != "null" &&
        checkInTime != null &&
        checkOutTime != "null" &&
        checkOutTime != null) {
      DateTime startDate = DateTime.parse(checkInTime);
      DateTime endDate = DateTime.parse(checkOutTime);

      int seconds = endDate.difference(startDate).inSeconds;
      if (seconds < 60)
        return '${seconds.abs()} Secs';
      else if (seconds >= 60 && seconds < 3600) {
        String secs =
            (seconds.abs() - startDate.difference(endDate).inMinutes.abs() * 60)
                .toString();
        return '${startDate.difference(endDate).inMinutes.abs()} Mins' +
            " " +
            '$secs Secs';
      } else {
        String mins = (startDate.difference(endDate).inMinutes.abs() -
                startDate.difference(endDate).inHours.abs() * 60)
            .toString();
        return '${startDate.difference(endDate).inHours.abs()} Hrs' +
            " " +
            '$mins Mins';
      }
    } else {
      return "";
    }
  }

  getUserLocation() async {
    await Geolocator.checkPermission().then((value) async => {
          if (value == LocationPermission.denied)
            {
              {await Geolocator.requestPermission().then((value) => {})}
            }
          else if (value == LocationPermission.deniedForever)
            {
              AppUtils.showToastError(
                  "Please enable loaction from App permission Settings")
            }
          else
            {
              await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation).then((value) => {
                    setState(
                      () {
                        AppUtils.showprogress();
                        lat = value.latitude;
                        long = value.longitude;
                        getGeocode(lat, long);
                      },
                    )
                  })
            }
        });
  }

  Future<void> getGeocode(double latt, double longg) async {
    var results = await Geocoder.local
        .findAddressesFromCoordinates(new Coordinates(latt, longg));
    setState(() {
      var address = results.first;
      location = address.addressLine!;
      // print(address.addressLine);
      // print("${address.featureName} : ${address.addressLine}");
      // AppUtils.showToastError(address.addressLine);
    });
    print("loc det");
    AppUtils.dismissprogress();
  }
}
