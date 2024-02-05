
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mta/ChatView/lib/src/models/AddRemoveUserReq.dart';
import 'package:mta/models/Chat/GroupUsersRes.dart';
import 'package:provider/provider.dart';

import '../../models/Chat/AddRemoveUserListRes.dart';
import '../../network/ApiService.dart';
import '../../utilities/apputilities.dart';
import '../../utilities/constant.dart';




class AddRemoveUsersIntoGroups extends StatefulWidget {

  const AddRemoveUsersIntoGroups({super.key, required this.groupId});

  final int groupId;
  @override
  _AddRemoveUsersIntoGroupsState createState() => _AddRemoveUsersIntoGroupsState();
}

class _AddRemoveUsersIntoGroupsState extends State<AddRemoveUsersIntoGroups> {
 
  List<AddUsersData> chatUsers = [];
  getUnlinkUsersByGroupId() 
  {
    final api = Provider.of<ApiService>(context, listen: false);
    api.getUnlinkedUsers(widget.groupId).then((response) {
      if (response.status!) 
      {
        setState(() {
          chatUsers = response.data!;
          for(int i = 0;i<chatUsers.length;i++)
          {
            if(chatUsers[i].alreadyLinked == true)
            {
               chatUsers[i].isSelected = true;
            }
            else
            {
                chatUsers[i].isSelected = false;
            }
          }
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }


  updateSelectedUsers()
  {
    List<int> selectedUsers = [];
          chatUsers.forEach((element) 
          {
            if(element.isSelected == true && element.alreadyLinked != true)
            {
              selectedUsers.add(element.userId!);
            }
           });
            AddRemoveUserReq req = AddRemoveUserReq();
            req.groupId = widget.groupId;
            req.userId = selectedUsers;

            print("jsone ${jsonEncode(req)}");
            addUsersToGroupApiCall(req);
           
  }


  addUsersToGroupApiCall(req) 
  {
    final api = Provider.of<ApiService>(context, listen: false);
    api.addRemoveUsersintoGroup(req).then((response) {
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
    getUnlinkUsersByGroupId();
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
                    enabled: (!chatUsers[index].alreadyLinked!),
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
              child: ElevatedButton(onPressed: (){
                  updateSelectedUsers();
              }, child: Text("Add",style: TextStyle(color: Colors.white),),style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)
              ),))
          ],
        ),
      ),
    );
  }
}
