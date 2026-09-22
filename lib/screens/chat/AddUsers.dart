import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mta/ChatView/models/AddRemoveUserReq.dart';
import 'package:mta/blocs/chat/add_users_bloc.dart';
import 'package:mta/models/Chat/GroupCreationReq.dart';

import '../../models/Chat/AddRemoveUserListRes.dart';
import '../../network/ApiService.dart';
import '../../utilities/apputilities.dart';

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

  late final AddUsersBloc _bloc;
  late final StreamSubscription<AddUsersState> _blocSub;
  bool selectedClick = false;

  void _onBlocState(AddUsersState state) {
    if (!mounted) return;
    if (state is AddUsersLoading) {
      AppUtils.showprogress();
    } else if (state is AddUsersLoaded) {
      setState(() {
        chatUsers = state.data;
        for (int i = 0; i < chatUsers.length; i++) {
          if (chatUsers[i].alreadyLinked == true) {
            chatUsers[i].isSelected = true;
          } else {
            chatUsers[i].isSelected = false;
          }
        }
        AppUtils.dismissprogress();
      });
    } else if (state is AddUsersLoadFailed) {
      AppUtils.showToastError("Unable to load users");
    } else if (state is AddUsersLoadError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(state.message);
    } else if (state is AddUsersCreateLoading) {
      AppUtils.showprogress();
    } else if (state is AddUsersCreatedNav) {
      AppUtils.dismissprogress();
      Navigator.pop(context);
      AppUtils.showToastSuccess(state.message);
    } else if (state is AddUsersCreateFailed) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(state.message);
    } else if (state is AddUsersCreateError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(state.message);
    } else if (state is AddUsersAddedNav) {
      AppUtils.showToastSuccess("Successfully Added the users");
      Navigator.pop(context);
    }
  }

  getUnlinkUsersByGroupId() {
    _bloc.add(AddUsersLoadRequested(
        widget.fromCreateGroup, widget.groupId, widget.projectId, widget.teamId));
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
      _bloc.add(AddUsersSubmitRequested(
          widget.fromCreateGroup, widget.groupData, selectedUsers));
    } else {
      AppUtils.showToastError("Please select atleast one user");
    }
  }

  @override
  void initState() {
    _bloc = AddUsersBloc(ApiService.create());
    _blocSub = _bloc.stream.listen(_onBlocState);
    getUnlinkUsersByGroupId();
    // TODO: implement initState
    super.initState();

    _bloc.add(AddUsersSocketInit(
        widget.groupId, widget.projectId, widget.teamId));
  }

  @override
  void dispose() {
    _blocSub.cancel();
    _bloc.close();
    super.dispose();
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
