import 'dart:async';
import 'dart:io' if (kIsWeb) 'dart:html';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mta/ChatView/extensions/extensions.dart';
import 'package:mta/ChatView/widgets/chat_groupedlist_widget.dart';
import 'package:mta/utilities/apputilities.dart';

import '../chatview.dart';
import 'reaction_popup.dart';
import 'reply_popup_widget.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget(
      {Key? key,
      required this.chatController,
      required this.chatBackgroundConfig,
      required this.showTypingIndicator,
      required this.assignReplyMessage,
      required this.replyMessage,
      this.refreshCall,
      this.loadingWidget,
      this.reactionPopupConfig,
      this.messageConfig,
      this.chatBubbleConfig,
      this.profileCircleConfig,
      this.swipeToReplyConfig,
      this.repliedMessageConfig,
      this.typeIndicatorConfig,
      this.replyPopupConfig,
      this.loadMoreData,
      this.isLastPage,
      this.onChatListTap,
      this.audioDownloadConfirmation})
      : super(key: key);

  /// Provides controller for accessing few function for running chat.
  final ChatController chatController;

  /// Provides configuration for background of chat.
  final ChatBackgroundConfiguration chatBackgroundConfig;

  /// Provides widget for loading view while pagination is enabled.
  final Widget? loadingWidget;

  /// Provides flag for turn on/off typing indicator.
  final bool showTypingIndicator;

  /// Provides configuration for reaction pop up appearance.
  final ReactionPopupConfiguration? reactionPopupConfig;

  /// Provides configuration for customisation of different types
  /// messages.
  final MessageConfiguration? messageConfig;

  /// Provides configuration of chat bubble's appearance.
  final ChatBubbleConfiguration? chatBubbleConfig;

  /// Provides configuration for profile circle avatar of user.
  final ProfileCircleConfiguration? profileCircleConfig;

  /// Provides configuration for when user swipe to chat bubble.
  final SwipeToReplyConfiguration? swipeToReplyConfig;

  /// Provides configuration for replied message view which is located upon chat
  /// bubble.
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides configuration of typing indicator's appearance.
  final TypeIndicatorConfiguration? typeIndicatorConfig;

  /// Provides reply message when user swipe to chat bubble.
  final ReplyMessage replyMessage;

  /// Provides configuration for reply snack bar's appearance and options.
  final ReplyPopupConfiguration? replyPopupConfig;

  /// Provides callback when user actions reaches to top and needs to load more
  /// chat
  final VoidCallBackWithFuture? loadMoreData;

  /// Provides flag if there is no more next data left in list.
  final bool? isLastPage;

  /// Provides callback for assigning reply message when user swipe to chat
  /// bubble.
  final MessageCallBack assignReplyMessage;

  /// Provides callback when user tap anywhere on whole chat.
  final VoidCallBack? onChatListTap;

  final DataRefreshCallback? refreshCall;

  final Function()? audioDownloadConfirmation;

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _isNextPageLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> showPopUp = ValueNotifier(false);
  final GlobalKey<ReactionPopupState> _reactionPopupKey = GlobalKey();

  List<String> _selectedItems = [];

  ChatController get chatController => widget.chatController;

  List<Message> get messageList => chatController.initialMessageList;

  ScrollController get scrollController => chatController.scrollController;

  bool get showTypingIndicator => widget.showTypingIndicator;

  ChatBackgroundConfiguration get chatBackgroundConfig =>
      widget.chatBackgroundConfig;

  FeatureActiveConfig? featureActiveConfig;
  ChatUser? currentUser;

  FocusNode searchField = new FocusNode();
  TextEditingController _searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      featureActiveConfig = provide!.featureActiveConfig;
      currentUser = provide!.currentUser;
    }
    if (featureActiveConfig?.enablePagination ?? false) {
      // When flag is on then it will include pagination logic to scroll
      // controller.
      scrollController.addListener(_pagination);
    }
  }

  void _initialize() {
    chatController.messageStreamController = StreamController();
    if (!chatController.messageStreamController.isClosed) {
      chatController.messageStreamController.sink.add(messageList);
    }
    if (messageList.isNotEmpty) chatController.scrollToLastMessage();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _isNextPageLoading,
            builder: (_, isNextPageLoading, child) {
              if (isNextPageLoading &&
                  (featureActiveConfig?.enablePagination ?? false)) {
                print("printttt data ");
                return SizedBox(
                  height: Scaffold.of(context).appBarMaxHeight,
                  child: Center(
                    child: widget.loadingWidget ??
                        const CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: showPopUp,
              builder: (_, showPopupValue, child) {
                return Stack(
                  children: [
                    ChatGroupedListWidget(
                      audioDownloadConfirmation:
                          widget.audioDownloadConfirmation,
                      showPopUp: showPopupValue,
                      showTypingIndicator: showTypingIndicator,
                      scrollController: scrollController,
                      isEnableSwipeToSeeTime:
                          featureActiveConfig?.enableSwipeToSeeTime ?? true,
                      chatBackgroundConfig: widget.chatBackgroundConfig,
                      assignReplyMessage: widget.assignReplyMessage,
                      replyMessage: widget.replyMessage,
                      swipeToReplyConfig: widget.swipeToReplyConfig,
                      repliedMessageConfig: widget.repliedMessageConfig,
                      profileCircleConfig: widget.profileCircleConfig,
                      messageConfig: widget.messageConfig,
                      chatBubbleConfig: widget.chatBubbleConfig,
                      typeIndicatorConfig: widget.typeIndicatorConfig,
                      onChatBubbleLongPress:
                          (yCoordinate, xCoordinate, message) {
                        if (featureActiveConfig?.enableReactionPopup ?? false) {
                          _reactionPopupKey.currentState?.refreshWidget(
                            message: message,
                            xCoordinate: xCoordinate,
                            yCoordinate: yCoordinate < 0
                                ? -(yCoordinate) - 5
                                : yCoordinate,
                          );
                          showPopUp.value = true;
                        }
                        if (featureActiveConfig?.enableReplySnackBar ?? false) {
                          _showReplyPopup(
                            message: message,
                            sendByCurrentUser:
                                message.sendBy == currentUser?.id,
                          );
                        }
                      },
                      onChatListTap: _onChatListTap,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pagination() {
    print("pagination called ${widget.loadMoreData}");
    if (widget.loadMoreData == null || widget.isLastPage == true) return;
    if ((scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) &&
        !_isNextPageLoading.value) {
      print("truee loding");
      _isNextPageLoading.value = true;
      widget.loadMoreData!()
          .whenComplete(() => _isNextPageLoading.value = false);
    }
  }

  void _showReplyPopup({
    required Message message,
    required bool sendByCurrentUser,
  }) {
    final replyPopup = widget.replyPopupConfig;
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            duration: const Duration(hours: 1),
            backgroundColor: Colors.transparent,
            content: replyPopup?.replyPopupBuilder != null
                ? replyPopup!.replyPopupBuilder!(message, sendByCurrentUser)
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: ReplyPopupWidget(
                      buttonTextStyle: replyPopup?.buttonTextStyle,
                      topBorderColor: replyPopup?.topBorderColor,
                      onMoreTap: () {
                        _onChatListTap();
                        if (replyPopup?.onMoreTap != null) {
                          replyPopup?.onMoreTap!(message);
                        }
                      },
                      onReportTap: () {
                        _onChatListTap();
                        if (replyPopup?.onReportTap != null) {
                          replyPopup?.onReportTap!();
                        }
                      },
                      onUnsendTap: () {
                        print("message id ${message.id}");
                        _onChatListTap();
                        if (replyPopup?.onUnsendTap != null) {
                          replyPopup?.onUnsendTap!(message);
                        }
                      },
                      onReplyTap: () {
                        widget.assignReplyMessage(message);
                        if (featureActiveConfig?.enableReactionPopup ?? false) {
                          showPopUp.value = false;
                        }
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        if (replyPopup?.onReplyTap != null) {
                          replyPopup?.onReplyTap!(message);
                        }
                      },
                      onForwardTap: () {
                        print(">>>>>123");

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        showListPopup();
                      },
                      onCopyTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: message.message));

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                        AppUtils.showToast('Text copied to clipboard!');
                      },
                      sendByCurrentUser: sendByCurrentUser,
                      isCopyButtonEnabled:
                          message.messageType == MessageType.text,
                    ),
                  ),
            padding: EdgeInsets.zero,
          ),
        )
        .closed;
  }

  void _onChatListTap() {
    widget.onChatListTap?.call();
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      FocusScope.of(context).unfocus();
    }
    showPopUp.value = false;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

// Dummy Listview for group selection
  Future<void> showListPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        var items = [
          'Item 1',
          'Item 2',
          'Item 3',
          'Item 4',
          'Item 5',
          'Item 6',
          'Item 7',
          'Item 8',
          'Item 9'
        ];
        List<String> tempList = [];
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
                                      items = tempList;
                                    });
                                    return;
                                  }
                                  setState(() {
                                    items = tempList
                                        .where((data) => data
                                            .toLowerCase()
                                            .contains(value.toLowerCase()))
                                        .toList();
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    tempList = items;
                                  });
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
                  Container(
                    height: MediaQuery.of(context).size.width * 1,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: items.length != 0
                        ? ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      items[index],
                                      maxLines: 3,
                                      style: TextStyle(
                                          fontWeight: _selectedItems
                                                  .contains(items[index])
                                              ? FontWeight.bold
                                              : FontWeight.normal),
                                    ),
                                    onTap: () {
                                      if (!_selectedItems
                                          .contains(items[index])) {
                                        setState(() {
                                          _selectedItems.add(items[index]);
                                        });
                                      } else {
                                        setState(() {
                                          _selectedItems.remove(items[index]);
                                        });
                                      }
                                    },
                                    trailing: Checkbox(
                                      value:
                                          _selectedItems.contains(items[index]),
                                      onChanged: (bool? value) {
                                        if (value!) {
                                          setState(() {
                                            _selectedItems.add(items[
                                                index]); // Replace with your logic
                                          });
                                        } else {
                                          setState(() {
                                            _selectedItems.remove(items[
                                                index]); // Replace with your logic
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
                                child: Text("No assigned projects found",
                                    style: TextStyle(color: Colors.red))),
                  ),
                ],
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Send'),
            ),
          ],
        );
      },
    ).whenComplete(() => _selectedItems.clear());
  }

  @override
  void dispose() {
    chatController.messageStreamController.close();
    scrollController.dispose();
    _isNextPageLoading.dispose();
    showPopUp.dispose();
    super.dispose();
  }
}
