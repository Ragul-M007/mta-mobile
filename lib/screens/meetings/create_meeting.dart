import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mta/models/AddMeetingReq.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/TeamsModel.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/meetings/members_selection.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/chips_widget.dart';
import 'package:mta/utilities/customcolor.dart';
import 'package:mta/utilities/date_picker_widget.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:mta/utilities/theme_button.dart';
import 'package:mta/utilities/time_picker_widget.dart';
import 'package:provider/provider.dart';

class CreateMeeting extends StatelessWidget {
  const CreateMeeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: CreateMeetingContent(),
    );
  }
}

class CreateMeetingContent extends StatefulWidget {
  const CreateMeetingContent({super.key});

  @override
  State<CreateMeetingContent> createState() => _CreateMeetingContentState();
}

class _CreateMeetingContentState extends State<CreateMeetingContent> {
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final titleController = TextEditingController();
  final emailController = TextEditingController();
  TextEditingController teamController = TextEditingController();
  TextEditingController projectController = TextEditingController();
  final typeController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  FocusNode teamFocusNode = FocusNode();
  FocusNode projectFocusNode = FocusNode();
  List<TeamsData> teamLists = [];
  List<TeamsData> selectedTeams = [];
  List<Data> projectsList = [];
  List<Data> selectedProjects = [];

  String? selectedType;
  final List<String> meetingTypes = ["In Person Meeting", "Virtual Meeting"];

  DateTime? selectedDate;

  String? startTime;
  String? endTime;
  @override
  void initState() {
    super.initState();
    getTeams();
  }

