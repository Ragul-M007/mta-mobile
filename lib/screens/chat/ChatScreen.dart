import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:mta/ChatView/widgets/send_message_widget.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/ForwardMessageReq.dart';
import 'package:mta/models/GroupReq.dart';
import 'package:mta/screens/chat/ChatMedia.dart';
import 'package:mta/screens/chat/theme.dart';
import 'package:mta/screens/dashboard/teamsDashboard.dart';
import 'package:mta/screens/projects/projects.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:path/path.dart' as path;

import '../../ChatView/chatview.dart';
import '../../models/Chat/ChatMessageRes.dart';
import '../../models/Chat/GroupUsersRes.dart';
import '../../models/GroupRes.dart';
import '../../network/ApiService.dart';
import '../../utilities/apputilities.dart';
import '../../utilities/strings.dart';

class ChatScreen extends StatefulWidget {
  final int? projectId;
  final int? groupId;
  final int? teamId;
  final String teamName;

  const ChatScreen(
      {Key? key,
      this.groupId,
      this.teamId,
      this.projectId,
      required this.teamName})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

List<Message> msgList = [];
List<ChatUser> chtusers = [];

List<Map<String, dynamic>> flutterMentionUserList = [];

var dio = Dio();

class _ChatScreenState extends State<ChatScreen> {
  AppTheme theme = LightTheme();
  bool isDarkTheme = false;

  bool nextPageAvailable = true;

  // Assigning current user
  final currentUser = ChatUser(
    id: '${Strings.userID}',
    name: '${Strings.username}',
  );

  var _chatController = ChatController(
      initialMessageList: msgList,
      scrollController: ScrollController(),
      chatUsers: chtusers);

  IO.Socket? _socket;
  int pageNo = 2;
  bool isloading = true;

  List<FetchMapedUsersData> _readUsersList = [];

  List<int> _selectedItems = [];

  TextEditingController _searchFieldController = TextEditingController();

  FocusNode searchField = new FocusNode();

  List<int>? GroupList = [];

  @override
  void dispose() {
    super.dispose();
    print("dispose called");
    _socket?.disconnect();
    _socket?.dispose();
  }

  @override
  void initState() {
    msgList.clear();
    super.initState();
    getUsersByGroupId();

    print("team idd ${widget.teamId}");

    //connect socket_io
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

    // Timer(Duration(seconds: 5), () {
    //       updateChatCountDetails("");
    //   });
  }

//join chatgroup
  joinGroup() {
    _socket?.emit(
        'join-group',
        json.encode({
          "group_id": widget.groupId,
        }));
    updateUsersReadMessage();
    getMessages();
    getUsersList();
  }

//function call to update readed message user
  updateUsersReadMessage() {
    _socket?.emit(
        'update-message-readed-user',
        json.encode({
          "group_id": widget.groupId,
        }));
  }

