import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mta/ChatView/models/AddRemoveUserReq.dart';
import 'package:mta/models/Chat/GroupCreationReq.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../models/Chat/AddRemoveUserListRes.dart';
import '../../network/ApiService.dart';
import '../../utilities/apputilities.dart';
import '../../utilities/strings.dart';

class AddRemoveUsersIntoGroups extends StatefulWidget {
  AddRemoveUsersIntoGroups(
      {super.key,
      this.groupId,
      this.projectId,
      this.teamId,
      this.fromCreateGroup,
      this.groupData});

  int? groupId;
  final int? projectId;
  final int? teamId;
  final bool? fromCreateGroup;
  final GroupCreationReq? groupData;

  @override
  _AddRemoveUsersIntoGroupsState createState() =>
      _AddRemoveUsersIntoGroupsState();
}

class _AddRemoveUsersIntoGroupsState extends State<AddRemoveUsersIntoGroups> {
  List<AddUsersData> chatUsers = [];
  List<AddUsersData>? _searchLists = [];

  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();

  IO.Socket? _socket;
  bool selectedClick = false;

  getUnlinkUsersByGroupId() {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    if (widget.fromCreateGroup == true) {
      (api.getUsers(widget.projectId == null ? "team" : "project",
              widget.teamId, widget.projectId))
          .then((response) {
        if (response.status!) {
          setState(() {
            chatUsers = response.data!;
            for (int i = 0; i < chatUsers.length; i++) {
              if (chatUsers[i].alreadyLinked == true) {
                chatUsers[i].isSelected = true;
              } else {
                chatUsers[i].isSelected = false;
              }
            }
            AppUtils.dismissprogress();
          });
        } else {
          AppUtils.showToastError("Unable to load users");
          print('error');
        }
      }).catchError((onError) {
        AppUtils.dismissprogress();
        AppUtils.showToastError(onError.toString());
        print(onError.toString());
      });
    } else {
      api.getUnlinkedUsers(widget.groupId!).then((response) {
        if (response.status!) {
          setState(() {
            chatUsers = response.data!;
            for (int i = 0; i < chatUsers.length; i++) {
              if (chatUsers[i].alreadyLinked == true) {
                chatUsers[i].isSelected = true;
              } else {
                chatUsers[i].isSelected = false;
              }
            }
            AppUtils.dismissprogress();
          });
        } else {
          AppUtils.showToastError("Unable to load users");
          print('error');
        }
      }).catchError((onError) {
        AppUtils.dismissprogress();
        AppUtils.showToastError(onError.toString());
        print(onError.toString());
      });
    }
  }

  selectUnselectUsers() {
    setState(() {
      for (int i = 0; i < chatUsers.length; i++) {
        if (chatUsers[i].alreadyLinked == true) {
          chatUsers[i].isSelected = true;
        } else {
          if (selectedClick) {
            chatUsers[i].isSelected = true;
          } else {
            chatUsers[i].isSelected = false;
          }
        }
      }
    });
  }

