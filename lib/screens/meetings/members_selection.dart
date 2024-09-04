// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:mta/models/AddMeetingReq.dart';
import 'package:mta/models/AllTeamsRes.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/TeamUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/meetings/location_selection.dart';
import 'package:mta/screens/meetings/meetings_home.dart';
import 'package:mta/utilities/AppBarWidget.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/theme_button.dart';
import 'package:provider/provider.dart';

class MembersSelection extends StatefulWidget {
  AddMeetingReq? addMeetingData;
  List<String>? invitedMails;
  List<AllTeamsData>? selectedTeams;
  List<Data>? selectedProjects;
  MembersSelection(
      {super.key,
      required this.addMeetingData,
      required this.invitedMails,
      required this.selectedTeams,
      required this.selectedProjects});

  @override
  State<MembersSelection> createState() => _MembersSelectionState();
}

class _MembersSelectionState extends State<MembersSelection> {
  BuildContext? ctx;
  Map<String, List<UsersData>> teamUsersLists = {};
  Map<String, List<FetchMapedUsersData>> projectUsersLists = {};
  var extendedIndex;
  Map<String, bool> expandedStatus = {};

  List<String> selectedUsers = [];

  bool _switchValue = false;

  AddMeetingReq? addMeetingReq;

  final List<String> selectedInviteUsers = [];

  bool isButtonEnabled = false;

  int totalUserCount = 0;

  List totalUser = [];

  @override
  void initState() {
    super.initState();
    configData();
  }

  void configData() {
    AppUtils.showprogress();
    addMeetingReq = widget.addMeetingData;
    selectedInviteUsers.addAll(widget.invitedMails!);

    widget.addMeetingData!.meetingTypeId!.forEach((element) {
      if (widget.addMeetingData!.meetingType == "Team") {
        getTeamsUsers(element);
      } else {
        getProjectUsers(element);
      }
    });
    AppUtils.dismissprogress();
  }

  getTeamsUsers(team_id) {
    final api = Provider.of<ApiService>(context, listen: false);
    api.fetchTeamUsers(team_id).then((response) {
      if (response.status!) {
        setState(() {
          teamUsersLists["$team_id"] = response.data!;
        });

        for (var user in response.data!) {
          if (!totalUser.contains(user.email)) {
            totalUser.add(user.email!);
          }
        }
      } else {
        setState(() {
          teamUsersLists["$team_id"] = [];
        });
      }
    }).catchError((onError) {
      print(onError.toString());
    });
  }

