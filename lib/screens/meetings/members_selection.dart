import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/AddMeetingReq.dart';
import 'package:mta/models/TeamUsersRes.dart';
import 'package:mta/models/TeamsModel.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';

class MembersSelection extends StatefulWidget {
  final AddMeetingReq addMeetingReq;
  List<TeamsData>? selectedTeams;
  MembersSelection(
      {super.key, required this.addMeetingReq, required this.selectedTeams});

  @override
  State<MembersSelection> createState() => _MembersSelectionState();
}

class _MembersSelectionState extends State<MembersSelection> {
  BuildContext? ctx;
  Map<String, List<UsersData>> teamUsersLists = {};
  var extendedIndex;
  Map<String, bool> expandedStatus = {};

  List<String> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    if (widget.addMeetingReq.meetingType == "Team") {
      widget.addMeetingReq.meetingTypeId!.forEach((element) {
        getTeamsUsers(element);
      });
    } else {}
  }

  getTeamsUsers(team_id) {
    log(">>>>>:${Strings.authToken}");
    // AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.fetchTeamUsers(team_id).then((response) {
      // AppUtils.dismissprogress();
      if (response.status!) {
        setState(() {
          teamUsersLists["$team_id"] = response.data!;
        });
        log(">>>>data:${jsonEncode(teamUsersLists)}");
      }
    }).catchError((onError) {
      // AppUtils.dismissprogress();
      print(onError.toString());
      //getProjects();
    });
  }

  String getNameById(String id) {
    final matchingPerson = widget.selectedTeams!
        .firstWhere((person) => person.teamId == int.tryParse(id));
    return matchingPerson.teamName!;
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext newContext) {
            return membersSelectionWidget(newContext);
          },
        ),
      ),
    );
  }

  Widget membersSelectionWidget(BuildContext context) {
    ctx = context;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.1, 1.0),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(30.0)),
            ),
            elevation: 0,
            title: Text(
              "Select members",
              style: Drawables.adddoccontentstyle(
                  Colors.black, 16.0, FontWeight.bold),
            ),
            leading: SizedBox(
              height: 25.0,
              width: 25.0,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 25.0,
                  color: const Color(0xFF979797),
                ),
                onPressed: () {},
              ),
            ),
          ),
        ),
        preferredSize: Size.fromHeight(kToolbarHeight),
      ),
      body: Container(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.addMeetingReq.meetingType == "Team" ? "Teams" : "Projects",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSwatch()
                        .copyWith(secondary: Colors.white),
                  ),
                  child: ListView(
                    children: teamUsersLists.entries.map((entry) {
                      String groupName = getNameById(entry.key);
                      List<UsersData> users = entry.value;
                      return Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 8.0,
                        ), // Space between tiles
                        padding: EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color
                          borderRadius:
                              BorderRadius.circular(12.0), // Rounded corners
                          border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1), // Border color and width
                          boxShadow: [
                            // Optional: shadow for better appearance
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListTile(
                              onTap: () {
                                setState(() {
                                  expandedStatus[groupName] =
                                      !(expandedStatus[groupName] ?? false);
                                });
                              },
                              title: Text(
                                groupName,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold), // Text color
                              ),
                              trailing: expandedStatus[groupName] ?? false
                                  ? Icon(Icons.keyboard_arrow_up)
                                  : Icon(Icons.keyboard_arrow_down),
                            ),
                            if (expandedStatus[groupName] ?? false)
                              Column(
                                children: users.map((user) {
                                  return ListTile(
                                    title: Text(user.name!),
                                    trailing: Checkbox(
                                      onChanged: (val) {
                                        if (val!) {
                                          selectedUsers.add(user.email!);
                                        } else {
                                          selectedUsers.remove(user.email);
                                        }
                                        setState(() {});
                                      },
                                      value: selectedUsers.any((element) =>
                                          element.toLowerCase() ==
                                          user.email!.toLowerCase()),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
