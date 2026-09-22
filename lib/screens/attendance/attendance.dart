import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mta/blocs/attendance/attendance_bloc.dart';
import 'package:mta/models/AddAttendanceReq.dart';
import 'package:mta/models/CurrentProjectReq.dart';
import 'package:mta/models/FetchAttendanceRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/circleImage.dart';
import 'package:mta/utilities/constant.dart';
import 'package:mta/utilities/customcolor.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:mta/utilities/app_drawer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mta/models/FetchAttendenceChangedRes.dart';

import '../../models/DashboardRes.dart';

double lat = 0.00;
double long = 0.00;
String location = '';
double? distance;
var now = DateTime.now();
var month = now.month.toString().padLeft(2, '0');
var day = now.day.toString().padLeft(2, '0');
var year = now.year.toString();
DateTime _focusedDay = DateTime.now();
DateTime? _selectedDay;
List<Data>? _projectLists = [];
List<Data>? _searchLists = [];
Data? selectedProject;

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

class _AttendanceContentState extends State<AttendanceContent> {
  // CalendarController _calendarController;
  bool isgridView = true;
  bool isShowCheckInOut = true;
  List<AttendanceDataNew> _attendance = [];
  List<AttendanceData> _attendancemain = [];

  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();
  late final AttendanceBloc _bloc;
  late final StreamSubscription<AttendanceState> _blocSub;

  void initState() {
    //_calendarController = CalendarController();
    super.initState();
    _bloc = AttendanceBloc(ApiService.create());
    _blocSub = _bloc.stream.listen(_onBlocState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bloc
        .add(AttendanceForDateRequested(day + "-" + month + "-" + year)));
    _bloc.add(const AttendanceProjectsRequested());
  }

