
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:mta/screens/chat/data.dart';
import 'package:mta/screens/chat/theme.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:path/path.dart' as path;

import '../../ChatView/lib/chatview.dart';
import '../../models/Chat/ChatMessageRes.dart';
import '../../network/ApiService.dart';
import '../../utilities/apputilities.dart';
import '../../utilities/strings.dart';




class Example extends StatefulWidget {
  final int groupId;
    final int teamId;
  const Example({Key? key,required this.groupId,required this.teamId}) : super(key: key);

  @override
  State<Example> createState() => _ChatScreenState();
}
  List<Message> msgList = [];
  List<ChatUser> chtusers = [];
  var dio = Dio();

class _ChatScreenState extends State<Example> {
  AppTheme theme = LightTheme();
  bool isDarkTheme = false;

  bool nextPageAvailable = true;

  // final currentUser = ChatUser(
  //   id: '1',
  //   name: 'Flutter',
  //   profilePhoto: Data.profileImage,
  // );
  final currentUser = ChatUser(
    id: '${Strings.userID}',
    name: '${Strings.username}',
    profilePhoto: Data.profileImage,
  );

  var _chatController;

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }
IO.Socket? _socket;
int pageNo = 2;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
getUsersByGroupId();
     _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': false,
      'query': {'token': Strings.authToken, 
      'group_id': widget.groupId,
      "group_type":"team",
      "project_id":null,
      "team_id":widget.teamId
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

    getMessages();
  }

  void showUploadProgress(received, total) {
    if (total != -1) {
      AppUtils.showUploadProgressWithPercent(received / total);
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }


  getUsersByGroupId() {
    final api = Provider.of<ApiService>(context, listen: false);
    api.getChatUsers(widget.groupId).then((response) {
      if (response.status!) {
        setState(() {
          response.data?.forEach((element) { 
            chtusers.add(ChatUser(id: '${element.userId}', name: element.userName ?? "test"));

          });
        });
      } else {
        print('error');
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    });
  }
  getMessages()
  {
    print("getting messages");
    _socket?.on("group-messages", (_data) {
      log("data $_data");
      setState(() {
        msgList.clear();
        for (var item in _data) {
         var chat =  ChatMessageRes.fromJson(item);
                   print("prrrint ${jsonEncode(chat)}");
          if(chat.parentMessageId != 0 && chat.parentMessageId != null)
          {
 
         var mobj = Message(
          message:chat.files == null? chat.message ?? "":Strings.uatImageUrl+(chat.files ??""), 
                    createdAt: DateTime.parse(chat.createdAt!), sendBy: '${chat.userId}',id: '${chat.messageId}',
         messageType: chat.files == null?MessageType.text: chat.files!.contains("m4a")?MessageType.voice: MessageType.image,
         fileName: chat.fileName ?? "",status: chat.isDownloaded == 0 ?MessageStatus.downloadPending:MessageStatus.downloaded ,
          replyMessage: ReplyMessage(
            
            
            message: chat.parentFiles == null? chat.parentMessage ?? "":Strings.uatImageUrl+(chat.parentFiles ??""),messageId: "${chat.parentMessageId}",replyBy: '${chat.userId}',replyTo: '${chat.parentMessageUserId}',
          messageType: chat.parentFiles == null?MessageType.text: chat.parentFiles!.contains("m4a")?MessageType.voice: MessageType.image)
         );
                          msgList.add(mobj);
          }else{

         var mobj = Message(
          message:chat.files == null? chat.message ?? "":Strings.uatImageUrl+(chat.files ??""), 
                    createdAt: DateTime.parse(chat.createdAt!), sendBy: '${chat.userId}',id: '${chat.messageId}',
         messageType: chat.files == null?MessageType.text: chat.files!.contains("m4a")?MessageType.voice: MessageType.image,
         fileName: chat.fileName ?? "",status: chat.isDownloaded == 0 ?MessageStatus.downloadPending:MessageStatus.downloaded );
                          msgList.add(mobj);
          }



       _chatController =   ChatController(
    initialMessageList: msgList,
    scrollController: ScrollController(),
   chatUsers: chtusers
    // chatUsers: [
    //   ChatUser(
    //     id: '2',
    //     name: 'Simform',
    //     profilePhoto: Data.profileImage,
    //   ),
    //   ChatUser(
    //     id: '3',
    //     name: 'Jhon',
    //     profilePhoto: Data.profileImage,
    //   ),
    //   ChatUser(
    //     id: '4',
    //     name: 'Mike',
    //     profilePhoto: Data.profileImage,
    //   ),
    //   ChatUser(
    //     id: '5',
    //     name: 'Rich',
    //     profilePhoto: Data.profileImage,
    //   ),
    // ],
    //chtusers
  );
        }
      });
    });
  }

  Future<List<Message>> getMessagesWithPageCount() async
  {

  
    final api = Provider.of<ApiService>(context, listen: false);
    var val = await api.getMessagesWithPageCount(widget.groupId,pageNo);
               msgList.clear();
    if (val.status!) 
      {
        pageNo += 1;
        setState(() 
        {
        val.nextpage == 0?nextPageAvailable =false:nextPageAvailable =true;
        for (ChatMessageRes item in val.data ?? []) 
        {
         var chat =  item;

          if(chat.parentMessageId != 0 && chat.parentMessageId != null)
          {
 
         var mobj = Message(
          message:chat.files == null? chat.message ?? "":Strings.uatImageUrl+(chat.files ??""), 
                    createdAt: DateTime.parse(chat.createdAt!), sendBy: '${chat.userId}',id: '${chat.messageId}',
         messageType: chat.files == null?MessageType.text: chat.files!.contains("m4a")?MessageType.voice: MessageType.image,
         fileName: chat.fileName ?? "",status: chat.isDownloaded == 0 ?MessageStatus.downloadPending:MessageStatus.downloaded ,
          replyMessage: ReplyMessage(
            
            
            message: chat.parentFiles == null? chat.parentMessage ?? "":Strings.uatImageUrl+(chat.parentFiles ??""),messageId: "${chat.parentMessageId}",replyBy: '${chat.userId}',replyTo: '${chat.parentMessageUserId}',
          messageType: chat.parentFiles == null?MessageType.text: chat.parentFiles!.contains("m4a")?MessageType.voice: MessageType.image)
         );
                          msgList.add(mobj);
          }else{

         var mobj = Message(
          message:chat.files == null? chat.message ?? "":Strings.uatImageUrl+(chat.files ??""), 
                    createdAt: DateTime.parse(chat.createdAt!), sendBy: '${chat.userId}',id: '${chat.messageId}',
         messageType: chat.files == null?MessageType.text: chat.files!.contains("m4a")?MessageType.voice: MessageType.image,
         fileName: chat.fileName ?? "",status: chat.isDownloaded == 0 ?MessageStatus.downloadPending:MessageStatus.downloaded );
                          msgList.add(mobj);
          }


        }});
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

  sendRecordedAudio(recordingPath) 
  {
    List<MultipartFile> audioFile = [
      MultipartFile.fromFileSync(
        "$recordingPath",
        filename: getFileName("$recordingPath"),
      )
    ];
    var formData = FormData.fromMap({
      'parent_message_id':"",
      'user_id': Strings.userID,
      'group_id': widget.groupId,
      'groupFile': audioFile,
    });
    uploadFile(formData);
  }
  String getFileName(String _path) {
    return path.basename(_path);
  }
   uploadFile(formData) async 
   {
    try {
      var myUrl = 'https://demo.emeetify.com:81/mta/chat/createMessage';
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
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: "Chat App",
                  builder: (_, child) => Portal(child: child!),

      home: Scaffold(
        body: ChatView(
          isLastPage: !nextPageAvailable,
          loadMoreData: 
          getMessagesWithPageCount,
          currentUser: currentUser,
          chatController: _chatController,
          onSendTap: _onSendTap,
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
          appBar: ChatViewAppBar(
            elevation: theme.elevation,
            backGroundColor: theme.appBarColor,
            profilePicture: Data.profileImage,
            backArrowColor: theme.backArrowColor,
            chatTitle: "Chat view",
            chatTitleTextStyle: TextStyle(
              color: theme.appBarTitleTextStyle,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.25,
            ),
            userStatusTextStyle: const TextStyle(color: Colors.grey),
            actions: [
              // IconButton(
              //   onPressed: _onThemeIconTap,
              //   icon: Icon(
              //     isDarkTheme
              //         ? Icons.brightness_4_outlined
              //         : Icons.dark_mode_outlined,
              //     color: theme.themeIconColor,
              //   ),
              // ),
              // IconButton(
              //   tooltip: 'Toggle TypingIndicator',
              //   onPressed: _showHideTypingIndicator,
              //   icon: Icon(
              //     Icons.keyboard,
              //     color: theme.themeIconColor,
              //   ),
              // ),
            ],
          ),
          
          chatBackgroundConfig: ChatBackgroundConfiguration(
            messageTimeIconColor: theme.messageTimeIconColor,
            messageTimeTextStyle: TextStyle(color: theme.messageTimeTextColor),
            defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
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
              receiptsWidgetConfig:
                  const ReceiptsWidgetConfig(showReceiptsIn: ShowReceiptsIn.all),
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
              textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
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
            backgroundColor: theme.replyPopupColor,
            buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
            topBorderColor: theme.replyPopupTopBorderColor,
          ),
          reactionPopupConfig: ReactionPopupConfiguration(
            shadow: BoxShadow(
              color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
              blurRadius: 20,
            ),
            backgroundColor: theme.reactionPopupColor,
          ),
          messageConfig: MessageConfiguration(
            messageReactionConfig: MessageReactionConfiguration(
              backgroundColor: theme.messageReactionBackGroundColor,
              borderColor: theme.messageReactionBackGroundColor,
              reactedUserCountTextStyle:
                  TextStyle(color: theme.inComingChatBubbleTextColor),
              reactionCountTextStyle:
                  TextStyle(color: theme.inComingChatBubbleTextColor),
              reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                backgroundColor: theme.backgroundColor,
                reactedUserTextStyle: TextStyle(
                  color: theme.inComingChatBubbleTextColor,
                ),
                reactionWidgetDecoration: BoxDecoration(
                  color: theme.inComingChatBubbleColor,
                  boxShadow: [
                    BoxShadow(
                      color: isDarkTheme ? Colors.black12 : Colors.grey.shade200,
                      offset: const Offset(0, 20),
                      blurRadius: 40,
                    )
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            customMessageBuilder: customMsg,
            imageMessageConfig: ImageMessageConfiguration(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              shareIconConfig: ShareIconConfiguration(
                defaultIconBackgroundColor: theme.shareIconBackgroundColor,
                defaultIconColor: theme.shareIconColor,
              ),
            ),
          ),
          profileCircleConfig: const ProfileCircleConfiguration(
            profileImageUrl: Data.profileImage,
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
            replyTitleTextStyle: TextStyle(color: theme.repliedTitleTextColor),
          ),
          swipeToReplyConfig: SwipeToReplyConfiguration(
            replyIconColor: theme.swipeToReplyIconColor,
          ),
        ),
      ),
    );
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ){
    print("reply msg ${replyMessage.messageId}  send${replyMessage.replyBy}  to ${replyMessage.replyTo}");
    if(messageType.isVoice || messageType.isImage)
    {
        sendRecordedAudio(message);
    }
    else
    {
      updateChat(message,replyMessage.messageId);
    }

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

  Widget customMsg(msg){
    return Image.asset(
                                                getFileExt(
                                                    msg.message),
                                                height: 100,
                                                fit: BoxFit.cover,
                                              );
  }

   String getFileExt(String? fileName) 
  {
    print("Filename--> $fileName");
    var file = fileName?.split("/");
    var fileExttemp = file?[file.length - 1];

    var finalSplit = fileExttemp?.split(".");
    var fileExt = finalSplit?[finalSplit.length - 1];

    print("exttt $fileExt");
    if (fileExt == "png" || fileExt == "PNG") {
      return "assets/icons/png.png";
    } else if (fileExt == "jpg" ||
        fileExt == "jepg" ||
        fileExt == "jpeg" ||
        fileExt == "JPG" ||
        fileExt == "JEPG" ||
        fileExt == "JPEG") {
      return "assets/icons/jpg.png";
    } else if (fileExt == "pdf" || fileExt == "PDF") {
      return "assets/icons/pdf.png";
    } else if (fileExt == "txt" || fileExt == "TXT") {
      return "assets/icons/txt.png";
    } else if (fileExt == "ppt" || fileExt == "PPT") {
      return "assets/icons/ppt.png";
    } else if (fileExt == "mpeg" || fileExt == "mpg") {
      return "assets/icons/mpg.png";
    } else if (fileExt == "mp4") {
      return "assets/icons/mpg.png";
    } else if (fileExt == "wav" || fileExt == "mp3") {
      return "assets/icons/mp3.png";
    } else if (fileExt == "xls" ||
        fileExt == "xlsx" ||
        fileExt == "xlsm" ||
        fileExt == "xlsb" ||
        fileExt == "xltx") {
      return "assets/icons/xls.png";
    } else {
      return "assets/icons/doc.png";
    }
  }

  updateChat(msg,parentMsgId) 
  {
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