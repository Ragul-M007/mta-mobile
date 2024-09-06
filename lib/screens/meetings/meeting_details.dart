// ignore_for_file: unnecessary_null_comparison, must_be_immutable

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart';
import 'package:mta/models/MeetingDetails.dart';
import 'package:mta/models/UpdateMeetingReq.dart';
import 'package:mta/models/cancelMeetingReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/meetings/meetings_home.dart';
import 'package:mta/utilities/AppBarWidget.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/customcolor.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingDetails extends StatefulWidget {
  int meeting_id;
  bool fromHistory;
  MeetingDetails(
      {super.key, required this.meeting_id, required this.fromHistory});

  @override
  State<MeetingDetails> createState() => _MeetingDetailsState();
}

class _MeetingDetailsState extends State<MeetingDetails> {
  BuildContext? ctx;

  double? height;

  double? width;

  MeetingDetail? meetingsData;

  var address;

  String locationData = 'Location';

  var startFieldController;

  TimeOfDay? choosenFromTime;

  TimeOfDay? choosenToTime;

  TextEditingController endTimeController = TextEditingController();

  TextEditingController startTimeController = TextEditingController();

  DateTime? startTime;

  DateTime? endTime;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getMeetings());
  }

  getMeetings() {
    print(">>>>:${widget.meeting_id}");
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.getMeetingById(widget.meeting_id).then((response) async {
      AppUtils.dismissprogress();
      print(">>>>>>11:${response.status!}");
      if (response.status!) {
        setState(() {
          meetingsData = response.data!;
        });
        if (meetingsData!.type == "1" &&
            Strings.urlRegex.hasMatch(meetingsData!.location!)) {
          _getAddressFromLink(meetingsData!.location!);
        }
      }
    }).catchError((onError) {
      print(">>>>>err:${onError}");
      AppUtils.dismissprogress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
          onWillPop: () {
            if (Strings.fromNotificationNewMeeting) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => Meetings(),
                ),
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }

            throw '';
          },
          child: Builder(
            builder: (BuildContext newContext) {
              return meetingDetailsWidget(newContext);
            },
          ),
        ),
      ),
    );
  }

  Widget meetingDetailsWidget(BuildContext newContext) {
    ctx = newContext;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return meetingsData != null
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppBarWidget(
                  backButtonfunction: () {
                    if (Strings.fromNotificationNewMeeting) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Meetings(),
                        ),
                        (route) => false,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  title: "Meeting Details",
                  actionWidget: [
                    meetingsData!.userId == Strings.userID &&
                            !widget.fromHistory
                        ? IconButton(
                            onPressed: () {
                              _showDeleteMeetingDialog(context);
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              size: 22,
                            ))
                        : Container()
                  ]),
            ),
            body: Padding(
              padding:
                  EdgeInsets.only(left: 30.0, right: 30, top: height! * 0.06),
              child: Container(
                height: height! * 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        meetingsData!.title!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 30),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height! * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppUtils().getMeetingDateFormat(
                                  meetingsData!.start!,
                                  meetingsData!.end!,
                                  MediaQuery.of(context).size.width),
                              style: TextStyle(
                                  color: CustomColors.meetingSubtitleFontColor,
                                  fontSize: 16),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            meetingsData!.userId == Strings.userID &&
                                    !widget.fromHistory
                                ? IconButton(
                                    onPressed: () {
                                      _showMeetingEditDialog(context);
                                    },
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ))
                                : Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color:
                                        CustomColors.meetingSubtitleFontColor,
                                  ),
                          ],
                        ),
                      ),
                      meetingsData!.type != "1" && !widget.fromHistory
                          ? Padding(
                              padding: EdgeInsets.only(top: height! * 0.02),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                      // width: width! * 0.65,
                                      child: themeButton(
                                          title: "JOIN MEETING",
                                          buttonfunction: () {
                                            launchLink(
                                                meetingsData!.meetingLink!);
                                          })),
                                  SizedBox(
                                      // width: width! * 0.15,
                                      child: themeButton(
                                          title: "share",
                                          buttonfunction: () {
                                            shareFile();
                                          })),
                                ],
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.only(
                            top: height! * 0.04, bottom: height! * 0.02),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              AppUtils().getMeetingType(meetingsData!.type!),
                              style: TextStyle(fontSize: 22),
                            )),
                      ),
                      meetingsData!.type == "1"
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: width! * 0.4,
                                  child: Text(
                                    locationData,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                                Row(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          launchLink(meetingsData!.location!);
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              "Direction ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF0061b0)),
                                            ),
                                            Icon(
                                              Icons.directions_outlined,
                                              size: 18,
                                              color: Color(0xFF0061b0),
                                            )
                                          ],
                                        )),
                                    Container(
                                      margin: const EdgeInsets.only(right: 2.0),
                                      height: 20,
                                      width: 1, // Adjust the width as needed
                                      color: Colors.black,
                                    ),
                                    InkWell(
                                        onTap: () {
                                          shareFile();
                                        },
                                        child: Container(
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.share_outlined,
                                            size: 16,
                                            color: CustomColors.primarycolor,
                                          ),
                                        ))
                                  ],
                                ),
                              ],
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.only(top: height! * 0.02),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Description",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height! * 0.01),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xFFeceeef),
                          ),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                meetingsData!.description!,
                                style: TextStyle(fontSize: 16),
                              )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: height! * 0.03),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Invited Members",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            )),
                      ),
                      meetingsData!.guestEmail!.isNotEmpty
                          ? ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: meetingsData!.guestEmail!
                                  .length, // Adjust the item count as needed
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                          meetingsData!.guestEmail![index]),
                                    ),
                                    const Divider(
                                      height:
                                          1, // Adjust the divider height if necessary
                                      color: Colors.grey,
                                      thickness:
                                          1, // Adjust the divider thickness if necessary
                                    ),
                                  ],
                                );
                              },
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  Future<void> _getAddressFromLink(String googleMapsLink) async {
    // Extract latitude and longitude from the link (adjust the regex as needed)
    RegExp regex = RegExp(r"(\d+\.\d+),\s*(\d+\.\d+)");
    Match match = regex.firstMatch(googleMapsLink)!;
    double latitude = double.parse(match.group(1)!);
    double longitude = double.parse(match.group(2)!);

    // Use Google Maps Geocoding API
    final response = await Dio().get(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyBGzK5REYl1icyJd-Bgu4A6Af9vbH-y1FM');

    if (response.statusCode == 200) {
      final data = json.decode(jsonEncode(response.data));
      log(">>>>sts2:${data},");
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        setState(() {
          locationData = data['results'][0]['formatted_address'];
        });
        print(">>>>address:$locationData");
      } else {
        // Handle error or no results
        print('Error: ${data['status']}');
      }
    } else {
      // Handle network error
      print('Error: Failed to fetch address');
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

  Future<void> _showMeetingEditDialog(context) async {
    startTimeController.text = convertTime(meetingsData!.start!);

    endTimeController.text = convertTime(meetingsData!.end!);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      InkWell(
                        child: new Icon(Icons.close,
                            size: 22.0, color: Colors.black),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ]),
                    Text(
                      "Update meeting time",
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF0061b0),
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    timerPickerWidget(),
                  ],
                ),
              );
            }),
            // actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: updateMeeting,
                child: Text("Save Changes"),
                // style: ButtonStyle(
                //     backgroundColor: MaterialStateProperty.all<Color>(
                //         Colors.grey.withOpacity(0.3)))
              )
            ]);
      },
    );
  }

  String convertTime(String timeString) {
    final DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final DateFormat outputFormat = DateFormat('hh:mm a');

    DateTime dateTime = inputFormat.parse(timeString);
    String formattedTime = outputFormat.format(dateTime);

    return formattedTime;
  }

  timerPickerWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: "  Start Time",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'MyriadPro',
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: "  End Time",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'MyriadPro',
                            fontSize: 12)),
                  ],
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: GestureDetector(
                onTap: () {
                  _selectFromTime();
                },
                child: TextField(
                  controller: startTimeController,
                  enabled: false,
                  style: TextStyle(color: Colors.black, fontSize: 12),
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    contentPadding: EdgeInsets.all(15),
                    hintText: "Select Time",
                    hintStyle:
                        TextStyle(color: CustomColors.fontColor, fontSize: 12),
                    suffixIcon: Icon(
                      Icons.schedule,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selecttoTime();
                  });
                },
                child: TextField(
                  controller: endTimeController,
                  enabled: false,
                  style: TextStyle(color: Colors.black, fontSize: 12),
                  decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    contentPadding: EdgeInsets.all(15),
                    hintText: "Select Time",
                    hintStyle:
                        TextStyle(color: CustomColors.fontColor, fontSize: 12),
                    suffixIcon: Icon(
                      Icons.schedule,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  _selectFromTime() async {
    choosenFromTime = await showTimePicker(
      context: context,
      initialTime: choosenFromTime != null
          ? choosenFromTime!
          : TimeOfDay.fromDateTime(
              DateFormat("yyyy-MM-dd HH:mm:ss").parse(meetingsData!.start!)),
      initialEntryMode: TimePickerEntryMode.dial,
      confirmText: "CONFIRM",
      helpText: "SELECT TIME",
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false, textScaler: TextScaler.linear(1)),
          child: child!,
        );
      },
    );

    if (choosenFromTime != null) {
      final DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      DateTime startDateTime = inputFormat.parse(meetingsData!.start!);
      var currDate = DateTime.now();
      var currDateTime = "${currDate.day}-${currDate.month}-${currDate.year}";
      var date1 =
          "${startDateTime.day}-${startDateTime.month}-${startDateTime.year}";

      var startShift = DateTime(startDateTime.year, startDateTime.month,
          startDateTime.day, choosenFromTime!.hour, choosenFromTime!.minute);

      final endShift = DateTime(currDate.year, currDate.month, currDate.day,
          currDate.hour, currDate.minute);
      if (date1 == currDateTime) {
        if (startShift.isAfter(endShift)) {
          startTimeController.text = choosenFromTime!.format(context);
          startTime = startShift;
          endTimeController.text = "";
          choosenToTime = null;
          endTime = null;
        } else {
          AppUtils.showToastError(
            "Meetings can only be scheduled for future dates and times",
          );
          startTimeController.text = "";
        }
      } else if (startShift.isAfter(endShift)) {
        startTimeController.text = choosenFromTime!.format(context);
        startTime = startShift;
        endTimeController.text = "";
        choosenToTime = null;
        endTime = null;
      } else if (!startShift.isAfter(endShift)) {
        AppUtils.showToastError(
          "Meetings can only be scheduled for future dates and timese",
        );
      } else {
        AppUtils.showToastError("Time should not be above the to time");
        startTimeController.text = "";
      }
    }
  }

  _selecttoTime() async {
    choosenToTime = await showTimePicker(
      context: context,
      initialTime: choosenToTime != null
          ? choosenToTime!
          : TimeOfDay.fromDateTime(
              DateFormat("yyyy-MM-dd HH:mm:ss").parse(meetingsData!.end!)),
      initialEntryMode: TimePickerEntryMode.dial,
      confirmText: "CONFIRM",
      // cancelText: "NOT NOW",
      helpText: "SELECT TIME",
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false, textScaler: TextScaler.linear(1)),
          child: child!,
        );
      },
    );
    if (choosenToTime != null) {
      final DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      DateTime startDateTime = inputFormat.parse(meetingsData!.start!);
      DateTime endDateTime = inputFormat.parse(meetingsData!.end!);
      var startShift = DateTime(endDateTime.year, endDateTime.month,
          endDateTime.day, choosenToTime!.hour, choosenToTime!.minute);
      final endShift = choosenFromTime != null
          ? DateTime(endDateTime.year, endDateTime.month, endDateTime.day,
              choosenFromTime!.hour, choosenFromTime!.minute + 29)
          : DateTime(endDateTime.year, endDateTime.month, endDateTime.day,
              startDateTime.hour, startDateTime.minute + 29);
      final endShift2 = choosenFromTime != null
          ? DateTime(endDateTime.year, endDateTime.month, endDateTime.day,
              choosenFromTime!.hour, choosenFromTime!.minute)
          : DateTime(endDateTime.year, endDateTime.month, endDateTime.day,
              startDateTime.hour, startDateTime.minute);
      if (startShift == endShift2) {
        endTimeController.text = "";
        AppUtils.showToastError("The from and to time should not be same.");
      } else if (!startShift.isAfter(endShift)) {
        endTimeController.text = "";
        AppUtils.showToastError(
            "The end time must be at least 30 minutes ahead of the start time.");
      } else {
        endTimeController.text = choosenToTime!.format(context);
      }
    }
  }

  void updateMeeting() {
    //If times not changed
    print(">>>>che:$choosenFromTime,$choosenToTime");
    if (choosenFromTime == null && choosenToTime == null) {
      Navigator.of(context).pop();
      return;
    } else if (endTimeController.text.isEmpty) {
      AppUtils.showToastError("Please select end time.");
      // Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop();
    AppUtils.showprogress();
    UpdateMeetingReq updateMeetingReq = UpdateMeetingReq();
    final DateFormat inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime dateTime = inputFormat.parse(meetingsData!.end!);
    updateMeetingReq.start = choosenFromTime != null
        ? DateTime(dateTime.year, dateTime.month, dateTime.day,
                choosenFromTime!.hour, choosenFromTime!.minute)
            .toString()
            .substring(0, 19)
        : meetingsData!.start!;
    updateMeetingReq.end = choosenToTime != null
        ? DateTime(dateTime.year, dateTime.month, dateTime.day,
                choosenToTime!.hour, choosenToTime!.minute)
            .toString()
            .substring(0, 19)
        : meetingsData!.end!;
    updateMeetingReq.meetingId = meetingsData!.meetingId.toString();
    updateMeetingReq.type = meetingsData!.type!;
    updateMeetingReq.meeting = meetingsData!.imeetifyMeetingId;
    final api = Provider.of<ApiService>(context, listen: false);
    print(">>>>:${Strings.authToken}");
    print(">>>>:${jsonEncode(updateMeetingReq)}");
    api.updateMeeting(updateMeetingReq).then((response) {
      if (response.status!) {
        getMeetings();
        AppUtils.showToastSuccess("Meeting updated successfully!");
      } else {
        AppUtils.showToastError(response.message!);
      }
      AppUtils.dismissprogress();
    }).catchError((onError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError("Something went wrong!");
    });
  }

  void _showDeleteMeetingDialog(BuildContext context) {
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
          'Do you want to cancel this meeting',
          style: TextStyle(
              fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(
              'No',
              style: TextStyle(
                  fontSize: 16, color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: cancelMeeting,
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
  }

  void cancelMeeting() {
    CancelMeetingReq cancelMeetingReq = CancelMeetingReq();
    cancelMeetingReq.meeting = meetingsData!.imeetifyMeetingId!;
    cancelMeetingReq.type = meetingsData!.type;
    final api = Provider.of<ApiService>(context, listen: false);
    api.deleteMeeting(cancelMeetingReq).then((response) {
      if (response.status!) {
        AppUtils.showToastSuccess("Meeting cancelled successfully!");
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      AppUtils.showToastError("Something went wrong!");
      Navigator.of(context).pop();
    });
  }

  Future<void> shareFile() async {
    if ((meetingsData!.type == "1" &&
            Strings.urlRegex.hasMatch(meetingsData!.location!)) ||
        (meetingsData!.type == "2" &&
            Strings.urlRegex.hasMatch(meetingsData!.meetingLink!))) {
      await FlutterShare.share(
        title: "Share link",
        text: meetingsData!.title!,
        linkUrl: meetingsData!.type == "1"
            ? meetingsData!.location
            : meetingsData!.meetingLink,
      );
    } else {
      AppUtils.showToastError("Invalid URL");
    }
  }

  themeButton(
      {required String title, required Null Function() buttonfunction}) {
    return SizedBox(
      width: title == "share" ? width! * 0.15 : width! * 0.68,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.only(right: 0),
            foregroundColor: Colors.white,
            backgroundColor: CustomColors.primarycolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          onPressed: () => buttonfunction(),
          child: title == "share"
              ? Center(
                  child: Icon(
                    Icons.share_outlined,
                    size: 18,
                  ),
                )
              : Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600))),
    );
  }
}

Widget errorPage() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Something went wrong",
            style: TextStyle(color: Colors.grey, fontSize: 18)),
        SizedBox(
          height: 10,
        ),
        Text("Try refershing the page or try again later.",
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(
                    CustomColors.appthemecolor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: CustomColors.appthemecolor)))),
            onPressed: () {
              // setState(() {
              //   getProfile();
              //   Strings.serverError = false;
              //   // _isLoading2 = true;
              //   _isLoading1 = true;
              // });
            },
            child: Text("Retry", style: TextStyle(fontSize: 14))),
      ],
    ),
  );
}