  /// Performs the UI side effects for [AttendanceBloc] states — spinner, toasts,
  /// setState of the screen globals/fields, `formatAttendanceData()` and the
  /// grid/list-aware list refresh the old networking methods did inline.
  void _onBlocState(AttendanceState state) {
    if (state is AttendanceProjectsLoading) {
      AppUtils.showprogress();
    } else if (state is AttendanceProjectsLoaded) {
      AppUtils.dismissprogress();
      setState(() {
        _projectLists = state.projects;
        selectedProject = state.selectedProject;
        location = state.selectedProject?.projectName ?? "";
      });
    } else if (state is AttendanceProjectsFailure) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(state.message);
    } else if (state is AttendanceProjectsError) {
      AppUtils.dismissprogress();
    } else if (state is AttendanceCurrentProjectFailure) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(state.message);
    } else if (state is AttendanceRecordsLoading) {
      AppUtils.showprogress();
    } else if (state is AttendanceRecordsLoaded) {
      AppUtils.dismissprogress();
      setState(() {
        _attendancemain = state.records;
        formatAttendanceData();
      });
    } else if (state is AttendanceRecordsEmpty) {
      AppUtils.dismissprogress();
      setState(() {
        _attendancemain = [];
        _attendance = [];
      });
    } else if (state is AttendanceRecordsFailure) {
      AppUtils.dismissprogress();
      setState(() {
        _attendance = [];
      });
      AppUtils.showToastError(state.message);
    } else if (state is AttendanceRecordsError) {
      AppUtils.dismissprogress();
      setState(() {
        _attendance = [];
      });
    } else if (state is AttendanceCheckLoading) {
      AppUtils.showprogress();
    } else if (state is AttendanceCheckSuccess) {
      AppUtils.dismissprogress();
      AppUtils.showToastSuccess(state.message);
      if (isgridView == true) {
        _bloc.add(AttendanceForDateRequested(day + "-" + month + "-" + year));
      } else {
        dropdownValue = monthMatch[int.parse(month) - 1];
        _bloc.add(AttendanceForDateRequested(month + "-" + year));
      }
      setState(() {});
    } else if (state is AttendanceCheckFailure) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(state.message);
    } else if (state is AttendanceCheckError) {
      AppUtils.dismissprogress();
    }
  }

  getProjects() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.projects(Strings.userID!).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        setState(() {
          print("messagee from api ${response.message}");
          _projectLists = response.data;
          selectedProject = response.token;
          location = response.token?.projectName ?? "";
        });
      } else {
        AppUtils.showToastError(response.message ?? "Error");
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print("caddd");
      print(onError.toString());
    });
  }

  updateCurrentProject(int projectId) {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    print("qw11");

    CurrentProjectReq req = CurrentProjectReq();
    req.userId = Strings.userID;
    req.projectId = projectId;

    api.setCurrentProject(req).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        getProjects();
      } else {
        AppUtils.showToastError(response.message ?? "Error");
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  menuopen() {
    print("menuopen");
  }

  @override
  void dispose() {
    _blocSub.cancel();
    _bloc.close();
    super.dispose();
  }

  Future<bool> _showExitDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
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
                child: Text(
                  'No',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: Text(
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
    print(" data ${_projectLists?.length}");
    return Material(
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            await _showExitDialog();
            return false;
          },
          child: Scaffold(
            drawer: AppDrawer(),
            backgroundColor:
                isgridView ? Color.fromARGB(255, 47, 62, 75) : Colors.grey[300],
            appBar: mainappbar(ontab: menuopen, title: "Attendance"),
            body: isgridView
                ? gridView()
                : Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(30, 10, 0, 10),
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
                                      if (newValue != null) {
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
                                    _bloc.add(AttendanceForDateRequested(
                                        editedMonth + "-" + year));
                                    setState(() {
                                      if (newValue != null)
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
                              InkWell(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Text("Grid View",
                                        style: Drawables.adddoccontentstyle(
                                            Colors.black87, 14.0, FontWeight.w600)),
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
                                    _bloc.add(AttendanceForDateRequested(
                                        day + "-" + month + "-" + year));
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                        _attendance.length > 0
                            ? Expanded(
                                child: ListView.builder(
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
                                                          horizontal: 15,
                                                          vertical: 35),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                                vertical: 10.0),
                                                        child: Center(
                                                            child: Text(
                                                          getDateFormat(
                                                                  _attendance[index]
                                                                          .date ??
                                                                      "",
                                                                  1) +
                                                              "\n" +
                                                              getDateFormat(
                                                                  _attendance[index]
                                                                          .date ??
                                                                      "",
                                                                  2),
                                                          style: Drawables
                                                              .adddoccontentstyle(
                                                                  Colors.black87,
                                                                  14.0,
                                                                  FontWeight.w400),
                                                        )),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey[200]!),
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
                                                      Row(
                                                        children: [
                                                          CircleImageFromNetwork(
                                                              imageUrl: Strings
                                                                      .baseImageUrl +
                                                                  (_attendance[
                                                                              index]
                                                                          .projectImg ??
                                                                      ""),
                                                              width: 40,
                                                              height: 40,
                                                              radius: 15,
                                                              defaultImageUrl:
                                                                  "assets/images/background1.png"),
                                                          SizedBox(width: 5.0),
                                                          Expanded(
                                                            child: Text(
                                                              _attendance[index]
                                                                      .projectName ??
                                                                  "",
                                                              style: Drawables
                                                                  .adddoccontentstyle(
                                                                      Colors.grey,
                                                                      12.0,
                                                                      FontWeight
                                                                          .w400),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
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
                                                                          .checkInTime ??
                                                                      ""),
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
                                                            color:
                                                                Color(0xFF0061b0),
                                                            size: 16.0,
                                                          ),
                                                          SizedBox(width: 5.0),
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
                                                                  Colors.black54,
                                                                  13.0,
                                                                  FontWeight.w400),
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: getTimeFormat(
                                                                  _attendance[index]
                                                                          .checkOutTime ??
                                                                      ""),
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
                                                            color:
                                                                Color(0xFF0061b0),
                                                            size: 16.0,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 3.0),
                                                      Text(
                                                        getHours(
                                                            _attendance[index]
                                                                    .checkInTime ??
                                                                "",
                                                            _attendance[index]
                                                                    .checkOutTime ??
                                                                ""),
                                                        style: TextStyle(
                                                            color:
                                                                Color(0xFF0061b0),
                                                            fontWeight:
                                                                FontWeight.w600),
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
                            : Center(
                                child: Text(
                                  "No Attendance Marked",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
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
            onTap: () async {
              if (location == '') {
                AppUtils.showToast("Please Select the Project");
              } else {
                if (selectedProject?.latitude == "" ||
                    selectedProject?.latitude == null ||
                    selectedProject?.longitude == "" ||
                    selectedProject?.longitude == null) {
                  Widget okButton = TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  );

                  AlertDialog alert = AlertDialog(
                    title: Text("Location Not available",
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF0061b0),
                            fontWeight: FontWeight.w600)),
                    content: Text(
                        "Kindly contact the admin and Update Project location."),
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
                } else {
                  AppUtils.showprogress();
                  var status = await getUserLocation();
                  print("inside check  $status");

                  if (status) {
                    if (_attendance.length != 0) {
                      var lastSignIn = _attendance.last;
                      print("last Signin --> ${lastSignIn.checkOutTime}");
                      if (lastSignIn.checkOutTime == "" ||
                          lastSignIn.checkOutTime == null) {
                        Widget okButton = TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );

                        AlertDialog alert = AlertDialog(
                          title: Text("You haven't Checked out",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF0061b0),
                                  fontWeight: FontWeight.w600)),
                          content:
                              Text("Kindly Checkout from the Previous Session"),
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
                      } else {
                        print("distancee   $distance");
                        if (distance != null &&
                            distance! <= Strings.checkInRadius) {
                          _onWillPop("IN");
                        } else if (distance != null) {
                          _outOfLocationPopUp();
                        }
                      }
                    } else {
                      print("dis $distance");
                      if (distance != null &&
                          distance! < Strings.checkInRadius) {
                        _onWillPop("IN");
                      } else if (distance != null) {
                        _outOfLocationPopUp();
                      }
                    }
                  } else {
                    AppUtils.showToastError(
                        "Location permission is required for Check In/Check Out");
                  }
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
            onTap: () async {
              if (location == '') {
                AppUtils.showToastErrorTop("Please Select a Project.");
              } else {
                if (selectedProject?.latitude == "" ||
                    selectedProject?.latitude == null ||
                    selectedProject?.longitude == "" ||
                    selectedProject?.longitude == null) {
                  Widget okButton = TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  );

                  AlertDialog alert = AlertDialog(
                    title: Text("Location Not available",
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF0061b0),
                            fontWeight: FontWeight.w600)),
                    content: Text(
                        "Kindly contact the admin and Update Project location."),
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
                } else {
                  AppUtils.showprogress();
                  var status = await getUserLocation();
                  //checkInOut("OUT");

                  if (status) {
                    if (_attendance.length == 0) {
                      Widget okButton = TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      );

                      AlertDialog alert = AlertDialog(
                        title: Text("You haven't Checked In",
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF0061b0),
                                fontWeight: FontWeight.w600)),
                        content: Text(
                            "You were not allowed to check out, since you were not checkedin."),
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
                    } else {
                      var lastSignIn = _attendance.last;
                      print("last ${_attendance.last}");
                      if (lastSignIn.checkOutTime == "" ||
                          lastSignIn.checkOutTime == null) {
                        if (distance != null &&
                            distance! < Strings.checkInRadius) {
                          _onWillPop("OUT");
                        } else if (distance != null) {
                          _outOfLocationPopUp();
                        }
                      } else {
                        Widget okButton = TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );

                        AlertDialog alert = AlertDialog(
                          title: Text("You haven't Checked In",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF0061b0),
                                  fontWeight: FontWeight.w600)),
                          content: Text(
                              "You were not allowed to checked out, since you are not checkedin."),
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
                    }
                  } else {
                    AppUtils.showToastError(
                        "Location permission is required for Check In/Check Out");
                  }
                }
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
                    InkWell(
                      onTap: () {
                        showUserProjectsDialog();
                      },
                      child: Container(
                        child: Row(
                          children: [
                            Icon(
                              Icons.pin_drop,
                              color: Colors.grey,
                              size: 26.0,
                            ),
                            SizedBox(width: 5.0),
                            CircleImageFromNetwork(
                                imageUrl: Strings.baseImageUrl +
                                    (selectedProject?.projectImg ?? ""),
                                width: 40,
                                height: 40,
                                radius: 12,
                                defaultImageUrl:
                                    "assets/images/background1.png"),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                  selectedProject?.projectName ??
                                      "Select Project",
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // GestureDetector(
                    //   onTap: () {
                    //     getUserLocation();
                    //   },
                    //   child: Icon(
                    //     Icons.refresh,
                    //     color: Colors.grey,
                    //     size: 26.0,
                    //   ),
                    // ),
                    Spacer(),

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
                          _bloc.add(
                              AttendanceForDateRequested(month + "-" + year));
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
                      disabledTextStyle: TextStyle(color: Colors.grey),
                      //outsideWeekendStyle: TextStyle(color: Colors.white),
                      holidayTextStyle: TextStyle(color: Colors.white),
                      withinRangeTextStyle: TextStyle(color: Colors.white),
                      selectedDecoration: BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(
                          color: Colors.blue, shape: BoxShape.circle),
                      todayTextStyle: TextStyle(
                        color: Colors.white,
                      ),
                      // todayColor: Colors.red,
                      selectedTextStyle: TextStyle(color: Colors.white),
                      //selectedStyle: TextStyle(color: Colors.black),
                      // weekdayStyle: TextStyle(color: Colors.white),
                      outsideDaysVisible: false,
                      // outsideStyle: TextStyle(color: Colors.grey),
                      defaultTextStyle: TextStyle(color: Colors.white),
                      weekendTextStyle:
                          TextStyle(color: Colors.red.withOpacity(0.7))),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                    var month1 = selectedDay.month.toString().padLeft(2, '0');
                    var day1 = selectedDay.day.toString().padLeft(2, '0');
                    var year1 = selectedDay.year.toString();
                    _bloc.add(AttendanceForDateRequested(
                        day1 + "-" + month1 + "-" + year1));
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    if ((day1 + "-" + month1 + "-" + year1) ==
                        (day + "-" + month + "-" + year)) {
                      isShowCheckInOut = true;
                    } else {
                      isShowCheckInOut = false;
                    }
                  },
                  firstDay: DateTime.utc(2010, 10, 16),
                  focusedDay: _focusedDay,
                  lastDay: DateTime.now(),
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
                                                        _attendance[index]
                                                                .date ??
                                                            "",
                                                        1) +
                                                    "\n" +
                                                    getDateFormat(
                                                        _attendance[index]
                                                                .date ??
                                                            "",
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
                                                  borderRadius: BorderRadius.circular(
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
                                            Row(
                                              children: [
                                                CircleImageFromNetwork(
                                                    imageUrl: Strings
                                                            .baseImageUrl +
                                                        (_attendance[index]
                                                                .projectImg ??
                                                            ""),
                                                    width: 40,
                                                    height: 40,
                                                    radius: 15,
                                                    defaultImageUrl:
                                                        "assets/images/background1.png"),
                                                SizedBox(width: 5.0),
                                                Expanded(
                                                  child: Text(
                                                    _attendance[index]
                                                            .projectName ??
                                                        "dttttt",
                                                    style: Drawables
                                                        .adddoccontentstyle(
                                                            Colors.grey,
                                                            12.0,
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
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
                                                                .checkInTime ??
                                                            ""),
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
                                            Icon(Icons.more_vert,
                                                color: Colors.grey, size: 14.0),
                                            SizedBox(height: 3.0),
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
                                                                .checkOutTime ??
                                                            ""),
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
                                            SizedBox(height: 3.0),
                                            Text(
                                              getHours(
                                                  _attendance[index]
                                                      .checkInTime
                                                      .toString(),
                                                  _attendance[index]
                                                      .checkOutTime
                                                      .toString()),
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
                    : Center(
                        child: Text(
                          "No Attendance Marked",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.w600),
                        ),
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

  getAttendance(String date) {
    // getUserLocation();
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.getAttendance(Strings.userID!, date).then((response) {
      AppUtils.dismissprogress();
      print('Response status ${response.toJson()}');

      if (response.status!) {
        // // to handle the check in distance
        Strings.checkInRadius = int.tryParse(response.radius ?? "50")!;
        setState(() {
          if (response.data!.length > 0) {
            print("response fetched");
            _attendancemain = response.data!;
            formatAttendanceData();
          } else {
            _attendancemain = [];
            _attendance = [];
          }
        });
      } else {
        setState(() {
          _attendance = [];
        });
        AppUtils.showToastError(response.message!);
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

  formatAttendanceData() {
    _attendance.clear();
    print("inside format");
    print(_attendancemain.length);
    for (var i = 0; i < _attendancemain.length; i++) {
      print("inside if");
      if (_attendancemain[i].checkType == "IN") {
        AttendanceDataNew test = new AttendanceDataNew();
        print("inside Inn");
        print("i $i");
        test.checkInLocation = _attendancemain[i].locationName;
        test.checkInTime = _attendancemain[i].checkTime;
        //  test.userId = _attendancemain[i].userId;
        DateTime dateData = DateTime.parse(_attendancemain[i].checkTime!);
        String formattedDate = DateFormat('yyyy-MM-dd').format(dateData);
        test.date = formattedDate;
        test.projectImg = _attendancemain[i].projectImg ?? "";
        test.projectName = _attendancemain[i].projectName ?? "";
        print("adding");
        if (i < _attendancemain.length - 1) {
          var j = i + 1;
          print("jsonEncode ${jsonEncode(_attendancemain[j])}");
          if (_attendancemain[j].checkType == "OUT") {
            print("in else");
            test.checkOutLocation = _attendancemain[j].locationName;
            test.checkOutTime = _attendancemain[j].checkTime;
          } else {
            test.checkOutLocation = "";
            test.checkOutTime = "";
          }

          print("prrr name ${_attendancemain[j].projectName}");
          test.projectImg = _attendancemain[j].projectImg ?? "";
          test.projectName = _attendancemain[j].projectName ?? "";
        }
        print("testing ${test.checkInLocation}");
        setState(() {
          _attendance.add(test);
        });
      }
    }
  }

  Future<bool> _onWillPop(action) async {
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
                onPressed: () {
                  _bloc.add(AttendanceCheckInOutRequested(
                      action: action,
                      lat: lat,
                      long: long,
                      location: location,
                      projectId: selectedProject?.projectId));
                  Navigator.of(context).pop(false);
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
        )) ??
        false;
  }

  Future<bool> _outOfLocationPopUp() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text(
              "Not Inside the Premise",
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0061b0),
                  fontWeight: FontWeight.w600),
            ),
            content: Text(
              "You were not inside the selected project location.You are ${distanceCalculation(distance!)} far from the location. Your current coordinates are (latitude: $lat, longitude: $long). Please move closer to the Project location and try again. ",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  'Okay',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  String distanceCalculation(double meters) {
    if (meters > 1000) {
      return "${(meters / 1000).toStringAsFixed(1)} kilometers"; // Convert to kilometers
    } else {
      return "${meters.toStringAsFixed(1)} meters"; // Return meters as it is
    }
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
    req.projectId = selectedProject?.projectId;

    print("payload ${jsonEncode(req)}");

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
    if (date != "" && date != "null") {
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
    print("date--> $date");
    if (date != "" && date != "null") {
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
        checkOutTime != "null") {
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

  Future<bool> getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        AppUtils.dismissprogress();
        AppUtils.showToastError(
            "Location permission denied. Please allow location access.");
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        AppUtils.dismissprogress();
        AppUtils.showToastError(
            "Please enable location from app permission settings");
        return false;
      }

      final value = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      if (!mounted) {
        AppUtils.dismissprogress();
        return false;
      }

      setState(() {
        AppUtils.dismissprogress();
        lat = value.latitude;
        long = value.longitude;
        distance = Geolocator.distanceBetween(
            lat,
            long,
            double.parse(selectedProject?.latitude ?? "0.0"),
            double.parse(selectedProject?.longitude ?? "0.0"));
        print("User distance $distance");
      });
      return true;
    } catch (error) {
      AppUtils.dismissprogress();
      AppUtils.showToastError("$error");
      return false;
    }
  }

  Future<void> getGeocode(double latt, double longg) async {
    var placemarks = await placemarkFromCoordinates(latt, longg);
    setState(() {
      var place = placemarks.first;
      location = [
        place.street,
        place.locality,
        place.administrativeArea,
        place.country
      ].where((e) => e != null && e.isNotEmpty).join(', ');
    });
    print("loc det");
    AppUtils.dismissprogress();
  }

  Future<void> showUserProjectsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        InkWell(
                          child: new Icon(Icons.close,
                              size: 22.0, color: Colors.black),
                          onTap: () {
                            _searchFieldController.text = "";
                            _searchLists?.clear();
                            searchField.unfocus();
                            Navigator.of(context).pop();
                          },
                        )
                      ]),
                      Text(
                        "Select Project",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
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
                                      _projectLists?.forEach((list) {
                                        if (list.projectName!
                                            .toLowerCase()
                                            .startsWith(value.toLowerCase()))
                                          _searchLists?.add(list);
                                      });
                                      print("dataaaa ${_searchLists?.length}");
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
                      Container(
                        height: MediaQuery.of(context).size.width * 1,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: (_projectLists?.length != 0 &&
                                _projectLists?.length != null)
                            ? _searchLists?.length != 0
                                ? ListView.builder(
                                    itemCount: _searchLists?.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        children: [
                                          Card(
                                            color: Colors.white70,
                                            child: ListTile(
                                              leading: CircleImageFromNetwork(
                                                  imageUrl:
                                                      Strings.baseImageUrl +
                                                          (_searchLists?[index]
                                                                  .projectImg ??
                                                              ""),
                                                  width: 40,
                                                  height: 40,
                                                  radius: 18,
                                                  defaultImageUrl:
                                                      "assets/images/background1.png"),
                                              title: Text(
                                                _searchLists?[index]
                                                        .projectName ??
                                                    "",
                                                maxLines: 3,
                                              ),
                                              subtitle: Text(
                                                _searchLists?[index]
                                                        .description ??
                                                    "",
                                                maxLines: 3,
                                              ),
                                              onTap: () {
                                                _bloc.add(
                                                    AttendanceCurrentProjectUpdated(
                                                        _searchLists![index]
                                                            .projectId!));
                                                _searchFieldController.text =
                                                    "";
                                                _searchLists?.clear();
                                                searchField.unfocus();
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                : _searchFieldController.text != ""
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "No results found",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: _projectLists?.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              Card(
                                                color: Colors.white70,
                                                child: ListTile(
                                                  leading: CircleImageFromNetwork(
                                                      imageUrl: Strings
                                                              .baseImageUrl +
                                                          (_projectLists?[index]
                                                                  .projectImg ??
                                                              ""),
                                                      width: 40,
                                                      height: 40,
                                                      radius: 18,
                                                      defaultImageUrl:
                                                          "assets/images/background1.png"),
                                                  title: Text(
                                                    _projectLists?[index]
                                                            .projectName ??
                                                        "",
                                                    maxLines: 3,
                                                  ),
                                                  subtitle: Text(
                                                    _projectLists?[index]
                                                            .description ??
                                                        "",
                                                    maxLines: 3,
                                                  ),
                                                  onTap: () {
                                                    _bloc.add(
                                                        AttendanceCurrentProjectUpdated(
                                                            _projectLists![index]
                                                                .projectId!));
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      )
                            : Center(
                                child: Text("No assigned projects found",
                                    style: TextStyle(color: Colors.red))),
                      ),
                    ],
                  )),
            );
          }),
        );
      },
    );
  }
}
