import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mta/ChatView/models/AddRemoveUserReq.dart';
import 'package:mta/models/Chat/GroupUsersRes.dart';
import 'package:provider/provider.dart';

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


  

 getUsersByGroupId()
    {
      AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.getChatUsers(widget.groupId).then((response) {
      if (response.status!) {
        setState(() {
          chatUsers.clear();
          chatUsers = response.data!;
          for(int i = 0;i<chatUsers.length;i++)
          {
            if(chatUsers[i].groupCreateAccess == 1)
            {
                chatUsers[i].isSelected = true;
            }
            else
            {
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
                removeUsersToGroupApiCall(req);
            }
            else
            {
              AppUtils.showToastError("Please select atleast any user");
            }
           
  }


  removeUsersToGroupApiCall(req) 
  {
    final api = Provider.of<ApiService>(context, listen: false);

    print("req  ${jsonEncode(req)}");
    api.removeUsersintoGroup(req).then((response) {
      if (response.status!) 
      {
        AppUtils.showToastSuccess(response.message ?? "Success");
        Navigator.pop(context);
      } else {
        print('error');
        AppUtils.showToastError(response.message ?? "Failed");
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }
  @override
  void initState() 
  {
    getUsersByGroupId();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
    );
  }
}