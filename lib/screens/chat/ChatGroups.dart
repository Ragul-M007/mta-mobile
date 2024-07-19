import 'dart:convert';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/Chat/GroupChatListRes.dart';
import 'package:mta/models/Chat/GroupCreationReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/chat/ChatScreen.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
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

class _ChatGroupsState extends State<ChatGroups>
    with SingleTickerProviderStateMixin {
  FancyDrawerController? _controller;
  WebViewController controller = WebViewController();

  IO.Socket? _socket;

  BuildContext? ctx;
  bool loading = true;

  List<GroupDetails> _searchLists = [];
  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();
  TextEditingController _groupNameFieldController = TextEditingController();
  TextEditingController _groupDescriptionFieldController =
      TextEditingController();

  List<GroupDetails> groupList = [];

  String? filepath;
  var dio = Dio();

  String _errText = "";
  void initState() {
    super.initState();
    print(">>>kkkkk");
    connectSocket();
    fetchChatCreateAcess();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  fetchChatCreateAcess() {
    final api = Provider.of<ApiService>(context, listen: false);

    api.getAccessDetails().then((response) {
      if (response.status!) {
        setState(() {
          Strings.groupCreationAccess = response.data!.groupCreateAccess;
        });
      }
    }).catchError((onError) {
      print(onError.toString());
      //getProjects();
    });
  }

  connectSocket() {
    print("teamid ${widget.teamId}  projectid ${widget.projectId}");
    print("trying to connect socket");
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': false,
      'query': {
        'token': Strings.authToken,
        "group_type": widget.projectId == null ? "team" : "project",
        "project_group_id": widget.projectId,
        "team_id": widget.teamId
      }
    });
    _socket?.connect();
    _socket?.onConnect((_) {
      print('connect');
    });
    _socket?.on("connect", (_) {
      print('Connected');
      print("Calling function");
      getChats();
      //recieveMessages();

      //_socket?.disconnect();
    });
  }

  // recieveMessages() {
  //   _socket?.on("message-received", (_data) {
  //     getChats();
  //   });
  // }

  getChats() {
    _socket?.on("all-groups", (_data) {
      print("dataa from all groups $_data");
      if (mounted) {
        setState(() {
          var formattedRes = GroupListRes.fromJson(_data);

          if (formattedRes.userId == Strings.userID &&
              ((formattedRes.projectId != null &&
                      formattedRes.projectId == widget.projectId) ||
                  (formattedRes.teamId != null &&
                      formattedRes.teamId == widget.teamId))) {
            groupList.clear();

            for (var item in formattedRes.groupDetails ?? []) {
              groupList.add(item);
            }
          } else {
            print("else");
          }
          loading = false;
        });
      }
    });
  }

  upload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
    );
    if (result != null) {
      List files = result.paths
          .map((path) => MultipartFile.fromFileSync(
                path!,
                filename: getFileName(path),
                // contentType: MediaType(
                //     lookupMimeType(getFileName(path))?.split('/')[0],
                //     lookupMimeType(getFileName(path))?.split('/')[1],
                // ),
              ))
          .toList();
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': Strings.userID, // other parameter may you need to send
        'group_id': 52, // other parameter may you need to send
        'groupImage': files,
      });

      var response = await dio.post(
          'https://demo.emeetify.com:81/mta/chat/createMessage',
          data: formData);
      // check response status code

      print("response ${response}");
      if (response.statusCode == 200) {
        // it's uploaded
      }
    } else {
      // User canceled the picker
    }
  }

  String getFileName(String _path) {
    return path.basename(_path);
  }

  createGroup() {
    print("dataaa ${widget.teamId}");
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    print("api--->  {$api}");
    GroupCreationReq req = GroupCreationReq();
    req.groupCreatedBy = Strings.userID;
    req.groupImage = null;
    req.groupName = _groupNameFieldController.text;
    req.groupDescription = _groupDescriptionFieldController.text;
    req.teamId = widget.teamId;
    req.projectId = widget.projectId;
    req.groupType = widget.projectId == null ? "team" : "project";

    api.checkGroupName(_groupNameFieldController.text).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
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
              groupData: req,
            ),
          ),
        ).whenComplete(() => connectSocket());
      } else {
        AppUtils.showToastError(response.message ?? "Error");
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(onError.toString());
      print(onError.toString());
    });
  }

  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: WillPopScope(
        onWillPop: () {
          print(
              ">>>>>>kkk2:${widget.projectId},${widget.fromTeamProjects},${Strings.fromTeamProjects}");
          if (widget.projectId == null) {
            Navigator.pushNamed(context, "/teamsDashboard");
          } else if (widget.fromTeamProjects == true ||
              Strings.fromTeamProjects) {
            Strings.fromTeamProjects = false;
            Navigator.pushNamed(context, "/dashboard");
          } else {
            Navigator.pushNamed(context, "/projects");
          }

          throw '';
        },
        child: loading
            ? Center(
                child: Container(
                    height: 30, width: 30, child: CircularProgressIndicator()))
            : Scaffold(
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
                        print(">>>>>lll");
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
                        _controller?.toggle();
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
