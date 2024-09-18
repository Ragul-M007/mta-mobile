import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mta/models/AllTeamsRes.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/AppBarWidget.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/chips_widget.dart';
import 'package:mta/utilities/customcolor.dart';
import 'package:mta/utilities/date_picker_widget.dart';
import 'package:mta/utilities/strings.dart';
import 'package:mta/utilities/theme_button.dart';
import 'package:provider/provider.dart';

import '../../models/AddMeetingReq.dart';
import '../../models/IntegratedMeetingsData.dart';
import 'members_selection.dart';

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
  TextEditingController endTimeController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  final titleController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController teamController = TextEditingController();
  TextEditingController projectController = TextEditingController();
  final typeController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  FocusNode teamFocusNode = FocusNode();
  FocusNode projectFocusNode = FocusNode();
  FocusNode mailsFocusNode = FocusNode();
  List<IntegratedMeetings> integratedMeetingsList = [];
  List<AllTeamsData> teamLists = [];
  List<AllTeamsData> selectedTeams = [];
  List<Data> projectsList = [];
  List<Data> selectedProjects = [];
  List<String> invitedMails = [];

  String? selectedType;
  String? selectedProvider;
  String? providerType;
  final List<Map> meetingTypes = [
    {"id": "1", "name": "In Person Meeting"},
    {"id": "2", "name": "Virtual Meeting"}
  ];
  // final List<Map> providerTypes = [
  //   {"id": "1", "name": "Zoom"},
  //   {"id": "2", "name": "Google Meet"}
  // ];

  DateTime? selectedDate;

  DateTime? startTime;
  DateTime? endTime;

  TimeOfDay? choosenFromTime;
  final now = DateTime.now();
  TimeOfDay? choosenToTime;
  void clearSelection() {
    setState(() {
      startTimeController.text = "";
      endTimeController.text = "";
      choosenFromTime = null;
    });
  }

  @override
  void initState() {
    super.initState();

    getIntegratedMeetings();
    print(">>>>token:${Strings.authToken}");
  }

  void _scrollToBottom() {
    // Scroll to the bottom of the scroll view
    print(">>>>sc:${_scrollController.position.maxScrollExtent}");
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 50),
      curve: Curves.easeInOut,
    );
  }

  getIntegratedMeetings() {
    final api = Provider.of<ApiService>(context, listen: false);
    api.fetchIntegratedMeetings().then((response) {
      if (response.status!) {
        integratedMeetingsList = response.data!;
      }
      getTeams();
    }).catchError((onError) {
      print(onError.toString());
    });
  }

  getTeams() {
    // AppUtils.showprogress();
    if (teamLists.isEmpty) {
      final api = Provider.of<ApiService>(context, listen: false);

      api.fetchAllTeams().then((response) {
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

      api.fetchAllProjects().then((response) {
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
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBarWidget(
              backButtonfunction: () {
                Navigator.pop(context);
              },
              title: "Create Meetings",
              actionWidget: []),
        ),
        floatingActionButton: Padding(
          padding:
              const EdgeInsets.only(left: 30.0, right: 30, top: 0, bottom: 20),
          child: ThemeButton(title: "NEXT", buttonfunction: submitData),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Container(
          padding: EdgeInsets.only(
              left: 30.0,
              right: 30,
              top: 30,
              bottom: MediaQuery.of(context).viewInsets.bottom > 0.0 ? 70 : 0),
          height: MediaQuery.of(context).size.height < 872
              ? MediaQuery.of(context).size.height * 0.75
              : MediaQuery.of(context).size.height * 0.82,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.03),
            child: Column(
              children: [
                formFields("  Meeting Title", "meetingTitle",
                    "eg: Site meeting", titleController, false),
                formFields("  Type of Meetings", "meetingType", "Select type",
                    typeController, false),
                selectedType == "2"
                    ? formFields("  Provider", "providerType",
                       integratedMeetingsList.isNotEmpty? "Select a provider":"No Data Found", typeController, false)
                    : Container(),
                formFields("  Invite Teams or Projects", "inviteTeams",
                    "Select a team", teamController, false),
                Padding(
                  padding: EdgeInsets.only(top: 15.0),
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
                    projectController, false),
                formFields("  Invite via Email (Optional)", "inviteMails",
                    "eg: email@address.com", emailController, false),
                formFields("  Meeting Date", "meetingDate", "Select date",
                    dateController, false),
                formFields(
                    "", "meetingTime", "Select Time", timeController, false),
                formFields("  Meeting Description", "meetingDescription",
                    "Type message..", descriptionController, false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  formFields(title, fieldType, hintText, controller, isMandatory) {
    return Padding(
      padding: EdgeInsets.only(top: fieldType != "inviteProjects" ? 15.0 : 0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field Heading
            fieldType != "meetingTime"
                ? RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: title,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'MyriadPro',
                                fontSize: 12)),
                        isMandatory
                            ? TextSpan(
                                text: ' *', style: TextStyle(color: Colors.red))
                            : TextSpan(),
                      ],
                    ),
                  )
                : fieldType == "meetingTime"
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "  Start Time",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'MyriadPro',
                                          fontSize: 12)),
                                  isMandatory
                                      ? TextSpan(
                                          text: ' *',
                                          style: TextStyle(color: Colors.red))
                                      : TextSpan(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "  End Time",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'MyriadPro',
                                          fontSize: 12)),
                                  isMandatory
                                      ? TextSpan(
                                          text: ' *',
                                          style: TextStyle(color: Colors.red))
                                      : TextSpan(),
                                ],
                              ),
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
                  height: fieldType == "meetingDescription"
                      ? MediaQuery.of(context).size.height * 0.15
                      : 45,
                  child: fieldType == "meetingTitle" ||
                          fieldType == "meetingDescription"
                      ? TextField(
                          onTap: () {
                            // if (fieldType == "meetingDescription") {
                            //   _scrollToBottom();
                            // }
                          },
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
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10)),
                          inputFormatters: fieldType == "meetingTitle"
                              ? [LengthLimitingTextInputFormatter(250)]
                              : null,
                          maxLines: fieldType == "meetingDescription" ? 5 : 1,
                        )
                      : fieldType == "meetingDate"
                          ? DatePickerWidget(
                              hintText: hintText,
                              onDateSelected: (date) {
                                selectedDate = date;
                                clearTimeSelection();
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
                                      ? dropdownType(true, hintText)
                                      : fieldType == "providerType"
                                          ? dropdownType(false, hintText)
                                          : fieldType == "meetingTime"
                                              ? timerPickerWidget()
                                              : fieldType == "inviteMails"
                                                  ? inviteMails(hintText)
                                                  : Container()),
            ),
            fieldType == "inviteTeams" && selectedTeams.isNotEmpty
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
                    mails: [],
                    onDeletedMail: (val) {},
                  )
                : fieldType == "inviteProjects" && selectedProjects.isNotEmpty
                    ? ChipsWidget(
                        projects: selectedProjects,
                        onDeletedProject: (data) {
                          setState(() {
                            selectedProjects.removeWhere((element) =>
                                element.projectId == data.projectId);
                            // to reload deleted data in autocomplete list
                            projectController.text = "a";
                            projectController.clear();
                          });
                        },
                        teams: [],
                        onDeleted: (val) {},
                        mails: [],
                        onDeletedMail: (val) {},
                      )
                    : fieldType == "inviteMails" && invitedMails.isNotEmpty
                        ? ChipsWidget(
                            mails: invitedMails,
                            onDeletedMail: (data) {
                              setState(() {
                                invitedMails
                                    .removeWhere((element) => element == data);
                                // to reload deleted data in autocomplete list
                                emailController.clear();
                              });
                            },
                            teams: [],
                            onDeleted: (val) {},
                            projects: [],
                            onDeletedProject: (val) {},
                          )
                        : Container()
          ],
        ),
      ),
    );
  }

  teamField(hintText) {
    return Container(
      child: Autocomplete<AllTeamsData>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.isEmpty) {
              // Return teams that are not in selectedTeams
              return teamLists
                  .where((team) => !selectedTeams.any(
                      (selectedTeam) => selectedTeam.teamId == team.teamId))
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
                  // to refresh auto complete field
                  projectController.text = "a";
                  projectController.clear();
                  setState(() {});
                  teamController.clear();
                } else {
                  teamController.clear();
                }
              }
            }
            teamFocusNode.unfocus();
          },
          displayStringForOption: (AllTeamsData option) =>
              option.teamName ?? '',
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                hintText: hintText,
              ),
            );
          }),
    );
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
              projectController.clear();
              setState(() {});
            } else {
              var isTrue = await clearDataWarning(true);
              if (isTrue) {
                selectedProjects.add(project);
                selectedTeams.clear();
                // to refresh auto complete field
                teamController.text = "a";
                teamController.clear();
                projectController.clear();
                setState(() {});
              } else {
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

  dropdownType(isTypeofMeeting, hintText) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          hintText,
          style: TextStyle(color: CustomColors.fontColor),
          overflow: TextOverflow.ellipsis,
        ),
        items: isTypeofMeeting
            ? meetingTypes
                .map((Map item) => DropdownMenuItem<String>(
                      value: item['id'],
                      child: Text(
                        item['name'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList()
            : integratedMeetingsList
                .map<DropdownMenuItem<String>>((IntegratedMeetings provider) {
                return DropdownMenuItem<String>(
                  value: provider.provider
                      .toString(), // Use the provider's ID as the value
                  child: Text(
                      provider.providerName!), // Display the provider's name
                );
              }).toList(),
        value: isTypeofMeeting ? selectedType : selectedProvider,
        onChanged: (String? value) {
          if (isTypeofMeeting) {
            selectedType = value;
            if (value == "1") {
              selectedProvider == null;
            }
          } else {
            selectedProvider = value;
          }
          setState(() {});
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

  Future<void> submitData() async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool isValid = await meetingValidation();

    if (isValid) {
      AddMeetingReq addMeetingReq = AddMeetingReq();
      addMeetingReq.inviteeTimezone = "Asia/Kolkata";

      addMeetingReq.title = titleController.text;
      addMeetingReq.description = descriptionController.text;
      addMeetingReq.end = DateTime(selectedDate!.year, selectedDate!.month,
              selectedDate!.day, endTime!.hour, endTime!.minute)
          .toString()
          .substring(0, 19);
      ;
      addMeetingReq.start = DateTime(selectedDate!.year, selectedDate!.month,
              selectedDate!.day, startTime!.hour, startTime!.minute)
          .toString()
          .substring(0, 19);
      ;
      addMeetingReq.type = selectedType;
      addMeetingReq.provider =
          selectedType == "1" ? "2" : selectedProvider ?? "";
      addMeetingReq.meetingType = selectedTeams.isNotEmpty ? "Team" : "Project";
      print("loqinrequest --->${invitedMails}, ${jsonEncode(addMeetingReq)}");
      addMeetingReq.guestEmail = [];
      addMeetingReq.meetingTypeId = (selectedTeams.isNotEmpty
              ? selectedTeams.map((item) => item.teamId).toList()
              : selectedProjects.map((item) => item.projectId).toList())
          .cast<int>();
      print("loqinrequest ---> ${jsonEncode(addMeetingReq)}");
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MembersSelection(
                addMeetingData: addMeetingReq,
                selectedTeams: selectedTeams,
                invitedMails: invitedMails,
                selectedProjects: selectedProjects,
              )));
    }
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
          !isTeamSelection
              ? "Please choose either a project or a team. Clicking 'Yes' will confirm your team choice and cancel any project selections."
              : "Please choose either a project or a team. Clicking 'Yes' will confirm your project choice and cancel any team selections.",
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

  bool meetingValidation() {
    if (titleController.text.isEmpty) {
      AppUtils.showToastError("Please provide meeting title.");
      return false;
    } else if (descriptionController.text.isEmpty) {
      AppUtils.showToastError("Please provide meeting description.");
      return false;
    } else if (selectedType == null) {
      AppUtils.showToastError("Please select a meeting type.");
      return false;
    } else if (selectedType == "2" &&
        providerType == null &&
        selectedProvider == null) {
      AppUtils.showToastError("Please select a provider type.");
      return false;
    } else if (selectedDate == null) {
      AppUtils.showToastError("Please select a date.");
      return false;
    } else if (startTime == null) {
      AppUtils.showToastError("Please select a start time.");
      return false;
    } else if (endTime == null) {
      AppUtils.showToastError("Please select an end time.");
      return false;
    } else if (invitedMails.isEmpty &&
        selectedProjects.isEmpty &&
        selectedTeams.isEmpty) {
      AppUtils.showToastError(
          "Please select at least one team, project, or add a member's email");
      return false;
    } else {
      return true;
    }
  }

  inviteMails(hintText) {
    final RegExp _emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?");
    return Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) async {
          if (textEditingValue.text.isNotEmpty) {
            return _emailRegExp.hasMatch(textEditingValue.text)
                ? [textEditingValue.text]
                : [];
          } else {
            return [];
          }
        },
        onSelected: (mail) async {
          if (!invitedMails.contains(mail)) {
            invitedMails.add(mail);
            setState(() {});
            emailController.clear();
          } else {
            AppUtils.showToastError("Already existing mail.");
          }
          mailsFocusNode.unfocus();
        },
        displayStringForOption: (option) => option,
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          emailController = controller;
          mailsFocusNode = focusNode;
          return TextField(
            enabled: teamLists.isNotEmpty,
            controller: emailController,
            focusNode: mailsFocusNode,
            onEditingComplete: () {
              mailsFocusNode.unfocus();
            },
            onSubmitted: (String value) {
              onFieldSubmitted();
              emailController.clear();
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

  timerPickerWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: GestureDetector(
            onTap: () {
              if (selectedDate != null) {
                _selectFromTime();
              } else {
                AppUtils.showToastError("Date should be select before time");
              }
            },
            child: TextField(
              controller: startTimeController,
              enabled: false,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding: EdgeInsets.all(15),
                hintText: "Select Time",
                hintStyle: TextStyle(color: CustomColors.fontColor),
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
          width: MediaQuery.of(context).size.width * 0.4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (choosenFromTime != null) {
                  _selecttoTime();
                } else {
                  AppUtils.showToastError("Please select the start time");
                }
              });
            },
            child: TextField(
              controller: endTimeController,
              enabled: false,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding: EdgeInsets.all(15),
                hintText: "Select Time",
                hintStyle: TextStyle(color: CustomColors.fontColor),
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
    );
  }

  _selectFromTime() async {
    choosenFromTime = await showTimePicker(
      context: context,
      initialTime: choosenFromTime != null ? choosenFromTime! : TimeOfDay.now(),
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
      setState(() {
        var currDate = DateTime.now();
        var currDateTime = "${currDate.day}-${currDate.month}-${currDate.year}";

        var date1 =
            "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}";
        var startShift = DateTime(selectedDate!.year, selectedDate!.month,
            selectedDate!.day, choosenFromTime!.hour, choosenFromTime!.minute);
        final endShift =
            DateTime(now.year, now.month, now.day, now.hour, now.minute);
        if (selectedDate != null && date1 == currDateTime) {
          if (endTimeController.text == "") {
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
          } else {
            ///To check selected time is greater than the current time
            if (startShift.isAfter(endShift)) {
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
        } else {
          startTimeController.text = choosenFromTime!.format(context);
          startTime = startShift;
          endTimeController.text = "";
          choosenToTime = null;
          endTime = null;
        }
      });
    }
  }

  _selecttoTime() async {
    choosenToTime = await showTimePicker(
      context: context,
      initialTime: choosenToTime != null ? choosenToTime! : TimeOfDay.now(),
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
    if (choosenFromTime == null) {
      AppUtils.showToastError("Select start time");
      return;
    }
    if (choosenToTime != null) {
      setState(() {
        var time = DateTime.now();
        var startShift = DateTime(selectedDate!.year, selectedDate!.month,
            selectedDate!.day, choosenToTime!.hour, choosenToTime!.minute);
        if (choosenFromTime == null) {
          choosenFromTime = TimeOfDay.fromDateTime(DateTime(
              time.year,
              time.month,
              time.day,
              choosenFromTime!.hour,
              choosenFromTime!.minute));
        }
        var t2 = choosenFromTime;
        final endShift = DateTime(selectedDate!.year, selectedDate!.month,
            selectedDate!.day, t2!.hour, t2.minute + 29);
        if (choosenFromTime!.format(context) ==
            choosenToTime!.format(context)) {
          AppUtils.showToastError("The from and to time should not be same.");
          endTimeController.text = "";
        } else if (startShift.isAfter(endShift)) {
          endTimeController.text = choosenToTime!.format(context);
          endTime = startShift;
        } else {
          AppUtils.showToastError(
              "The end time must be at least 30 minutes ahead of the start time.");
          endTimeController.text = "";
        }
      });
    }
  }

  void clearTimeSelection() {
    setState(() {
      startTimeController.text = "";
      endTimeController.text = "";
      choosenFromTime = null;
      choosenToTime = null;
    });
  }
}
