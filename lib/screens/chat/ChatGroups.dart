import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mta/blocs/chat/chat_groups_bloc.dart';
import 'package:mta/models/Chat/GroupChatListRes.dart';
import 'package:mta/models/Chat/GroupCreationReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/chat/ChatScreen.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';

import 'package:path/path.dart' as path;

import '../../utilities/apputilities.dart';
import 'AddUsers.dart';

class ChatGroups extends StatefulWidget {
  // static const String routeName = "/chatGroups";
  final int? teamId;
  final int? projectId;
  final bool? fromTeamProjects;

  ChatGroups({this.teamId, this.projectId, this.fromTeamProjects});

  @override
  _ChatGroupsState createState() => _ChatGroupsState();
}

class _ChatGroupsState extends State<ChatGroups> {
  WebViewController controller = WebViewController();

  late final ChatGroupsBloc _bloc;
  late final StreamSubscription<ChatGroupsState> _blocSub;

  BuildContext? ctx;
  bool loading = true;

  List<GroupDetails> _searchLists = [];
  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();
  TextEditingController _groupNameFieldController = TextEditingController();
  TextEditingController _groupDescriptionFieldController =
      TextEditingController();

  List<GroupDetails> groupList = [];
  FocusNode groupNameFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();
  String? filepath;
  var dio = Dio();

  String _errText = "";
  void initState() {
    _bloc = ChatGroupsBloc(ApiService.create());
    _blocSub = _bloc.stream.listen(_onBlocState);
    super.initState();
    print(">>>kkkkk");
    connectSocket();
    fetchChatCreateAcess();
  }

  @override
  void dispose() {
    _blocSub.cancel();
    _bloc.close();
    super.dispose();
  }

