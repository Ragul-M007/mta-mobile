// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mta/utilities/app_drawer.dart';
import 'package:mta/blocs/meetings/meetings_home_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mta/models/MeetingsDataRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/meetings/create_meeting.dart';
import 'package:mta/screens/meetings/meeting_details.dart';
import 'package:mta/screens/meetings/meeting_history.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/customcolor.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _MeetingscontentState extends State<Meetingscontent> {
  List<MeetingsData> tempLists = [];
  List<MeetingsData> meetingsData = [];
  late final MeetingsHomeBloc _bloc;
  late final StreamSubscription<MeetingsHomeState> _blocSub;

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

  Future<void> _handleBackPressed() async {
    if (Strings.fromNotificationNewMeeting) {
      Strings.fromNotificationNewMeeting = false;
      Navigator.of(context).pushReplacementNamed('/notification');
      return;
    }

    _onWillPop();
  }

  bool meetingCraetionAccess = false;

  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();

  void initState() {
    super.initState();
    _bloc = MeetingsHomeBloc(ApiService.create());
    _blocSub = _bloc.stream.listen(_onBlocState);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _bloc.add(const MeetingsHomeRequested()));
  }

  @override
  void dispose() {
    _blocSub.cancel();
    _bloc.close();
    super.dispose();
  }

  /// Performs the UI side effects for [MeetingsHomeBloc] states — the spinner
  /// and setState of the meetings lists / access flag getProfile() did inline.
  void _onBlocState(MeetingsHomeState state) {
    if (state is MeetingsHomeLoading) {
      AppUtils.showprogress();
    } else if (state is UpcomingMeetingsLoaded) {
      AppUtils.dismissprogress();
      setState(() {
        tempLists = state.meetings;
        meetingsData = state.meetings;
      });
    } else if (state is UpcomingMeetingsEmpty) {
      AppUtils.dismissprogress();
      setState(() {
        tempLists = [];
        meetingsData = [];
      });
    } else if (state is MeetingAccessLoaded) {
      AppUtils.dismissprogress();
      setState(() {
        meetingCraetionAccess = state.access;
      });
    } else if (state is MeetingAccessError) {
      AppUtils.dismissprogress();
    }
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
    print(">>>>>>");
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
      } else {
        setState(() {
          tempLists = [];
        });
      }
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
    return PopScope(
                  canPop: false,
                  onPopInvoked: (didPop) {
                    if (didPop) {
                      return;
                    }
                    _handleBackPressed();
                  },
                  child: SafeArea(
                    child: Scaffold(
                      drawer: AppDrawer(),
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
                        leading: Builder(
                          builder: (ctx) => IconButton(
                            icon: Icon(
                              Icons.menu,
                              size: 25.0,
                              color: const Color(0xFF979797),
                            ),
                            onPressed: () {
                              Scaffold.of(ctx).openDrawer();
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
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => CreateMeeting(),
                                  ),
                                ).whenComplete(() => getMeetings());
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
                                              (meetingsData[index].type != "1") ||
                                                      meetingsData[index].type ==
                                                              "1" &&
                                                          meetingsData[index]
                                                                  .location !=
                                                              null &&
                                                          meetingsData[index]
                                                              .location!
                                                              .isNotEmpty &&
                                                          !meetingsData[index]
                                                              .location!
                                                              .contains(
                                                                  "Location Not Mentioned")
                                                  ? Container(
                                                      width: 75,
                                                      height: 30,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              CustomColors
                                                                  .primarycolor,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          launchLink(meetingsData[
                                                                          index]
                                                                      .type ==
                                                                  "1"
                                                              ? meetingsData[
                                                                      index]
                                                                  .location!
                                                              : meetingsData[
                                                                      index]
                                                                  .meetingLink!);
                                                        },
                                                        child:
                                                            (meetingsData[index]
                                                                        .type !=
                                                                    "1")
                                                                ? Text(
                                                                    'JOIN',
                                                                    style: TextStyle(
                                                                        fontWeight: Platform.isIOS
                                                                            ? FontWeight
                                                                                .bold
                                                                            : FontWeight
                                                                                .w700,
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .white),
                                                                  )
                                                                : Icon(
                                                                    Icons
                                                                        .directions_outlined,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 18,
                                                                  ),
                                                      ),
                                                    )
                                                  : Container(),
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
                  ),
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
