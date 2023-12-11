import 'dart:convert';
import 'dart:io';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:mta/models/Chat/GroupChatListRes.dart';
import 'package:mta/models/Chat/GroupCreationReq.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/models/TeamsModel.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/drawables.dart';
import 'package:mta/utilities/strings.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';

import '../../utilities/apputilities.dart';

class ChatGroups extends StatefulWidget {
  static const String routeName = "/chatGroups";
    final int teamId;

    ChatGroups({required this.teamId});

  @override
  _ChatGroupsState createState() => _ChatGroupsState();
}

class _ChatGroupsState extends State<ChatGroups>
    with SingleTickerProviderStateMixin {
  FancyDrawerController? _controller;
  WebViewController controller = WebViewController();

  
  IO.Socket? _socket;

  BuildContext? ctx;
  
  List<GroupListRes> _searchLists = [];
  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();
  TextEditingController _groupNameFieldController = TextEditingController();

  List<GroupListRes> groupList = [];

  String? filepath;
  var dio = Dio();

  String _errText = "";
  void initState() {
    super.initState();

    connectSocket();
  
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  connectSocket()
  {
    print("trying to connect socket");
     _socket = IO.io(Strings.socketUrl, <String, dynamic>
    {
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': false,
      'query': {
        'token': Strings.authToken,
        "group_type": "team",
        "project_group_id" : null,
        "team_id" : widget.teamId
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
      //_socket?.disconnect();
    });
  }
  
getChats()
{

      _socket?.on("all-groups", (_data) {
        setState(() {
           for (var item in _data) {
            groupList.add(GroupListRes.fromJson(item));
            print("set state");
          }

        });
       
        print("dataaa ${groupList}");
      });

}
  createGroup() 
  {
          
    print("dataaa ${widget.teamId}");
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    print("api--->  {$api}");
    GroupCreationReq req = GroupCreationReq();
    req.groupCreatedBy = Strings.userID;
    req.groupImage = null;
    req.groupName = _groupNameFieldController.text;
    req.groupDescription = " ";
    req.teamId = widget.teamId;
    req.groupType = "team";

    print("loqinrequest ---> ${jsonEncode(req)
}}");
    api.createGroup(req).then((response) 
    {
      AppUtils.dismissprogress();
      if(response.status!)
      {
          AppUtils.showToastSuccess(response.message ?? "Error");
          _groupNameFieldController.clear();
          Navigator.of(context).pop();
      }
      else
      {
          AppUtils.showToastError(response.message ?? "Error");
      }
      
      
    }).catchError((onError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError(onError.toString());
      print(onError.toString());
    });
  }

  Widget build(BuildContext context) 
  {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: Scaffold(
        floatingActionButton: InkWell(
          onTap: (){
              _showMyDialog(context);
          },
          child: CircleAvatar(
            radius: 20,
            child: Icon(Icons.people_rounded,color: Colors.white,),
              backgroundColor: Colors.grey.withOpacity(0.8),
            ),
        ),
          backgroundColor: const Color(0xFFececed),
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text("Chats"),
            bottom:PreferredSize(
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
                                onChanged: (value) 
                                {
                                  if (value.isEmpty) {
                                    setState(() {
                                      _searchLists = [];
                                    });
                                    return;
                                  }
                                  _searchLists = [];
                                  groupList
                                      .forEach((list) {
                                    if (list.groupName!
                                        .toLowerCase()
                                        .startsWith(
                                            value.toLowerCase()))
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
                  searchField.unfocus();
                  _controller?.toggle();
                },
              ),
            ),
          ),
          body: Builder(builder: (BuildContext newContext) {
            ctx = newContext;
            return 
            groupList.length > 0
                ? 
                _searchLists.length != 0? ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemBuilder: (BuildContext ctx, int index) {
                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: GestureDetector(
                          onTap: () {
                      
                          },
                          child: Container(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                                _searchLists[index].groupName!,
                                                style: Drawables.adddoccontentstyle(
                                                    Colors.black87,
                                                    14.0,
                                                    FontWeight.w500)),
                                                    Text(
                                                _searchLists[index].groupDescription!,
                                                style: Drawables.adddoccontentstyle(
                                                    Colors.grey,
                                                    12.0,
                                                    FontWeight.w300))
                                          ],
                                        )),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey,
                                      size: 14.0,
                                    )
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
                  ):
                  _searchFieldController.text != ""
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "No results found",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600),
                                ),
                              ): ListView.builder(
                    padding: EdgeInsets.all(2),
                    itemBuilder: (BuildContext ctx, int index) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: () {
                          

                          },
                          child: Container(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(12,14,12,14),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                groupList[index].groupName ?? "",
                                                style: Drawables.adddoccontentstyle(
                                                    Colors.black87,
                                                    14.0,
                                                    FontWeight.w500)),
                                                    Text(
                                                      
                                                groupList[index].groupDescription ?? "",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Drawables.adddoccontentstyle(
                                                    Colors.grey,
                                                    12.0,
                                                    FontWeight.w300))
                                          ],
                                        )),
                                        SizedBox(width: 8,),
                                    Container(
                    width: 24,
                    height: 24,
                    child: Center(child: Text("4",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400),)),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 60, 237, 80)),
                  )
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
                    itemCount: groupList.length,
                  )
                : Container(
                    child: Padding(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _errText,
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
    );
  }


  Future<void> _showMyDialog(context) async 
  {
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
                        onTap: (){
                                                  _groupNameFieldController.clear();
                                                  Navigator.of(context).pop();
                        },
                        child: Icon(Icons.close, size: 22.0, color: Colors.black)),
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
                      Text("Group name"),
                      SizedBox(height: 4,),
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
                      Text("Description"),
                      SizedBox(height: 4,),
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
                            hintText: ' Enter description',
                          ),  
                        ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                       Expanded(child: OutlinedButton(onPressed: (){
                        Navigator.of(context).pop();
                        _groupNameFieldController.clear();
                       }, child: Text("Cancel"))),
SizedBox(width: 10,),
                      Expanded(child: TextButton(onPressed: (){

                        if(_groupNameFieldController.text.isEmpty)
                        {
                            AppUtils.showToastError("Please enter Group name");
                        }
                        else if(_groupNameFieldController.text.length <= 3)
                        {
                          AppUtils.showToastError("Group name should be minimum 3 letters");
                        }
                        else
                        {
                          createGroup();
                        }
                      }, child: Text("Add"),style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.withOpacity(0.3)))),),

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
}