  void showUploadProgress(received, total) {
    if (total != -1) {
      AppUtils.showUploadProgressWithPercent(received / total);
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  getUsersByGroupId() {
    final api = Provider.of<ApiService>(context, listen: false);
    api.getChatUsers(widget.groupId!).then((response) {
      if (response.status!) {
        setState(() {
          chtusers.clear();
          response.data?.forEach((element) {
            print(
                "user image ${Strings.baseImageUrl + (element.userImage ?? "")}");
            chtusers.add(ChatUser(
                id: '${element.userId}',
                name: element.userName ?? "test",
                profilePhoto:
                    Strings.baseImageUrl + (element.userImage ?? "")));
          });
          log("added users ${jsonEncode(chtusers)}");

          addMentionUsers(response.data);
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }

  //add users to mentioning list
  addMentionUsers(users) {
    flutterMentionUserList.clear();

    for (int i = 0; i < chtusers.length; i++) {
      var user = {
        "id": users[i].userId.toString(),
        "display": users[i].userName?.split(' ')[0],
        "full_name": users[i].userName,
        "photo": Strings.baseImageUrl + (users[i].userImage ?? "")
      };
      flutterMentionUserList.add(user);
    }
  }

  //function call delete messages
  deleteMessagesById(int msgId, int grpId) {
    final api = Provider.of<ApiService>(context, listen: false);
    api.deleteMessage(msgId, grpId).then((response) {
      unSelectList([]);
      if (response.status!) {
        setState(() {
          AppUtils.showToastSuccess(response.message ?? "Deleted Successfully");
          joinGroup();
        });
      } else {
        print('error');
      }
      Strings.isSelectionEnabled = false;
    }).catchError((onError) {
      AppUtils.dismissprogress();
      unSelectList([]);
      print(onError.toString());
    });
  }

  updateChatCountDetails(String type) {
    final api = Provider.of<ApiService>(context, listen: false);
    api
        .checkMessageAvailability(
            widget.projectId,
            widget.teamId,
            Strings.userID,
            widget.projectId == null ? "team" : "project",
            type,
            widget.groupId)
        .then((response) {
      print("okkk");
    }).catchError((onError) {
      print(onError.toString());
    });
  }

//get the users list from socket_io
  getUsersList() {
    _socket?.on("group-users-list", (_data) {
      setState(() {
        flutterMentionUserList.clear();
        chtusers.clear();
        for (var item in _data) {
          var users = GroupChatUsersData.fromJson(item);
          print("user image ${Strings.baseImageUrl + (users.userImage ?? "")}");
          chtusers.add(ChatUser(
              id: '${users.userId}',
              name: users.userName ?? "test",
              profilePhoto: Strings.baseImageUrl + (users.userImage ?? "")));

          var user = {
            "id": users.userId.toString(),
            "display": users.userName?.split(' ')[0],
            "full_name": users.userName,
            "photo": Strings.baseImageUrl + (users.userImage ?? "")
          };
          flutterMentionUserList.add(user);
        }
      });
    });
  }

//get messages from socket io
  getMessages() {
    print("getting messages");
    _socket?.on("group-messages", (_data) {
      log("dataloaded $_data");

      // updateChatCountDetails("");
      setState(() {
        msgList.clear();
        if (_data.length > 0) {
          for (var item in _data) {
            var chat = ChatMessageRes.fromJson(item);
            if (chat.parentMessageId != 0 && chat.parentMessageId != null) {
              var mobj = Message(
                  message: chat.files == null
                      ? chat.message ?? ""
                      : Strings.baseImageUrl + (chat.files ?? ""),
                  createdAt: DateTime.parse(chat.createdAt!),
                  sendBy: '${chat.userId}',
                  id: '${chat.messageId}',
                  messageType: chat.files == null
                      ? MessageType.text
                      : chat.files!.contains("m4a")
                          ? MessageType.voice
                          : MessageType.image,
                  fileName: chat.fileName ?? "",
                  status:
                      chat.fileDownloadedUsers!.contains("${Strings.userID}")
                          ? MessageStatus.downloaded
                          : MessageStatus.downloadPending,
                  replyMessage: ReplyMessage(
                      message: chat.parentFiles == null
                          ? chat.parentMessage ?? ""
                          : Strings.baseImageUrl + (chat.parentFiles ?? ""),
                      messageId: "${chat.parentMessageId}",
                      replyBy: '${chat.userId}',
                      replyTo: '${chat.parentMessageUserId}',
                      messageType: chat.parentFiles == null
                          ? MessageType.text
                          : chat.parentFiles!.contains("m4a")
                              ? MessageType.voice
                              : MessageType.image));
              msgList.add(mobj);
            } else {
              var mobj = Message(
                  message: chat.files == null
                      ? chat.message ?? ""
                      : Strings.baseImageUrl + (chat.files ?? ""),
                  createdAt: DateTime.parse(chat.createdAt!),
                  sendBy: '${chat.userId}',
                  id: '${chat.messageId}',
                  messageType: chat.files == null
                      ? MessageType.text
                      : chat.files!.contains("m4a")
                          ? MessageType.voice
                          : MessageType.image,
                  fileName: chat.fileName ?? "",
                  status:
                      chat.fileDownloadedUsers!.contains("${Strings.userID}")
                          ? MessageStatus.downloaded
                          : MessageStatus.downloadPending);
              msgList.add(mobj);
            }

            _chatController = ChatController(
                initialMessageList: msgList,
                scrollController: ScrollController(),
                chatUsers: chtusers);
          }
        }
        isloading = false;
      });
    });
  }

//Pagination for older messages(API Call)
  Future<List<Message>> getMessagesWithPageCount() async {
    final api = Provider.of<ApiService>(context, listen: false);
    var val = await api.getMessagesWithPageCount(widget.groupId!, pageNo);
    // msgList.clear();
    List<Message> loasdedMsgList = [];

    if (val.status!) {
      pageNo += 1;
      setState(() {
        val.nextpage == 0
            ? nextPageAvailable = false
            : nextPageAvailable = true;
        for (ChatMessageRes item in val.data ?? []) {
          var chat = item;

          if (chat.parentMessageId != 0 && chat.parentMessageId != null) {
            var mobj = Message(
                message: chat.files == null
                    ? chat.message ?? ""
                    : Strings.baseImageUrl + (chat.files ?? ""),
                createdAt: DateTime.parse(chat.createdAt!),
                sendBy: '${chat.userId}',
                id: '${chat.messageId}',
                messageType: chat.files == null
                    ? MessageType.text
                    : chat.files!.contains("m4a")
                        ? MessageType.voice
                        : MessageType.image,
                fileName: chat.fileName ?? "",
                status: chat.isDownloaded == 0
                    ? MessageStatus.downloadPending
                    : MessageStatus.downloaded,
                replyMessage: ReplyMessage(
                    message: chat.parentFiles == null
                        ? chat.parentMessage ?? ""
                        : Strings.baseImageUrl + (chat.parentFiles ?? ""),
                    messageId: "${chat.parentMessageId}",
                    replyBy: '${chat.userId}',
                    replyTo: '${chat.parentMessageUserId}',
                    messageType: chat.parentFiles == null
                        ? MessageType.text
                        : chat.parentFiles!.contains("m4a")
                            ? MessageType.voice
                            : MessageType.image));
            loasdedMsgList.add(mobj);
          } else {
            var mobj = Message(
                message: chat.files == null
                    ? chat.message ?? ""
                    : Strings.baseImageUrl + (chat.files ?? ""),
                createdAt: DateTime.parse(chat.createdAt!),
                sendBy: '${chat.userId}',
                id: '${chat.messageId}',
                messageType: chat.files == null
                    ? MessageType.text
                    : chat.files!.contains("m4a")
                        ? MessageType.voice
                        : MessageType.image,
                fileName: chat.fileName ?? "",
                status: chat.isDownloaded == 0
                    ? MessageStatus.downloadPending
                    : MessageStatus.downloaded);
            loasdedMsgList.add(mobj);
          }
        }
        msgList.insertAll(0, loasdedMsgList);
      });
    } else {
      print('error');
    }
    return msgList;
  }

  // getMessagesWithPageCount()
  // {
  //   _socket?.emitWithAck(
  //       'get-message-with-pagecount',
  //       json.encode({
  //         "page_no": 2,
  //         "group_id": widget.groupId,

  //       }), ack: (_data) {
  //     print("dataaa ${_data}");
  //   });
  // }

//send recorded audio via API
  sendRecordedAudio(recordingPath, parentMsgId) {
    List<MultipartFile> audioFile = [
      MultipartFile.fromFileSync(
        "$recordingPath",
        filename: getFileName("$recordingPath"),
      )
    ];
    var formData = FormData.fromMap({
      'parent_message_id': parentMsgId,
      'user_id': Strings.userID,
      'group_id': widget.groupId,
      'groupFile': audioFile,
    });
    uploadFile(formData);
  }

//send documents via API
  sendFiles(files, parentMsgId) {
    print("$parentMsgId ${Strings.userID} ${widget.groupId}");
    var formData = FormData.fromMap({
      'parent_message_id': parentMsgId,
      'user_id': Strings.userID,
      'group_id': widget.groupId,
      'groupFile': files,
    });
    uploadFile(formData);
  }

  String getFileName(String _path) {
    return path.basename(_path);
  }

  uploadFile(formData) async {
    try {
      var myUrl = '${Strings.baseUrl}/chat/createMessage';
      var response = await dio.post(
        myUrl,
        data: formData,
        onSendProgress: showUploadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      print("response ${response.statusMessage}");

      print("status code ${response.statusCode}");
      if (response.statusCode == 200) {
        joinGroup();
        AppUtils.dismissprogress();
      } else if (response.statusCode == 404) {
        AppUtils.dismissprogress();
        AppUtils.showToastError("Sorry, File  not Found !");
      } else {
        AppUtils.dismissprogress();
      }
    } catch (e) {
      AppUtils.dismissprogress();
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? Center(child: CircularProgressIndicator())
        : WillPopScope(
            onWillPop: () {
              if (msgList
                      .where((element) => element.isSelected == true)
                      .length >
                  0) {
                msgList
                    .where((item) => item.isSelected == true)
                    .forEach((item) => item.isSelected = false);
                setState(() {});
              } else {
                if (Strings.fromNotificationChat) {
                  Strings.fromNotificationChat = false;
                  if (Strings.roleId == 6) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Projects(),
                      ),
                      (route) => false,
                    );
                    //   Navigator.pushNamed(context, "/projects");
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                         builder: (context) => TeamsDashboard(),
                      ),
                      (route) => false,
                    );
                    //   Navigator.pushNamed(context, "/teamsDashboard");
                  }
                } else {
                  Navigator.pop(context);
                }
              }

              throw '';
            },
            child: MaterialApp(
              builder: (_, child) => Portal(child: child!),
              home: SafeArea(
                child: Scaffold(
                  body: ChatView(
                    ctx: context,
                    msgList: msgList,
                    projectId: widget.projectId,
                    groupId: widget.groupId,
                    teamId: widget.teamId,
                    teamName: widget.teamName,
                    refreshCall: () {},
                    audioDownloadConfirmation: () {
                      joinGroup();
                    },
                    userList: flutterMentionUserList,
                    isLastPage: !nextPageAvailable,
                    loadMoreData: getMessagesWithPageCount,
                    currentUser: currentUser,
                    chatController: _chatController,
                    onSendTap: _onSendTap,
                    onLongPressed: _onLongPressed,
                    onTap: _onLongPressed,
                    onDeleteTap: () {
                      String id = msgList
                          .where((item) => item.isSelected == true)
                          .first
                          .id;
                      showDeleteDialog(context, int.tryParse(id));
                    },
                    onForwardTap: _onForwardTap,
                    onMoreTap: () {
                      Strings.isSelectionEnabled = false;
                      print("morre");
                      int? id = int.tryParse(msgList
                          .where((item) => item.isSelected == true)
                          .first
                          .id);
                      showLoading(context);
                      getReadUsers(id);
                    },
                    onBackPress: () {
                      if (msgList
                              .where((element) => element.isSelected == true)
                              .length >
                          0) {
                        msgList
                            .where((item) => item.isSelected == true)
                            .forEach((item) => item.isSelected = false);

                        Strings.isSelectionEnabled = false;
                        setState(() {});
                      } else {
                        if (Strings.fromNotificationChat) {
                          Strings.fromNotificationChat = false;
                          if (Strings.roleId == 6) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Projects(),
                              ),
                              (route) => false,
                            );
                            //   Navigator.pushNamed(context, "/projects");
                          } else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeamsDashboard(),
                              ),
                              (route) => false,
                            );
                            //   Navigator.pushNamed(context, "/teamsDashboard");
                          }
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    },
                    featureActiveConfig: const FeatureActiveConfig(
                      enableReactionPopup: false,
                      enablePagination: true,
                      lastSeenAgoBuilderVisibility: false,
                      receiptsBuilderVisibility: true,
                    ),
                    chatViewState: ChatViewState.hasMessages,
                    chatViewStateConfig: ChatViewStateConfiguration(
                      loadingWidgetConfig: ChatViewStateWidgetConfiguration(
                        loadingIndicatorColor: theme.outgoingChatBubbleColor,
                      ),
                      onReloadButtonTap: () {},
                    ),
                    typeIndicatorConfig: TypeIndicatorConfiguration(
                      flashingCircleBrightColor: theme.flashingCircleBrightColor,
                      flashingCircleDarkColor: theme.flashingCircleDarkColor,
                    ),
                    chatBackgroundConfig: ChatBackgroundConfiguration(
                      messageTimeIconColor: theme.messageTimeIconColor,
                      messageTimeTextStyle:
                          TextStyle(color: theme.messageTimeTextColor),
                      defaultGroupSeparatorConfig:
                          DefaultGroupSeparatorConfiguration(
                        textStyle: TextStyle(
                          color: theme.chatHeaderColor,
                          fontSize: 17,
                        ),
                      ),
                      backgroundColor: theme.backgroundColor,
                    ),
                    sendMessageConfig: SendMessageConfiguration(
                      imagePickerIconsConfig: ImagePickerIconsConfiguration(
                        cameraIconColor: theme.cameraIconColor,
                        galleryIconColor: theme.galleryIconColor,
                      ),
                      replyMessageColor: theme.replyMessageColor,
                      defaultSendButtonColor: theme.sendButtonColor,
                      replyDialogColor: theme.replyDialogColor,
                      replyTitleColor: theme.replyTitleColor,
                      textFieldBackgroundColor: theme.textFieldBackgroundColor,
                      closeIconColor: theme.closeIconColor,
                      textFieldConfig: TextFieldConfiguration(
                        onMessageTyping: (status) {
                          /// Do with status
                          debugPrint(status.toString());
                        },
                        compositionThresholdTime: const Duration(seconds: 1),
                        textStyle: TextStyle(color: theme.textFieldTextColor),
                      ),
                      micIconColor: theme.replyMicIconColor,
                      voiceRecordingConfiguration: VoiceRecordingConfiguration(
                        backgroundColor: theme.waveformBackgroundColor,
                        recorderIconColor: theme.recordIconColor,
                        waveStyle: WaveStyle(
                          showMiddleLine: false,
                          waveColor: theme.waveColor ?? Colors.white,
                          extendWaveform: true,
                        ),
                      ),
                    ),
                    chatBubbleConfig: ChatBubbleConfiguration(
                      outgoingChatBubbleConfig: ChatBubble(
                        linkPreviewConfig: LinkPreviewConfiguration(
                          backgroundColor: theme.linkPreviewOutgoingChatColor,
                          bodyStyle: theme.outgoingChatLinkBodyStyle,
                          titleStyle: theme.outgoingChatLinkTitleStyle,
                        ),
                        receiptsWidgetConfig: const ReceiptsWidgetConfig(
                            showReceiptsIn: ShowReceiptsIn.all),
                        color: theme.outgoingChatBubbleColor,
                      ),
                      inComingChatBubbleConfig: ChatBubble(
                        linkPreviewConfig: LinkPreviewConfiguration(
                          linkStyle: TextStyle(
                            color: theme.inComingChatBubbleTextColor,
                            decoration: TextDecoration.underline,
                          ),
                          backgroundColor: theme.linkPreviewIncomingChatColor,
                          bodyStyle: theme.incomingChatLinkBodyStyle,
                          titleStyle: theme.incomingChatLinkTitleStyle,
                        ),
                        textStyle:
                            TextStyle(color: theme.inComingChatBubbleTextColor),
                        onMessageRead: (message) {
                          /// send your message reciepts to the other client
                          debugPrint('Message Read');
                        },
                        senderNameTextStyle:
                            TextStyle(color: theme.inComingChatBubbleTextColor),
                        color: theme.inComingChatBubbleColor,
                      ),
                    ),
                    replyPopupConfig: ReplyPopupConfiguration(
                      onUnsendTap: (message) {
                        showDeleteDialog(context, int.parse(message.id));
                      },
                      onMoreTap: (message) {
                        print("morre");
                        showLoading(context);
                        getReadUsers(int.parse(message.id));
                      },
                      onReportTap: () {
                        print("report");
                      },
                      backgroundColor: theme.replyPopupColor,
                      buttonTextStyle:
                          TextStyle(color: theme.replyPopupButtonColor),
                      topBorderColor: theme.replyPopupTopBorderColor,
                    ),
                    messageConfig: MessageConfiguration(
                      messageReactionConfig: MessageReactionConfiguration(
                        backgroundColor: theme.messageReactionBackGroundColor,
                        borderColor: theme.messageReactionBackGroundColor,
                        reactedUserCountTextStyle:
                            TextStyle(color: theme.inComingChatBubbleTextColor),
                        reactionCountTextStyle:
                            TextStyle(color: theme.inComingChatBubbleTextColor),
                        reactionsBottomSheetConfig:
                            ReactionsBottomSheetConfiguration(
                          backgroundColor: theme.backgroundColor,
                          reactedUserTextStyle: TextStyle(
                            color: theme.inComingChatBubbleTextColor,
                          ),
                          reactionWidgetDecoration: BoxDecoration(
                            color: theme.inComingChatBubbleColor,
                            boxShadow: [
                              BoxShadow(
                                color: isDarkTheme
                                    ? Colors.black12
                                    : Colors.grey.shade200,
                                offset: const Offset(0, 20),
                                blurRadius: 40,
                              )
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      imageMessageConfig: ImageMessageConfiguration(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        shareIconConfig: ShareIconConfiguration(
                          defaultIconBackgroundColor:
                              theme.shareIconBackgroundColor,
                          defaultIconColor: theme.shareIconColor,
                        ),
                      ),
                    ),
                    repliedMessageConfig: RepliedMessageConfiguration(
                      backgroundColor: theme.repliedMessageColor,
                      verticalBarColor: theme.verticalBarColor,
                      repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
                        enableHighlightRepliedMsg: true,
                        highlightColor: Colors.pinkAccent.shade100,
                        highlightScale: 1.1,
                      ),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.25,
                      ),
                      replyTitleTextStyle:
                          TextStyle(color: theme.repliedTitleTextColor),
                    ),
                    swipeToReplyConfig: SwipeToReplyConfiguration(
                      replyIconColor: theme.swipeToReplyIconColor,
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> _onLongPressed(Message message) async {
    if (msgList.where((element) => element.isSelected == true).length > 0) {
      Strings.isSelectionEnabled = true;
    } else {
      Strings.isSelectionEnabled = false;
    }
    setState(() {});
  }

  Future<void> _onForwardTap(List<Message> messages) async {
    AppUtils.showprogress();
    GroupReq req = GroupReq();
    req.projectId = widget.projectId != null ? widget.projectId.toString() : "";
    req.groupType = widget.projectId == null ? "team" : "project";
    req.teamId = widget.teamId != null ? widget.teamId.toString() : "";
    req.userId = Strings.userID!.toString();
    req.groupId = widget.groupId.toString();
    final api = Provider.of<ApiService>(context, listen: false);
    api.fetchGroupList(req).then((response) {
      if (response.status!) {
        AppUtils.dismissprogress();
        showListPopup(response.data!, messages);
      } else {
        AppUtils.dismissprogress();
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();

      Strings.isSelectionEnabled = false;
      AppUtils.showToastError("Something went wrong!");
    });
  }

// Dummy Listview for group selection
  Future<void> showListPopup(List<Data> groups, List<Message> messages) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        List<Data> tempList = [];
        return AlertDialog(
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    InkWell(
                      child: new Icon(Icons.close,
                          size: 22.0, color: Colors.black),
                      onTap: () {
                        _searchFieldController.text = "";
                        _selectedItems.clear();
                        searchField.unfocus();
                        Navigator.of(context).pop();
                      },
                    )
                  ]),
                  Text(
                    'Select groups',
                    style: TextStyle(
                        // fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
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
                                      groups = tempList;
                                    });
                                    return;
                                  }
                                  setState(() {
                                    groups = tempList
                                        .where((data) => data.groupName!
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    tempList = groups;
                                  });
                                },
                              ),
                            ),
                            Icon(
                              Icons.search,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * 1,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: groups.length != 0
                        ? ListView.builder(
                            itemCount: groups.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      groups[index].groupName ?? "",
                                      maxLines: 3,
                                      style: TextStyle(
                                          fontWeight: _selectedItems.contains(
                                                  groups[index].groupId)
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                    ),
                                    onTap: () {
                                      if (!_selectedItems
                                          .contains(groups[index].groupId)) {
                                        setState(() {
                                          _selectedItems
                                              .add(groups[index].groupId!);
                                        });
                                      } else {
                                        setState(() {
                                          _selectedItems
                                              .remove(groups[index].groupId);
                                        });
                                      }
                                    },
                                    trailing: Checkbox(
                                      value: _selectedItems
                                          .contains(groups[index].groupId),
                                      onChanged: (bool? value) {
                                        if (value!) {
                                          if (_selectedItems.length < 5) {
                                            setState(() {
                                              _selectedItems.add(groups[index]
                                                  .groupId!); // Replace with your logic
                                            });
                                          } else {
                                            AppUtils.showToastError(
                                                "You can only share with upto 5 groups");
                                          }
                                        } else {
                                          setState(() {
                                            _selectedItems.remove(groups[index]
                                                .groupId); // Replace with your logic
                                          });
                                        }
                                      },
                                    ),
                                  )
                                ],
                              );
                            },
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
                            : Center(
                                child: Text("No groups found",
                                    style: TextStyle(color: Colors.red))),
                  ),
                ],
              ),
            );
          }),
          actions: [
            groups.length != 0
                ? TextButton(
                    onPressed: () async {
                      if (_selectedItems.isNotEmpty) {
                        // sendForwardMessage(messages);
                        await updateForwardMessage(messages);
                        var ids = messages
                            .where((element) => element.isSelected == true)
                            .map((element) {
                              return int.tryParse(element.id);
                            })
                            .cast<int>()
                            .toList();
                        unSelectList(ids);
                        AppUtils.showToastSuccess("Sending Messages..");
                        Timer(Duration(seconds: 2), () {
                          AppUtils.showToastSuccess(
                              "Message forwarded successfully!");
                        });
                      } else {
                        AppUtils.showToastError("Please select any one group!");
                      }
                    },
                    child: Text('Send', style: TextStyle(fontSize: 16)),
                  )
                : Container(),
          ],
        );
      },
    );
  }

  sendForwardMessage(List<Message> messages) {
    ForwadMessageReq req = ForwadMessageReq();
    req.documentId = messages
        .where((element) => element.isSelected == true)
        .map((element) {
          // Assuming 'id' property exists for true elements
          return int.tryParse(element.id);
        })
        .cast<int>()
        .toList();
    req.receiverGroupId = _selectedItems;
    req.senderGroupId = widget.groupId.toString();
    req.userId = Strings.userID!.toString();
    final api = Provider.of<ApiService>(context, listen: false);
    api.sendForwadMessage(req).then((response) {
      if (response.status!) {
        unSelectList(req.documentId);
        AppUtils.showToastSuccess("Message forwarded successfully!");
      } else {
        unSelectList(req.documentId);
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      unSelectList(req.documentId);
      AppUtils.showToastError("Something went wrong!");
    });
  }

  unSelectList(List<int>? selectedId) {
    if (selectedId!.isNotEmpty) {
      for (var targetId in selectedId) {
        msgList
            .where((item) => item.id == targetId.toString())
            .forEach((item) => item.isSelected = false);
      }
      _selectedItems.clear();
    } else {
      msgList
          .where((item) => item.isSelected == true)
          .forEach((item) => item.isSelected = false);
    }
    Strings.isSelectionEnabled = false;
    Navigator.pop(context);
    setState(() {});
  }

  Future<void> _onSendTap(String message, ReplyMessage replyMessage,
      MessageType messageType, List<MultipartFile> files) async {
    print(
        "reply msg ${replyMessage.messageId}  send${replyMessage.replyBy}  to ${replyMessage.replyTo}");
    if (messageType.isVoice) {
      sendRecordedAudio(message, replyMessage.messageId);
    } else if (messageType.isImage) {
      int totalLength = 0;
      for (MultipartFile file in files) {
        int content = await file.length;
        totalLength += content;
      }

      print("print totla ${(totalLength / 1024)}");

      var totalSize = totalLength / 1024;

      //var response = await dio.post('https://demo.emeetify.com:81/mta/chat/createMessage', data: formData);
      // check response status code
      if (totalSize <= 25600) {
        sendFiles(files, replyMessage.messageId);
      } else {
        _showFileSizeWarning();
      }
    } else {
      updateChat(message, replyMessage.messageId);
    }
    Strings.isSelectionEnabled = false;
    print("reeeee ${files.length}");

    // final id = int.parse(Data.messageList.last.id) + 1;
    // _chatController.addMessage(
    //   Message(
    //     id: id.toString(),
    //     createdAt: DateTime.now(),
    //     message: message,
    //     sendBy: currentUser.id,
    //     replyMessage: replyMessage,
    //     messageType: messageType,
    //   ),
    // );
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   _chatController.initialMessageList.last.setStatus =
    //       MessageStatus.undelivered;
    // });
    // Future.delayed(const Duration(seconds: 1), () {
    //   _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    // });
  }

  Future<bool> _showFileSizeWarning() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text(
              "File Size is High",
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0061b0),
                  fontWeight: FontWeight.w600),
            ),
            content: Text(
              "Total file size should not be more than 25 MB. Please try again.",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text(
                  'Okay',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  getReadUsers(msgID) {
    _readUsersList = [];
    final api = Provider.of<ApiService>(context, listen: false);
    api.getReadedUsers(msgID).then((response) {
      if (response.status!) {
        setState(() {
          _readUsersList = response.data!;
        });
        unSelectList([]);
        showReadUsersDialog();
      } else {
        AppUtils.showToastError(response.message ?? "Unknown Error");
        unSelectList([]);
        print('error');
      }
    }).catchError((onError) {
      unSelectList([]);
      AppUtils.showToastError(onError.toString());
    });
  }

  Future<void> showReadUsersDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            print("checkk ${jsonEncode(_readUsersList)}");
            return SingleChildScrollView(
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        new Icon(Icons.close, size: 22.0, color: Colors.black)
                      ]),
                      Text(
                        "Read Users",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 1,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: _readUsersList.length != 0
                            ? ListView.builder(
                                itemCount: _readUsersList.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Card(
                                        color: Color.fromRGBO(230, 230, 230, 1),
                                        child: ListTile(
                                          title: Text(
                                            _readUsersList[index].name ?? "",
                                          ),
                                          // subtitle: Text(_readUsersList[index].prof ?? ""),
                                          onTap: () {},
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                            : Center(
                                child: Text("Not read by any users!",
                                    style: TextStyle(color: Colors.red))),
                      ),
                    ],
                  )),
            );
          }),
        );
      },
    );
  }

  showLoading(BuildContext context) {
    showDialog<void>(
      barrierColor: Colors.white.withOpacity(0.4),
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 8.0,
          backgroundColor:
              Colors.white, // can change this to your prefered color
          children: <Widget>[
            Container(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            Center(
                child: Text("Please wait! While the Details are being fetched"))
          ],
        );
      },
    );
  }

  Future<bool> showDeleteDialog(ctx, messageId) async {
    return await showDialog(
      context: ctx,
      builder: (context) => new AlertDialog(
        title: Text(
          "Delete ?",
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFF0061b0),
              fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure to delete the Message?',
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
            onPressed: () {
              deleteMessagesById(messageId, widget.groupId ?? 0);
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

  updateChat(msg, parentMsgId) {
    _socket?.emitWithAck(
        'create-message',
        json.encode({
          "message": msg,
          "group_id": widget.groupId,
          "user_id": Strings.userID,
          "parent_message_id": parentMsgId
        }), ack: (_data) {
      print("dataaa ${_data}");
    });

    // updateChatCountDetails("create");
  }

  updateForwardMessage(List<Message> messages) {
    _socket?.emitWithAck(
        'forward-message',
        json.encode({
          "document_id": messages
              .where((element) => element.isSelected == true)
              .map((element) {
                // Assuming 'id' property exists for true elements
                return int.tryParse(element.id);
              })
              .cast<int>()
              .toList(),
          "receiver_group_id": _selectedItems,
          "sender_group_id": widget.groupId.toString(),
          "user_id": Strings.userID!.toString()
        }));
  }

  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
      }
    });
  }
}