  getProjectUsers(project_id) {
    // AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.fetchUsers(project_id).then((response) {
      // AppUtils.dismissprogress();
      if (response.status!) {
        setState(() {
          projectUsersLists["$project_id"] = response.data ?? [];
        });

        for (var user in response.data!) {
          if (!totalUser.contains(user.email)) {
            totalUser.add(user.email!);
          }
        }
      } else {
        setState(() {
          projectUsersLists["$project_id"] = [];
        });
      }
    }).catchError((onError) {
      // AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  String getTeamNameById(String id) {
    final matchingPerson = widget.selectedTeams!
        .firstWhere((person) => person.teamId == int.tryParse(id));
    return matchingPerson.teamName!;
  }

  String getProjectNameById(String id) {
    final matchingPerson = widget.selectedProjects!
        .firstWhere((person) => person.projectId == int.tryParse(id));
    return matchingPerson.projectName!;
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
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarWidget(
            backButtonfunction: () {
              Navigator.pop(context);
            },
            title: "Select members",
            actionWidget: []),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
        child: ThemeButton(
            title:
                widget.addMeetingData!.type == "2" ? "CREATE MEETING" : "NEXT",
            buttonfunction: submitData),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30, top: 30),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.invitedMails!.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Invited Members",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          // Row(
                          //   children: [
                          //     Text(
                          //       "Select all",
                          //       style: TextStyle(color: Colors.blue),
                          //     ),
                          //     Theme(
                          //       data: ThemeData(useMaterial3: false),
                          //       child: Switch(
                          //         activeColor: Colors.blue,
                          //         value: _inviteSwitchValue,
                          //         onChanged: (value) {
                          //           setState(() {
                          //             _inviteSwitchValue = value;
                          //           });
                          //           if (_inviteSwitchValue == true) {
                          //             print(">>>>>2");
                          //             for (var user in tempList) {
                          //               if (!selectedInviteUsers
                          //                   .contains(user)) {
                          //                 selectedInviteUsers.add(user);
                          //               }
                          //             }
                          //           } else {
                          //             selectedInviteUsers.clear();
                          //           }
                          //           setState(() {});
                          //         },
                          //       ),
                          //     ),
                          //   ],
                          // )
                        ],
                      )
                    : Container(),
                widget.invitedMails!.isNotEmpty
                    ? SizedBox(
                        height: 10,
                      )
                    : SizedBox(),
                widget.invitedMails!.isNotEmpty ? inviteList() : SizedBox(),
                widget.addMeetingData!.meetingTypeId!.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.addMeetingData!.meetingType == "Team"
                                ? "Teams"
                                : "Projects",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Row(
                            children: [
                              Text(
                                "Select all",
                                style: TextStyle(color: Colors.blue),
                              ),
                              Theme(
                                data: ThemeData(useMaterial3: false),
                                child: Switch(
                                  activeColor: Colors.blue,
                                  value: _switchValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _switchValue = value;
                                    });
                                    if (_switchValue == true) {
                                      if (widget.addMeetingData!.meetingType ==
                                          "Team") {
                                        teamUsersLists
                                            .forEach((groupName, users) {
                                          for (var user in users) {
                                            if (!selectedUsers
                                                .contains(user.email)) {
                                              selectedUsers.add(user.email!);
                                            }
                                          }
                                        });
                                      } else {
                                        projectUsersLists
                                            .forEach((groupName, users) {
                                          for (var user in users) {
                                            if (!selectedUsers
                                                .contains(user.email)) {
                                              selectedUsers.add(user.email!);
                                            }
                                          }
                                        });
                                      }
                                    } else {
                                      selectedUsers = [];
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    : Container(),
                SizedBox(height: 10),
                Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.fromSwatch()
                          .copyWith(secondary: Colors.white),
                    ),
                    child: widget.addMeetingData!.meetingType == "Team"
                        ? teamList()
                        : widget.addMeetingData!.meetingTypeId!.isNotEmpty
                            ? projectList()
                            : Container()),
                SizedBox(
                  height: 70,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  teamList() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: teamUsersLists.entries.map((entry) {
        String groupName = getTeamNameById(entry.key);
        List<UsersData> users = entry.value;
        return Container(
          margin: EdgeInsets.symmetric(
            vertical: 8.0,
          ), // Space between tiles
          padding: EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
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
                      fontSize: 16, fontWeight: FontWeight.bold), // Text color
                ),
                trailing: expandedStatus[groupName] ?? false
                    ? Icon(Icons.keyboard_arrow_up)
                    : Icon(Icons.keyboard_arrow_down),
              ),
              if (expandedStatus[groupName] ?? false)
                users.isEmpty
                    ? ListTile(title: Center(child: Text("No users found")))
                    : Column(
                        children: users.map((user) {
                          return ListTile(
                            title: Text(user.name!),
                            trailing: Checkbox(
                              onChanged: (val) {
                                if (val!) {
                                  selectedUsers.add(user.email!);

                                  if (totalUser.length ==
                                      selectedUsers.length) {
                                    _switchValue = true;
                                  }
                                } else {
                                  selectedUsers.remove(user.email);
                                  _switchValue = false;
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
    );
  }

  projectList() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: projectUsersLists.entries.map((entry) {
        String groupName = getProjectNameById(entry.key);
        List<FetchMapedUsersData> users = entry.value;
        return Container(
          margin: EdgeInsets.symmetric(
            vertical: 8.0,
          ), // Space between tiles
          padding: EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
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
                      fontSize: 16, fontWeight: FontWeight.bold), // Text color
                ),
                trailing: expandedStatus[groupName] ?? false
                    ? Icon(Icons.keyboard_arrow_up)
                    : Icon(Icons.keyboard_arrow_down),
              ),
              if (expandedStatus[groupName] ?? false)
                users.isEmpty
                    ? ListTile(title: Center(child: Text("No users found")))
                    : Column(
                        children: users.map((user) {
                          return ListTile(
                            title: Text(user.name!),
                            trailing: Checkbox(
                              onChanged: (val) {
                                if (val!) {
                                  selectedUsers.add(user.email!);
                                  if (totalUser.length ==
                                      selectedUsers.length) {
                                    _switchValue = true;
                                  }
                                } else {
                                  selectedUsers.remove(user.email);
                                  _switchValue = false;
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
    );
  }

  void submitData() {
    if (isButtonEnabled == false) {
      isButtonEnabled = true;
      setState(() {});
      if (widget.invitedMails!.isNotEmpty || selectedUsers.isNotEmpty) {
        selectedInviteUsers.forEach((element) {
          if (!addMeetingReq!.guestEmail!.contains(element)) {
            addMeetingReq!.guestEmail!.add(element);
          }
        });
        selectedUsers.forEach((element) {
          if (!addMeetingReq!.guestEmail!.contains(element)) {
            addMeetingReq!.guestEmail!.add(element);
          }
        });
        if (addMeetingReq!.type == "2") {
          addMeetingReq!.location = null;
          AppUtils.showprogress();
          final api = Provider.of<ApiService>(context, listen: false);
          api.createMeeting(addMeetingReq!).then((response) {
            if (response.status!) {
              AppUtils.showToastSuccess("Meeting created successfully!");

              isButtonEnabled = false;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => Meetings(),
                ),
                (route) => false,
              );
            } else {
              AppUtils.showErrorSnackBar(context, response.message!);
              isButtonEnabled = false;
            }
            AppUtils.dismissprogress();
          }).catchError((onError) {
            AppUtils.dismissprogress();
            isButtonEnabled = false;
            AppUtils.showToastError("Something went wrong!");
          });
        } else {
          isButtonEnabled = false;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  LocationSelection(addMeetingData: addMeetingReq!)));
        }
      } else {
        AppUtils.showToastError("Please select users!");
        isButtonEnabled = false;
      }
    }
  }

  inviteList() {
    return Column(
      children: widget.invitedMails!.map((user) {
        return ListTile(
          title: Text(user),
          trailing: Checkbox(
            onChanged: (val) {
              if (val!) {
                selectedInviteUsers.add(user);
              } else {
                selectedInviteUsers.remove(user);
              }
              setState(() {});
            },
            value: selectedInviteUsers
                .any((element) => element.toLowerCase() == user.toLowerCase()),
          ),
        );
      }).toList(),
    );
  }
}
