import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mta/ChatView/models/AddRemoveUserReq.dart';
import 'package:mta/blocs/chat/remove_users_bloc.dart';
import 'package:mta/models/Chat/GroupUsersRes.dart';

import '../../models/Chat/AddRemoveUserListRes.dart';
import '../../network/ApiService.dart';
import '../../utilities/apputilities.dart';
import '../../utilities/strings.dart';




class RemoveUsersInGroup extends StatefulWidget {

  const RemoveUsersInGroup({super.key, required this.groupId});

  final int groupId;
  @override
  _AddRemoveUsersIntoGroupsState createState() => _AddRemoveUsersIntoGroupsState();
}

class _AddRemoveUsersIntoGroupsState extends State<RemoveUsersInGroup> {
 
  List<GroupChatUsersData> chatUsers = [];

  late final RemoveUsersBloc _bloc;
  late final StreamSubscription<RemoveUsersState> _blocSub;

  void _onBlocState(RemoveUsersState state) {
    if (!mounted) return;
    if (state is RemoveUsersLoading) {
      AppUtils.showprogress();
    } else if (state is RemoveUsersLoaded) {
      setState(() {
        chatUsers.clear();
        chatUsers = state.data;
        for (int i = 0; i < chatUsers.length; i++) {
          if (chatUsers[i].groupCreateAccess == 1) {
            chatUsers[i].isSelected = true;
          } else {
            chatUsers[i].isSelected = false;
          }
        }
        AppUtils.dismissprogress();
      });
    } else if (state is RemoveUsersLoadFailed) {
      AppUtils.showToastError("Unable to load users");
    } else if (state is RemoveUsersLoadError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(state.message);
    } else if (state is RemoveUsersRemoveSuccess) {
      AppUtils.showToastSuccess(state.message ?? "Success");
      Navigator.pop(context);
    } else if (state is RemoveUsersRemoveFailed) {
      AppUtils.showToastError(state.message ?? "Failed");
    } else if (state is RemoveUsersRemoveError) {
      AppUtils.dismissprogress();
    }
  }

  getUsersByGroupId() {
    _bloc.add(RemoveUsersLoadRequested(widget.groupId));
  }

    
  updateSelectedUsers()
  {
          List<int> selectedUsers = [];
          chatUsers.forEach((element) 
          {
            if(element.isSelected == true && element.groupCreateAccess != 1)
            {
              selectedUsers.add(element.userId!);
            }
          });
            AddRemoveUserReq req = AddRemoveUserReq();
            req.groupId = widget.groupId;
            req.userId = selectedUsers;

            print("jsone ${jsonEncode(req)}");

            if(selectedUsers.length>0)
            {
                _bloc.add(RemoveUsersSubmitted(req));
            }
            else
            {
              AppUtils.showToastError("Please select atleast any user");
            }

  }

  @override
  void initState()
  {
    _bloc = RemoveUsersBloc(ApiService.create());
    _blocSub = _bloc.stream.listen(_onBlocState);
    getUsersByGroupId();
    // TODO: implement initState
    super.initState();
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
        appBar: AppBar(title: Text("Chat Media"),leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_sharp)),),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: chatUsers.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      enabled: !(chatUsers[index].groupCreateAccess == 1),
                      title: Text('${chatUsers[index].userName}'),
                      value: chatUsers[index].isSelected,
                      onChanged: (value) 
                      {
                        setState(() 
                        {
                          //  var data = jsonEncode(chatUsers).to;
                          //  chatUsers[index]['isSelected'] = value;
                          chatUsers[index].isSelected = value!;
                          print("jsonn data ${jsonEncode(chatUsers)}");
                        });
                      },
                    );
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.80,
                child: ElevatedButton(onPressed: ()
                {
                    updateSelectedUsers();
                }, child: Text("Remove",style: TextStyle(color: Colors.white),),style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)
                ),))
            ],
          ),
        ),
      ),
    );
  }
}