  void _onBlocState(ChatGroupsState state) {
    if (!mounted) return;
    if (state is ChatGroupsAccessLoaded) {
      setState(() {
        Strings.groupCreationAccess = state.groupCreateAccess;
      });
    } else if (state is ChatGroupsLoaded) {
      setState(() {
        groupList.clear();
        for (var item in state.items) {
          groupList.add(item);
        }
        loading = false;
      });
    } else if (state is ChatGroupsLoadedNoMatch) {
      setState(() {
        loading = false;
      });
    } else if (state is ChatGroupsCreateLoading) {
      AppUtils.showprogress();
    } else if (state is ChatGroupsCreateOk) {
      AppUtils.dismissprogress();
      _groupNameFieldController.clear();
      _groupDescriptionFieldController.clear();
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRemoveUsersIntoGroups(
            groupId: 0,
            teamId: widget.teamId,
            projectId: widget.projectId,
            fromCreateGroup: true,
            groupData: state.req,
          ),
        ),
      ).whenComplete(() => connectSocket());
    } else if (state is ChatGroupsCreateFailed) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(state.message);
    } else if (state is ChatGroupsCreateError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(state.message);
    }
  }

  fetchChatCreateAcess() {
    _bloc.add(const ChatGroupsAccessRequested());
  }

  connectSocket() {
    _bloc.add(ChatGroupsConnect(widget.projectId, widget.teamId));
  }

  String getFileName(String _path) {
    return path.basename(_path);
  }

  createGroup() {
    print("dataaa ${widget.teamId}");
    GroupCreationReq req = GroupCreationReq();
    req.groupCreatedBy = Strings.userID;
    req.groupImage = null;
    req.groupName = _groupNameFieldController.text;
    req.groupDescription = _groupDescriptionFieldController.text;
    req.teamId = widget.teamId;
    req.projectId = widget.projectId;
    req.groupType = widget.projectId == null ? "team" : "project";

    _bloc.add(ChatGroupsCreateRequested(req, _groupNameFieldController.text));
  }

  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: WillPopScope(
        onWillPop: () async {
          print(
              ">>>>>>kkk2:${widget.projectId},${widget.fromTeamProjects},${Strings.fromTeamProjects}");
          if (widget.projectId == null) {
            Navigator.of(context).pushReplacementNamed("/teamsDashboard");
          } else if (widget.fromTeamProjects == true ||
              Strings.fromTeamProjects) {
            Strings.fromTeamProjects = false;
            Navigator.of(context).pushReplacementNamed("/dashboard");
          } else {
            Navigator.of(context).pushReplacementNamed("/projects");
          }
          return false;
        },
        child: loading
            ? Center(
                child: Container(
                    height: 30, width: 30, child: CircularProgressIndicator()))
            : SafeArea(
              child: Scaffold(
                  floatingActionButton: Strings.groupCreationAccess == 1
                      ? InkWell(
                          onTap: () {
                            // upload();
                            _showMyDialog(context);
                          },
                          child: CircleAvatar(
                            radius: 20,
                            child: Icon(
                              Icons.people_rounded,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.grey.withOpacity(0.8),
                          ),
                        )
                      : Container(),
                  backgroundColor: const Color(0xFFececed),
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    title: Text("Chats"),
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
                                        onChanged: (value) {
                                          if (value.isEmpty) {
                                            setState(() {
                                              _searchLists = [];
                                            });
                                            return;
                                          }
                                          _searchLists = [];
                                          groupList.forEach((list) {
                                            if (list.groupName!
                                                .toLowerCase()
                                                .startsWith(value.toLowerCase()))
                                              _searchLists.add(list);
                                          });
                                          print("dataaaa ${_searchLists.length}");
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
                        )),
                    leading: SizedBox(
                      height: 25.0,
                      width: 25.0,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 25.0,
                          color: const Color(0xFF979797),
                        ),
                        onPressed: () {
                          if (widget.projectId == null) {
                            Navigator.pushNamed(context, "/teamsDashboard");
                          } else if (widget.fromTeamProjects == true ||
                              Strings.fromTeamProjects) {
                            Strings.fromTeamProjects = false;
                            Navigator.pushNamed(context, "/dashboard");
                          } else {
                            Navigator.pushNamed(context, "/projects");
                          }
                          searchField.unfocus();
                        },
                      ),
                    ),
                  ),
                  body: Builder(builder: (BuildContext newContext) {
                    ctx = newContext;
                    return groupList.length > 0
                        ? _searchLists.length != 0
                            ? ListView.builder(
                                padding: EdgeInsets.all(8),
                                itemBuilder: (BuildContext ctx, int index) {
                                  return Padding(
                                    padding: EdgeInsets.all(8),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => ChatScreen(
                                        //       groupId: groupList[index].groupId!,
                                        //       teamId: widget.teamId,
                                        //     ),
                                        //   ),
                                        // );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              teamName:
                                                  _searchLists[index].groupName ??
                                                      "No name",
                                              groupId:
                                                  _searchLists[index].groupId!,
                                              teamId: widget.teamId,
                                              projectId: widget.projectId,
                                            ),
                                          ),
                                        ).then((value) {
                                          setState(() {
                                            _searchLists.clear();
                                            _searchFieldController.clear();
                                          });
                                        });
                                      },
                                      child: Container(
                                        child: Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                12, 14, 12, 14),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        _searchLists[index]
                                                                .groupName ??
                                                            "",
                                                        style: Drawables
                                                            .adddoccontentstyle(
                                                                Colors.black87,
                                                                14.0,
                                                                FontWeight.w500)),
                                                    Text(
                                                        _searchLists[index]
                                                                .groupDescription ??
                                                            "",
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        style: Drawables
                                                            .adddoccontentstyle(
                                                                Colors.grey,
                                                                12.0,
                                                                FontWeight.w300))
                                                  ],
                                                )),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                _searchLists[index]
                                                            .unreadMessageCount !=
                                                        0
                                                    ? Container(
                                                        width: 24,
                                                        height: 24,
                                                        child: Center(
                                                            child: Text(
                                                          "${_searchLists[index].unreadMessageCount ?? 0}",
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        )),
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Color.fromARGB(
                                                                255,
                                                                60,
                                                                237,
                                                                80)),
                                                      )
                                                    : Container()
                                              ],
                                            )),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
              
                                  // return Text("hi");
                                },
                                itemCount: _searchLists.length,
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
                                    padding: EdgeInsets.all(2),
                                    itemBuilder: (BuildContext ctx, int index) {
                                      return Padding(
                                        padding: EdgeInsets.all(8),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) => ChatScreen(
                                            //       groupId: groupList[index].groupId!,
                                            //       teamId: widget.teamId,
                                            //     ),
                                            //   ),
                                            // );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatScreen(
                                                  teamName: groupList[index]
                                                          .groupName ??
                                                      "No name",
                                                  groupId:
                                                      groupList[index].groupId!,
                                                  teamId: widget.teamId,
                                                  projectId: widget.projectId,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    12, 14, 12, 14),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            groupList[index]
                                                                    .groupName ??
                                                                "",
                                                            style: Drawables
                                                                .adddoccontentstyle(
                                                                    Colors
                                                                        .black87,
                                                                    14.0,
                                                                    FontWeight
                                                                        .w500)),
                                                        Text(
                                                            groupList[index]
                                                                    .groupDescription ??
                                                                "",
                                                            maxLines: 1,
                                                            overflow: TextOverflow
                                                                .ellipsis,
                                                            style: Drawables
                                                                .adddoccontentstyle(
                                                                    Colors.grey,
                                                                    12.0,
                                                                    FontWeight
                                                                        .w300))
                                                      ],
                                                    )),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    groupList[index]
                                                                .unreadMessageCount !=
                                                            0
                                                        ? Container(
                                                            width: 24,
                                                            height: 24,
                                                            child: Center(
                                                                child: Text(
                                                              "${groupList[index].unreadMessageCount ?? 0}",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                            )),
                                                            decoration:
                                                                BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            60,
                                                                            237,
                                                                            80)),
                                                          )
                                                        : Container()
                                                  ],
                                                )),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
              
                                      // return Text("hi");
                                    },
                                    itemCount: groupList.length,
                                  )
                        : Container(
                            child: Padding(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "No Groups Available",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(20),
                          ));
                  })),
            ),
      ),
    );
  }

  Future<void> _showMyDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                          onTap: () {
                            _groupNameFieldController.clear();
                            _groupDescriptionFieldController.clear();
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.close,
                              size: 22.0, color: Colors.black)),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(
                          "Add a new Group",
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF0061b0),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text("Group name *"),
                      SizedBox(
                        height: 4,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            controller: _groupNameFieldController,
                            focusNode: groupNameFocus,
                            decoration: InputDecoration.collapsed(
                              hintText: ' Enter group name',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text("Description *"),
                      SizedBox(
                        height: 4,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                            height: 100,
                            child: TextField(
                              controller: _groupDescriptionFieldController,
                              decoration: InputDecoration.collapsed(
                                hintText: ' Enter description',
                              ),
                              focusNode: descriptionFocus,
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _groupNameFieldController.clear();
                                    _groupDescriptionFieldController.clear();
                                  },
                                  child: Text("Cancel"))),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextButton(
                                onPressed: () {
                                  groupNameFocus.unfocus();
                                  descriptionFocus.unfocus();
                                  if (_groupNameFieldController.text.isEmpty) {
                                    showValidationalert(
                                        "Please enter Group name");
                                  } else if (_groupNameFieldController
                                          .text.length <
                                      3) {
                                    showValidationalert(
                                        "Group name should be minimum 3 letters");
                                  } else if (_groupDescriptionFieldController
                                      .text.isEmpty) {
                                    showValidationalert(
                                        "Please enter Group description");
                                  } else if (_groupDescriptionFieldController
                                          .text.length <
                                      3) {
                                    showValidationalert(
                                        "Group description should be minimum 3 letters");
                                  } else {
                                    createGroup();
                                  }
                                },
                                child: Text("Add"),
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.grey.withOpacity(0.3)))),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
          ),
        );
      },
    );
  }

  showValidationalert(bodyText) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Invalid Feilds",
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFF0061b0),
              fontWeight: FontWeight.w600)),
      content: Text(bodyText),
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