  createGroup(List<int> selectedUsrs) {
    print("dataaa ${widget.teamId}");
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.createGroup(widget.groupData!).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        widget.groupId = response.data!.groupId;
        addUsersToGroupApiCall(selectedUsrs);
        AppUtils.showToastSuccess(response.message ?? "Error");
      } else {
        AppUtils.showToastError(response.message ?? "Error");
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(onError.toString());
      print(onError.toString());
    });
  }

  updateSelectedUsers() {
    List<int> selectedUsers = [];
    chatUsers.forEach((element) {
      if (element.isSelected == true && element.alreadyLinked != true) {
        selectedUsers.add(element.userId!);
      }
    });
    AddRemoveUserReq req = AddRemoveUserReq();
    req.groupId = widget.groupId;
    req.userId = selectedUsers;

    if (selectedUsers.length > 0) {
      if (widget.fromCreateGroup == true) {
        createGroup(selectedUsers);
      } else {
        addUsersToGroupApiCall(selectedUsers);
      }
    } else {
      AppUtils.showToastError("Please select atleast one user");
    }
  }

  addUsersToGroupApiCall(req) {
    print("dddtt ${jsonEncode(req)}");
    _socket?.emit('add-users-into-group',
        json.encode({"group_id": widget.groupId, "user_id": req}));
    if (widget.fromCreateGroup != true) {
      AppUtils.showToastSuccess("Successfully Added the users");
    }
    Navigator.pop(context);

    // final api = Provider.of<ApiService>(context, listen: false);
    // api.addRemoveUsersintoGroup(req).then((response) {
    //   if (response.status!)
    //   {
    //     AppUtils.showToastSuccess(response.message ?? "Success");
    //     Navigator.pop(context);
    //   } else {
    //     print('error');
    //     AppUtils.showToastError(response.message ?? "Failed");
    //   }
    // }).catchError((onError) {
    //   AppUtils.dismissprogress();
    //   print(onError.toString());
    // });
  }

  @override
  void initState() {
    getUnlinkUsersByGroupId();
    // TODO: implement initState
    super.initState();

    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': false,
      'query': {
        'token': Strings.authToken,
        'group_id': widget.groupId,
        "group_type": widget.projectId == null ? "team" : "project",
        "project_id": widget.projectId,
        "team_id": widget.teamId
      }
    });
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected');
      joinGroup();
    });
  }

  joinGroup() {
    _socket?.emit(
        'join-group',
        json.encode({
          "group_id": widget.groupId,
        }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Chat Media"),
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_sharp)),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text(selectedClick ? "Unselect All" : "Select All"),
                    onPressed: () {
                      selectedClick = !selectedClick;
                      selectUnselectUsers();
                    },
                  ),
                ),
              ),
              // Container(
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(25),
              //       color: const Color(0xFFeceeef),
              //     ),
              //     child:

              //     Padding(
              //       padding: const EdgeInsets.all(5.0),
              //       child: Material(
              //         color: const Color(0xFFeceeef),
              //         child: Row(
              //           mainAxisSize: MainAxisSize.min,
              //           children: <Widget>[
              //             Expanded(
              //               child: TextField(
              //                 focusNode: searchField,
              //                 controller: _searchFieldController,
              //                 decoration: InputDecoration.collapsed(
              //                   hintText: ' Search',
              //                 ),
              //                 onChanged: (value) {
              //                   if (value.isEmpty) {
              //                     setState(() {
              //                       _searchLists = [];
              //                     });
              //                     return;
              //                   }
              //                   _searchLists = [];
              //                   chatUsers?.forEach((list) {
              //                     if (list.userName!
              //                         .toLowerCase()
              //                         .startsWith(value.toLowerCase()))
              //                       _searchLists?.add(list);
              //                   });
              //                   print("dataaaa ${_searchLists?.length}");
              //                   setState(() {});
              //                 },
              //               ),
              //             ),
              //             InkWell(
              //               child: Icon(
              //                 Icons.search,
              //                 color: Colors.black,
              //               ),
              //               onTap: () {},
              //             )
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),

              Expanded(
                child: chatUsers.length > 0
                    ? ListView.builder(
                        itemCount: chatUsers.length,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            enabled: (!chatUsers[index].alreadyLinked!),
                            title: Text('${chatUsers[index].userName}'),
                            value: chatUsers[index].isSelected,
                            onChanged: (value) {
                              setState(() {
                                chatUsers[index].isSelected = value!;
                                print("jsonn data ${jsonEncode(chatUsers)}");
                              });
                            },
                          );
                        },
                      )
                    : Center(
                        child: Text("No users found",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                                fontWeight: FontWeight.w600))),
              ),

              Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  child: ElevatedButton(
                    onPressed: () {
                      updateSelectedUsers();
                    },
                    child: Text(
                      "Add",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue)),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
