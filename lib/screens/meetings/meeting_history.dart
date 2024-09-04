import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mta/models/MeetingsDataRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/meetings/meeting_details.dart';
import 'package:mta/utilities/AppBarWidget.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:provider/provider.dart';

class MeetingHistory extends StatefulWidget {
  const MeetingHistory({super.key});

  @override
  State<MeetingHistory> createState() => _MeetingHistoryState();
}

class _MeetingHistoryState extends State<MeetingHistory> {
  List<MeetingsData> meetingsData = [];

  BuildContext? ctx;

  double? height;

  double? width;

  DateTime? picked;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getMeetings());
  }

  getMeetings() {
    final now = picked != null
        ? picked!
        : DateTime.now().subtract(const Duration(days: 1));
    final formatter = DateFormat('yyyy-MM-dd');
    final formattedDate = formatter.format(now);
    final api = Provider.of<ApiService>(context, listen: false);
    api.getMeetingHistory(formattedDate).then((response) {
      // AppUtils.dismissprogress();
      if (response.status!) {
        setState(() {
          meetingsData = response.data ?? [];
        });
      } else {
        setState(() {
          meetingsData = [];
        });
      }
    }).catchError((onError) {
      // AppUtils.dismissprogress();
      print(onError.toString());
      //getProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext newContext) {
            return MeetingHistoryWidget(newContext);
          },
        ),
      ),
    );
  }

  Widget MeetingHistoryWidget(BuildContext newContext) {
    ctx = newContext;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarWidget(
            backButtonfunction: () {
              Navigator.pop(context);
            },
            title: "Meeting History",
            actionWidget: [dateFilter()]),
      ),
      body: meetingsData.length > 0
          ? ListView.builder(
              itemCount: meetingsData.length,
              padding: EdgeInsets.all(20),
              itemBuilder: (BuildContext ctx, int index) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MeetingDetails(
                              fromHistory: true,
                              meeting_id: meetingsData[index].meetingId!)));
                    },
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: 60,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(14, 4, 15, 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(meetingsData[index].title!,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  Drawables.adddoccontentstyle(
                                                      Colors.black87,
                                                      14.0,
                                                      FontWeight.w500)),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                              AppUtils().getMeetingDateFormat(
                                                  meetingsData[index].start!,
                                                  meetingsData[index].end!),
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  Drawables.adddoccontentstyle(
                                                      Colors.grey,
                                                      12.0,
                                                      FontWeight.w300)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // meetingsData[index].type != "1"
                                //     ? Container(
                                //         width: 75,
                                //         height: 30,
                                //         child: ElevatedButton(
                                //           style: ElevatedButton.styleFrom(
                                //             backgroundColor:
                                //                 CustomColors.primarycolor,
                                //             shape: RoundedRectangleBorder(
                                //               borderRadius:
                                //                   BorderRadius.circular(8.0),
                                //             ),
                                //           ),
                                //           onPressed: () {},
                                //           child: Text(
                                //             'JOIN',
                                //             style:
                                //                 TextStyle(color: Colors.white),
                                //           ),
                                //         ),
                                //       )
                                //     : Container(),
                              ],
                            )),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              })
          : Center(child: Text("No Meetings Found")),
    );
  }

  dateFilter() {
    return TextButton(
      onPressed: selectDate,
      child: Row(
        children: [
          Text(
            CurrentDateWidget(),
            style: Drawables.adddoccontentstyle(
                Colors.black, 16.0, FontWeight.bold),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.black,
          )
        ],
      ),
    );
  }

  selectDate() async {
    picked = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: picked != null
          ? picked!
          : DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    if (picked != null) {
      getMeetings();
    }
    setState(() {});
  }

  CurrentDateWidget() {
    final now = picked != null
        ? picked!
        : DateTime.now().subtract(const Duration(days: 1));
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(now);
  }
}
