import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mta/models/Chat/MediaDetailsRes.dart';
import 'package:mta/screens/chat/ChatGroups.dart';
import 'package:mta/screens/chat/ChatScreen.dart';
import 'package:mta/screens/chat/RemoveUsers.dart';
import 'package:mta/screens/chat/AddUsers.dart';
import 'package:mta/screens/splashscreen.dart';
import 'package:provider/provider.dart';

import '../../models/Chat/GroupUsersRes.dart';
import '../../network/ApiService.dart';
import '../../utilities/apputilities.dart';
import '../../utilities/drawables.dart';
import '../../utilities/strings.dart';

class ChatMedia extends StatefulWidget {
  const ChatMedia(
      {super.key, required this.groupId, this.projectId, this.teamId});

  final int groupId;
  final int? projectId;
  final int? teamId;

  @override
  State<ChatMedia> createState() => _ChatMediaState();
}

class _ChatMediaState extends State<ChatMedia> with TickerProviderStateMixin {
  TabController? _tabController;
  List<MediaData> _imageList = [];
  List<MediaData> _videoList = [];
  List<MediaData> _docList = [];
  List<GroupChatUsersData> chatUsers = [];
  List<GroupChatUsersData> _searchLists = [];
  TextEditingController _searchFieldController = TextEditingController();
  FocusNode searchField = new FocusNode();
  int? groupCreatedUserId = 0;
  String? basePath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 4, vsync: this);
    findPath();
    getDocumentDetails("image");
    getDocumentDetails("document");
    getDocumentDetails("video");
    getUsersByGroupId();
    getGroupData();
  }

  findPath() async {
    basePath = Strings.basePath;
  }

  getDocumentDetails(type) {
    final api = Provider.of<ApiService>(context, listen: false);
    api.getMediaDetails(widget.groupId, type).then((response) {
      if (response.status!) {
        setState(() {
          if (type == "image") {
            _imageList = response.data!;
          } else if (type == "video") {
            _videoList = response.data!;
          } else {
            _docList = response.data!;
          }
        });

        AppUtils.dismissprogress();
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  getUsersByGroupId() {
    final api = Provider.of<ApiService>(context, listen: false);
    api.getChatUsers(widget.groupId).then((response) {
      if (response.status!) {
        setState(() {
          chatUsers = response.data!;
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  getGroupData() {
    final api = Provider.of<ApiService>(context, listen: false);
    api.getGroupData(widget.groupId).then((response) {
      if (response.status!) {
        setState(() {
          // chatUsers = response.data!;
          groupCreatedUserId = response.data?.groupCreatedBy;
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Media"),
        actions: [
          groupCreatedUserId == Strings.userID
              ? IconButton(
                  onPressed: () {
                    showDeleteDialog(context);
                  },
                  icon: Icon(Icons.delete_outline_outlined))
              : Container()
        ],
      ),
      body: tabbarwidget(),
    );
  }

  Widget tabbarwidget() {
    return Container(
        // padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              child: TabBar(
                tabs: [
                  Container(
                    height: 36,
                    // width: MediaQuery.of(context).size.width * 0.45,
                    child: Text('Members',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF272626))),
                  ),
                  Container(
                    height: 36,
                    // width: MediaQuery.of(context).size.width * 0.45,
                    child: Text('Images',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF272626))),
                  ),
                  Container(
                    height: 36,
                    child: Text('Videos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF272626))),
                  ),
                  Container(
                    height: 36,
                    child: Text('Documents',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF272626))),
                  )
                ],
                unselectedLabelColor: const Color(0xffacb3bf),
                indicatorColor: Color.fromRGBO(0, 97, 176, 1),
                labelColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3.0,
                indicatorPadding: EdgeInsets.all(10),
                isScrollable: false,
                controller: _tabController,
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: <Widget>[
                memberList(),
                imageViewer(),
                videoViewer(),
                documentViewer(),

                //
              ]),
            ),
            // SizedBox(height: 5,),
            // Center(child: Container(
            //   width: MediaQuery.of(context).size.width * 0.6,
            //   child: ElevatedButton(onPressed: (){
            //       Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => RemoveUsersInGroup(
            //         groupId: widget.groupId,
            //       ),
            //     ),
            //   ).then((value) => {
            //     getUsersByGroupId()
            //   });

            //   }, child: Text("Remove Users",style: TextStyle(color: Colors.white),),style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),)))
          ],
        ));
  }

  showDeleteDialog(context) {
    showDialog(
      context: context,
      builder: (ctx) => new AlertDialog(
        title: Text(
          "Are you sure ?",
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFF0061b0),
              fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Do you want to delete the group',
          style: TextStyle(
              fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: new Text(
              'No',
              style: TextStyle(
                  fontSize: 16, color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              deleteGroup(context);
            },
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
  }

  Widget imageViewer() {
    return _imageList.length != 0
        ? GridView.builder(
            itemBuilder: (BuildContext ctx, int index) {
              return Container(
                  margin: EdgeInsets.all(10),
                  color: Colors.grey.withOpacity(0.1),
                  child: Padding(
                      padding: EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () {
                          print(
                              "ooon   ${basePath! + "/" + _imageList[index].filesName! + AppUtils.getFileExtension(_imageList[index].filesName!)}");
                          AppUtils.openFile(basePath! +
                              "/" +
                              _imageList[index].filesName! +
                              AppUtils.getFileExtension(
                                  _imageList[index].files!));
                        },
                        child: Column(
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.file(File(basePath! +
                                          "/" +
                                          _imageList[index].filesName! +
                                          AppUtils.getFileExtension(
                                              _imageList[index].files!))),
                                    ))),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              _imageList[index].fileOriginalName ?? "",
                              textAlign: TextAlign.left,
                              textDirection: TextDirection.ltr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              AppUtils.formatDate(_imageList[index].createdAt),
                              textAlign: TextAlign.left,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )));
            },
            itemCount: _imageList.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          )
        : Center(child: Text("No items found"));
  }

  Widget videoViewer() {
    return _videoList.length != 0
        ? ListView.builder(
            itemBuilder: (BuildContext ctx, int index) {
              return Container(
                  margin: EdgeInsets.all(10),
                  color: Colors.grey.withOpacity(0.1),
                  child: Padding(
                      padding: EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () {
                          print(
                              "ooon ${Strings.baseImageUrl + _videoList[index].files!}");
                          AppUtils.openFile(basePath! +
                              "/" +
                              _videoList[index].filesName! +
                              AppUtils.getFileExtension(
                                  _videoList[index].files!));
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.ltr,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: 80,
                                child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: Image.asset(AppUtils.getFilTypeImg(
                                          _videoList[index].files)),
                                    ))),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _videoList[index].fileOriginalName ?? "",
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${((double.parse(_videoList[index].fileSize!) / 1028) / 1024).toStringAsFixed(2)} MB",
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textDirection: TextDirection.ltr,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 18.0,
                                        height: 18.0,
                                        child: IconButton(
                                          padding: new EdgeInsets.all(0.0),
                                          color: Colors.grey,
                                          icon: new Icon(Icons.lock_clock,
                                              size: 18.0),
                                          onPressed: () {},
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        _videoList[index].createdAt ?? "",
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )));
            },
            itemCount: _videoList.length,
          )
        : Center(child: Text("No items found"));
  }

  Widget documentViewer() {
    return _docList.length != 0
        ? ListView.builder(
            itemBuilder: (BuildContext ctx, int index) {
              return Container(
                  margin: EdgeInsets.all(10),
                  color: Colors.grey.withOpacity(0.1),
                  child: Padding(
                      padding: EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () {
                          print(
                              "ooon   ${basePath! + "/" + _docList[index].filesName! + AppUtils.getFileExtension(_docList[index].filesName!)}");
                          AppUtils.openFile(basePath! +
                              "/" +
                              _docList[index].filesName! +
                              AppUtils.getFileExtension(
                                  _docList[index].files!));
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.ltr,
                          children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: 80,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      child: Image.asset(AppUtils.getFilTypeImg(
                                          _docList[index].files))),
                                )),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _docList[index].fileOriginalName ?? "",
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${((double.parse(_docList[index].fileSize!) / 1028) / 1024).toStringAsFixed(2)} MB",
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    textDirection: TextDirection.ltr,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 18.0,
                                        height: 18.0,
                                        child: IconButton(
                                          padding: new EdgeInsets.all(0.0),
                                          color: Colors.grey,
                                          icon: new Icon(Icons.lock_clock,
                                              size: 18.0),
                                          onPressed: () {},
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        _docList[index].createdAt ?? "",
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )));
            },
            itemCount: _docList.length,
          )
        : Center(
            child: Text("No items found"),
          );
  }

  Widget memberList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("(${chatUsers.length}) Members"),
              Strings.groupCreationAccess == 1
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddRemoveUsersIntoGroups(
                                  groupId: widget.groupId,
                                  teamId: widget.teamId,
                                  projectId: widget.projectId,
                                ),
                              ),
                            ).then((value) => {getUsersByGroupId()});
                          },
                          child: Text("Add Users")),
                    )
                  : Container()
            ],
          ),
        ),
        chatUsers.length > 0
            ? Expanded(
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(left: 24, right: 24),
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
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

                                          chatUsers.forEach((projectDetail) {
                                            if (projectDetail.userName!
                                                .toLowerCase()
                                                .startsWith(
                                                    value.toLowerCase()))
                                              _searchLists.add(projectDetail);
                                          });
                                          print(
                                              "dataaaa ${_searchLists.length}");
                                          setState(() {});
                                        },
                                      ),
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
                      ),
                    ),
                    _searchLists.length != 0
                        ? Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.all(20),
                              itemBuilder: (BuildContext ctx, int index) {
                                return Padding(
                                  padding: EdgeInsets.all(10),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Strings.selectedCategory = [];
                                      // Strings.selectedCategory.add(_catsList[index]);
                                      // Strings.category = true;
                                      // Navigator.pushNamed(context, '/viewdoclist');
                                    },
                                    child: Container(
                                      child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundImage: (_searchLists[
                                                                index]
                                                            .userName !=
                                                        "")
                                                    ? NetworkImage(Strings
                                                            .baseImageUrl +
                                                        (_searchLists[index]
                                                                .userImage ??
                                                            ""))
                                                    : AssetImage(
                                                            "assets/icons/account.png")
                                                        as ImageProvider,
                                                backgroundColor: Colors.grey
                                                    .withOpacity(0.3),
                                              ),
                                              SizedBox(
                                                width: 12,
                                              ),
                                              Expanded(
                                                  child: Text(
                                                      _searchLists[index]
                                                          .userName!,
                                                      style: Drawables
                                                          .adddoccontentstyle(
                                                              Colors.black87,
                                                              14.0,
                                                              FontWeight
                                                                  .w500))),
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
                            ),
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
                            : Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.all(20),
                                  itemBuilder: (BuildContext ctx, int index) {
                                    return Padding(
                                      padding: EdgeInsets.all(10),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          child: Padding(
                                              padding: EdgeInsets.all(14),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 16,
                                                    backgroundImage: (chatUsers[
                                                                    index]
                                                                .userName !=
                                                            "")
                                                        ? NetworkImage(Strings
                                                                .baseImageUrl +
                                                            (chatUsers[index]
                                                                    .userImage ??
                                                                ""))
                                                        : AssetImage(
                                                                "assets/icons/account.png")
                                                            as ImageProvider,
                                                    backgroundColor: Colors.grey
                                                        .withOpacity(0.3),
                                                  ),
                                                  SizedBox(
                                                    width: 12,
                                                  ),
                                                  Expanded(
                                                      child: Text(
                                                          chatUsers[index]
                                                              .userName!,
                                                          style: Drawables
                                                              .adddoccontentstyle(
                                                                  Colors
                                                                      .black87,
                                                                  14.0,
                                                                  FontWeight
                                                                      .w500))),
                                                ],
                                              )),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.blueGrey
                                                .withOpacity(0.1),
                                          ),
                                        ),
                                      ),
                                    );

                                    // return Text("hi");
                                  },
                                  itemCount: chatUsers.length,
                                ),
                              )
                  ],
                ),
              )
            : Container(
                child: Padding(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No users Found",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(20),
              )),
      ],
    );
  }

  deleteGroup(context) {
    AppUtils.showprogress();
    final api = Provider.of<ApiService>(context, listen: false);
    api.deleteGroup(widget.groupId).then((response) {
      AppUtils.dismissprogress();
      if (response.status!) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatGroups(
                    teamId: widget.teamId,
                    projectId: widget.projectId,
                    fromTeamProjects: widget.projectId == null ? true : false,
                  )),
        );
        setState(() {
          AppUtils.showToastSuccess(response.comment ?? "Deleted Successfully");
        });
      } else {
        AppUtils.dismissprogress();
        AppUtils.showToastError("Something went wrong!");
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError("Something went wrong!");
      print(onError.toString());
    });
  }
}