  void _scrollToBottom() {
    // Scroll to the bottom of the scroll view
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  getTeams() {
    // AppUtils.showprogress();
    if (teamLists.isEmpty) {
      final api = Provider.of<ApiService>(context, listen: false);

      api.fetchTeams().then((response) {
        // AppUtils.dismissprogress();
        if (response.status!) {
          teamLists = response.data!;
        }
        getProjects();
      }).catchError((onError) {
        // AppUtils.dismissprogress();
        print(onError.toString());
        //getProjects();
      });
    }
  }

  getProjects() {
    if (projectsList.isEmpty) {
      final api = Provider.of<ApiService>(context, listen: false);

      api.projects(4).then((response) {
        if (response.status!) {
          projectsList = response.data!;
          setState(() {});
        }
      }).catchError((onError) {
        print(onError.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        child: Container(
          decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(30.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.1, 1.0),
                  blurRadius: 6.0,
                ),
              ]),
          child: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(30.0))),
            elevation: 0,
            title: Text(
              "Create Meetings",
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
                )),
          ),
        ),
        preferredSize: Size.fromHeight(kToolbarHeight),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30.0, right: 30, top: 30),
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.1),
                child: Column(
                  children: [
                    formFields("  Meeting Title", "meetingTitle",
                        "eg: Site meeting", titleController),
                    formFields("  Type of Meetings", "meetingType",
                        "Select type", typeController),
                    formFields("  Invite Teams or Projects", "inviteTeams",
                        "Select a team", teamController),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.37,
                              child: Divider(
                                color: Colors.grey.withOpacity(0.8),
                                height: 1,
                              ),
                            ),
                          ),
                          Text("or"),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.37,
                              child: Divider(
                                color: Colors.grey.withOpacity(0.8),
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    formFields("", "inviteProjects", "Select a project",
                        projectController),
                    formFields("  Meeting Date*", "meetingDate", "Select date",
                        dateController),
                    formFields(
                        "", "meetingTime", "Select Time", timeController),
                    formFields("  Meeting Description", "meetingDescription",
                        "Type message..", descriptionController),
                    formFields(
                        "  Invite Others By Name or Email",
                        "inviteMails",
                        "eg: email@address.com",
                        emailController),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 0, top: 10),
                child: ThemeButton(title: "NEXT", buttonfunction: submitData),
              ),
            )
          ],
        ),
      ),
    );
  }

  formFields(title, fieldType, hintText, controller) {
    return Padding(
      padding: EdgeInsets.only(top: fieldType != "inviteProjects" ? 15.0 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field Heading
          fieldType != "meetingTime"
              ? Text(title)
              : fieldType != "inviteProjects"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Text(
                            "  Start Time",
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Text(
                            "  End Time",
                          ),
                        )
                      ],
                    )
                  : Container(),
          // Form Input Fields
          Padding(
            padding:
                EdgeInsets.only(top: fieldType != "inviteProjects" ? 8.0 : 0),
            child: SizedBox(
                height: 45,
                child: fieldType != "meetingTime" &&
                        fieldType != "meetingDate" &&
                        fieldType != "inviteTeams" &&
                        fieldType != "inviteProjects" &&
                        fieldType != "meetingType"
                    ? TextField(
                        controller: controller,
                        decoration: new InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          hintText: hintText,
                        ),
                      )
                    : fieldType == "meetingDate"
                        ? DatePickerWidget(
                            hintText: hintText,
                            onDateSelected: (date) {
                              print(">>>>>:${date.day}");
                              selectedDate = date;
                              setState(() {});
                            },
                          )
                        : fieldType == "inviteTeams"
                            ? teamField(teamLists.isNotEmpty
                                ? hintText
                                : "No teams found")
                            : fieldType == "inviteProjects"
                                ? projectField(projectsList.isNotEmpty
                                    ? hintText
                                    : "No projects found")
                                : fieldType == "meetingType"
                                    ? meetingType(hintText)
                                    : TimerPickerWidget(
                                        selectedDate:
                                            selectedDate ?? DateTime.now(),
                                        isDateSelected: selectedDate != null,
                                        onSelectedFromTime: (fromTime) {
                                          DateTime dateTime = DateTime.parse(
                                              fromTime.toString());
                                          startTime = dateTime
                                              .toString()
                                              .substring(0, 19);
                                        },
                                        onSelectedToTime: (toTime) {
                                          DateTime dateTime =
                                              DateTime.parse(toTime.toString());
                                          endTime = dateTime
                                              .toString()
                                              .substring(0, 19);
                                        })),
          ),
          fieldType == "inviteTeams"
              ? ChipsWidget(
                  teams: selectedTeams,
                  onDeleted: (data) {
                    setState(() {
                      selectedTeams.removeWhere(
                          (element) => element.teamId == data.teamId);
                      // to reload deleted data in autocomplete list
                      teamController.text = "a";
                      teamController.clear();
                    });
                  },
                  projects: [],
                  onDeletedProject: (val) {},
                )
              : fieldType == "inviteProjects"
                  ? ChipsWidget(
                      projects: selectedProjects,
                      onDeletedProject: (data) {
                        setState(() {
                          selectedProjects.removeWhere(
                              (element) => element.projectId == data.projectId);
                          // to reload deleted data in autocomplete list
                          projectController.text = "a";
                          projectController.clear();
                        });
                      },
                      teams: [],
                      onDeleted: (val) {},
                    )
                  : Container()
        ],
      ),
    );
  }

  teamField(hintText) {
    return Autocomplete<TeamsData>(
        optionsBuilder: (TextEditingValue textEditingValue) async {
          if (textEditingValue.text.isEmpty) {
            return teamLists
                .where((team) => !selectedTeams
                    .any((selectedTeam) => selectedTeam.teamId == team.teamId))
                .toList();
          } else {
            // Return filtered teams that are not in selectedTeams
            return teamLists.where((teamData) {
              final isNotSelected = !selectedTeams.any(
                  (selectedTeam) => selectedTeam.teamId == teamData.teamId);
              return isNotSelected &&
                  teamData.teamName!
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
            }).toList();
          }
        },
        onSelected: (team) async {
          if (selectedTeams.any((element) => element.teamId == team.teamId)) {
          } else {
            if (selectedProjects.isEmpty) {
              selectedTeams.add(team);
              setState(() {});
              teamController.clear();
            } else {
              var isTrue = await clearDataWarning(false);
              if (isTrue) {
                selectedTeams.add(team);
                selectedProjects.clear();
                setState(() {});
                teamController.clear();
              }
            }
          }
          teamFocusNode.unfocus();
        },
        displayStringForOption: (TeamsData option) => option.teamName ?? '',
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          teamController = controller;
          teamFocusNode = focusNode;
          return TextField(
            enabled: teamLists.isNotEmpty,
            controller: teamController,
            focusNode: teamFocusNode,
            onEditingComplete: () {
              teamFocusNode.unfocus();
            },
            onSubmitted: (String value) {
              onFieldSubmitted();
              teamController.clear();
              focusNode.unfocus();
            },
            decoration: new InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: hintText,
            ),
          );
        });
  }

  projectField(hintText) {
    return Autocomplete<Data>(
        optionsBuilder: (TextEditingValue textEditingValue) async {
          if (textEditingValue.text.isEmpty) {
            return projectsList
                .where((project) => !selectedProjects.any((selectedProject) =>
                    selectedProject.projectId == project.projectId!))
                .toList();
          } else {
            // Return filtered projects that are not in selectedProjects
            return projectsList.where((projectData) {
              final isNotSelected = !selectedProjects.any((selectedProject) =>
                  selectedProject.projectId == projectData.projectId);
              return isNotSelected &&
                  projectData.projectName!
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
            }).toList();
          }
        },
        onSelected: (project) async {
          if (selectedProjects
              .any((element) => element.projectId == project.projectId)) {
          } else {
            if (selectedTeams.isEmpty) {
              selectedProjects.add(project);
              setState(() {});
              projectController.clear();
            } else {
              var isTrue = await clearDataWarning(true);
              if (isTrue) {
                selectedProjects.add(project);
                selectedTeams.clear();
                setState(() {});
                projectController.clear();
              }
            }
          }
          projectFocusNode.unfocus();
        },
        displayStringForOption: (Data option) => option.projectName ?? '',
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          projectController = controller;
          projectFocusNode = focusNode;
          return TextField(
            enabled: projectsList.isNotEmpty,
            controller: projectController,
            focusNode: projectFocusNode,
            onEditingComplete: () {
              projectFocusNode.unfocus();
            },
            onSubmitted: (String value) {
              onFieldSubmitted();
              projectController.clear();
              focusNode.unfocus();
            },
            decoration: new InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: hintText,
            ),
          );
        });
  }

  meetingType(hintText) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          hintText,
          style: TextStyle(color: CustomColors.fontColor),
          overflow: TextOverflow.ellipsis,
        ),
        items: meetingTypes
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        value: selectedType,
        onChanged: (String? value) {
          setState(() {
            selectedType = value;
          });
        },
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.only(left: 0, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.grey,
            ),
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          offset: const Offset(0, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all<double>(6),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
      ),
    );
  }

  void submitData() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    AddMeetingReq addMeetingReq = AddMeetingReq();
    addMeetingReq.title = titleController.text;
    addMeetingReq.inviteeEmail = emailController.text;
    addMeetingReq.description = descriptionController.text;
    addMeetingReq.end = endTime;
    addMeetingReq.start = startTime;
    addMeetingReq.type = selectedType;
    addMeetingReq.meetingType = selectedTeams.isNotEmpty ? "Team" : "Project";
    addMeetingReq.meetingTypeId = selectedTeams.isNotEmpty
        ? selectedTeams.map((item) => item.teamId!).toList()
        : selectedProjects.map((item) => item.projectId!).toList();
    print("loqinrequest ---> ${jsonEncode(addMeetingReq)}");

    AppUtils.dismissprogress();
    // api.login(loginreq).then((response) {});

    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => MembersSelection(addMeetingReq: addMeetingReq)));
  }

  clearDataWarning(bool isTeamSelection) async {
    var data = await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text(
          "Alert",
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFF0061b0),
              fontWeight: FontWeight.w600),
        ),
        content: Text(
          isTeamSelection
              ? "Please make sure you have selected either a project or a team. Clicking 'Yes' will confirm your team selection and remove any project selections."
              : "Please make sure you have selected either a project or a team. Clicking 'Yes' will confirm your project selection and remove any team selections.",
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
            onPressed: () => Navigator.of(context).pop(true),
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
    return data;
  }
}
