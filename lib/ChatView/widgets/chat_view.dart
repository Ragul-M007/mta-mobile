/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 WARE.
 */

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mta/ChatView/widgets/chat_list_widget.dart';
import 'package:mta/ChatView/widgets/chat_view_inherited_widget.dart';
import 'package:mta/ChatView/widgets/chatview_state_widget.dart';
import 'package:mta/screens/chat/ChatMedia.dart';
import 'package:mta/screens/chat/ChatScreen.dart';
import 'package:mta/screens/chat/theme.dart';
import 'package:mta/screens/dashboard/teamsDashboard.dart';
import 'package:mta/screens/projects/projects.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';
import 'package:timeago/timeago.dart';
import '../chatview.dart';
import '../values/custom_time_messages.dart';
import 'send_message_widget.dart';

class ChatView extends StatefulWidget {
  const ChatView(
      {Key? key,
      required this.chatController,
      required this.currentUser,
      this.onSendTap,
      this.onForwardTap,
      this.onMoreTap,
      this.refreshCall,
      this.profileCircleConfig,
      this.chatBubbleConfig,
      this.repliedMessageConfig,
      this.swipeToReplyConfig,
      this.replyPopupConfig,
      this.reactionPopupConfig,
      this.loadMoreData,
      this.loadingWidget,
      this.messageConfig,
      this.isLastPage,
      this.userList,
      ChatBackgroundConfiguration? chatBackgroundConfig,
      this.typeIndicatorConfig,
      this.sendMessageBuilder,
      this.showTypingIndicator = false,
      this.sendMessageConfig,
      this.onChatListTap,
      this.onDeleteTap,
      this.onLongPressed,
      this.onTap,
      this.onBackPress,
      this.audioDownloadConfirmation,
      required this.msgList,
      required this.chatViewState,
      ChatViewStateConfiguration? chatViewStateConfig,
      this.featureActiveConfig = const FeatureActiveConfig(),
      this.groupId,
      this.teamId,
      this.projectId,
      required this.teamName,
      required this.ctx})
      : chatBackgroundConfig =
            chatBackgroundConfig ?? const ChatBackgroundConfiguration(),
        chatViewStateConfig =
            chatViewStateConfig ?? const ChatViewStateConfiguration(),
        super(key: key);

  /// Provides configuration related to user profile circle avatar.
  final ProfileCircleConfiguration? profileCircleConfig;

  /// Provides configurations related to chat bubble such as padding, margin, max
  /// width etc.
  final ChatBubbleConfiguration? chatBubbleConfig;

  /// Allow user to giving customisation different types
  /// messages.
  final MessageConfiguration? messageConfig;

  /// Provides configuration for replied message view which is located upon chat
  /// bubble.
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides configurations related to swipe chat bubble which triggers
  /// when user swipe chat bubble.
  final SwipeToReplyConfiguration? swipeToReplyConfig;

  /// Provides configuration for reply snack bar's appearance and options.
  final ReplyPopupConfiguration? replyPopupConfig;

  /// Provides configuration for reaction pop up appearance.
  final ReactionPopupConfiguration? reactionPopupConfig;

  /// Allow user to give customisation to background of chat
  final ChatBackgroundConfiguration chatBackgroundConfig;

  /// Provides callback when user actions reaches to top and needs to load more
  /// chat
  final VoidCallBackWithFuture? loadMoreData;

  /// Provides widget for loading view while pagination is enabled.
  final Widget? loadingWidget;

  /// Provides flag if there is no more next data left in list.
  final bool? isLastPage;

  /// Provides call back when user tap on send button in text field. It returns
  /// message, reply message and message type.
  final ListCallBack? onSendTap;

  /// Provides call back when user tap on forward button. It returns
  /// message, reply message and message type.
  final ForwardCallBack? onForwardTap;

  final VoidCallBack? onMoreTap;

  /// Provides builder which helps you to make custom text field and functionality.
  final ReplyMessageWithReturnWidget? sendMessageBuilder;

  final DataRefreshCallback? refreshCall;

  final List<Map<String, dynamic>>? userList;
  final Function()? audioDownloadConfirmation;
  final List<Message> msgList;

  @Deprecated('Use [ChatController.setTypingIndicator]  instead')

  /// Allow user to show typing indicator.
  final bool showTypingIndicator;

  /// Allow user to giving customisation typing indicator.
  final TypeIndicatorConfiguration? typeIndicatorConfig;

  /// Provides controller for accessing few function for running chat.
  final ChatController chatController;

  /// Provides configuration of default text field in chat.
  final SendMessageConfiguration? sendMessageConfig;

  /// Provides current state of chat.
  final ChatViewState chatViewState;

  /// Provides configuration for chat view state appearance and functionality.
  final ChatViewStateConfiguration? chatViewStateConfig;

  /// Provides current user which is sending messages.
  final ChatUser currentUser;

  /// Provides configuration for turn on/off specific features.
  final FeatureActiveConfig featureActiveConfig;

  /// Provides callback when user tap on chat list.
  final VoidCallBack? onChatListTap;

  final VoidCallBack? onDeleteTap;

  final MessageCallBack? onLongPressed;

  final MessageCallBack? onTap;
  final VoidCallBack? onBackPress;
  final int? projectId;
  final int? groupId;
  final int? teamId;
  final String teamName;
  final BuildContext ctx;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SendMessageWidgetState> _sendMessageKey = GlobalKey();
  ValueNotifier<ReplyMessage> replyMessage =
      ValueNotifier(const ReplyMessage());

  ChatController get chatController => widget.chatController;

  // bool get showTypingIndicator => widget.showTypingIndicator;

  ChatBackgroundConfiguration get chatBackgroundConfig =>
      widget.chatBackgroundConfig;

  ChatViewState get chatViewState => widget.chatViewState;

  ChatViewStateConfiguration? get chatViewStateConfig =>
      widget.chatViewStateConfig;

  FeatureActiveConfig get featureActiveConfig => widget.featureActiveConfig;

  AppTheme theme = LightTheme();
  final GlobalKey _menuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setLocaleMessages('en', ReceiptsCustomMessages());
    // Adds current user in users list.
    chatController.chatUsers.add(widget.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    // Scroll to last message on in hasMessages state.
    // TODO: Remove this in new versions.
    // ignore: deprecated_member_use_from_same_package
    if (widget.showTypingIndicator ||
        widget.chatController.showTypingIndicator &&
            chatViewState.hasMessages) {
      chatController.scrollToLastMessage();
    }
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: ChatViewInheritedWidget(
        chatController: chatController,
        featureActiveConfig: featureActiveConfig,
        currentUser: widget.currentUser,
        child: Container(
          height:
              chatBackgroundConfig.height ?? MediaQuery.of(context).size.height,
          width:
              chatBackgroundConfig.width ?? MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: chatBackgroundConfig.backgroundColor ?? Colors.white,
            image: chatBackgroundConfig.backgroundImage != null
                ? DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(chatBackgroundConfig.backgroundImage!),
                  )
                : null,
          ),
          padding: chatBackgroundConfig.padding,
          margin: chatBackgroundConfig.margin,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    widget.ctx,
                    MaterialPageRoute(
                      builder: (ctx) => ChatMedia(
                        groupId: widget.groupId!,
                        teamId: widget.teamId,
                        projectId: widget.projectId,
                      ),
                    ),
                  );
                },
                child: ChatViewAppBar(
                  onBackPress: widget.onBackPress,
                  actions: widget.msgList
                              .where((element) => element.isSelected == true)
                              .length ==
                          0
                      ? [Container()]
                      : widget.msgList
                                  .where(
                                      (element) => element.isSelected == true)
                                  .length >
                              1
                          ? [
                              IconButton(
                                  onPressed: () {
                                    _onForwardTap();
                                  },
                                  icon: Icon(Icons.forward)),
                            ]
                          : appBarList(),
                  elevation: theme.elevation,
                  backGroundColor: theme.appBarColor,
                  backArrowColor: theme.backArrowColor,
                  chatTitle: widget.msgList
                          .any((element) => element.isSelected == true)
                      ? widget.msgList
                          .where((element) => element.isSelected == true)
                          .length
                          .toString()
                      : widget.teamName,
                  userStatus: widget.msgList
                          .any((element) => element.isSelected == true)
                      ? null
                      : "Click here for group info",
                  chatTitleTextStyle: TextStyle(
                    color: theme.appBarTitleTextStyle,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.25,
                  ),
                  userStatusTextStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    if (chatViewState.isLoading)
                      ChatViewStateWidget(
                        chatViewStateWidgetConfig:
                            chatViewStateConfig?.loadingWidgetConfig,
                        chatViewState: chatViewState,
                      )
                    else if (chatViewState.noMessages)
                      ChatViewStateWidget(
                        chatViewStateWidgetConfig:
                            chatViewStateConfig?.noMessageWidgetConfig,
                        chatViewState: chatViewState,
                        onReloadButtonTap:
                            chatViewStateConfig?.onReloadButtonTap,
                      )
                    else if (chatViewState.isError)
                      ChatViewStateWidget(
                        chatViewStateWidgetConfig:
                            chatViewStateConfig?.errorWidgetConfig,
                        chatViewState: chatViewState,
                        onReloadButtonTap:
                            chatViewStateConfig?.onReloadButtonTap,
                      )
                    else if (chatViewState.hasMessages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 70),
                        child: ValueListenableBuilder<ReplyMessage>(
                          valueListenable: replyMessage,
                          builder: (_, state, child) {
                            return ChatListWidget(
                              msgList: widget.msgList,
                              audioDownloadConfirmation:
                                  widget.audioDownloadConfirmation,

                              /// TODO: Remove this in future releases.
                              // ignore: deprecated_member_use_from_same_package
                              refreshCall: widget.refreshCall,

                              showTypingIndicator: widget.showTypingIndicator,
                              replyMessage: state,
                              chatController: widget.chatController,
                              chatBackgroundConfig: widget.chatBackgroundConfig,
                              reactionPopupConfig: widget.reactionPopupConfig,
                              typeIndicatorConfig: widget.typeIndicatorConfig,
                              chatBubbleConfig: widget.chatBubbleConfig,
                              loadMoreData: widget.loadMoreData,
                              isLastPage: widget.isLastPage,
                              replyPopupConfig: widget.replyPopupConfig,
                              loadingWidget: widget.loadingWidget,
                              messageConfig: widget.messageConfig,
                              profileCircleConfig: widget.profileCircleConfig,
                              repliedMessageConfig: widget.repliedMessageConfig,
                              swipeToReplyConfig: widget.swipeToReplyConfig,
                              onChatListTap: widget.onChatListTap,
                              onLongPressed: _onLongPressed,
                              onTap: _onLongPressed,
                              // onForwardTap: _onForwardTap,
                              assignReplyMessage: (message) => _sendMessageKey
                                  .currentState
                                  ?.assignReplyMessage(message),
                            );
                          },
                        ),
                      ),
                    if (featureActiveConfig.enableTextField)
                      SendMessageWidget(
                        userList: widget.userList,
                        key: _sendMessageKey,
                        chatController: chatController,
                        sendMessageBuilder: widget.sendMessageBuilder,
                        sendMessageConfig: widget.sendMessageConfig,
                        backgroundColor: chatBackgroundConfig.backgroundColor,
                        onSendTap: _onSendTap,
                        onReplyCallback: (reply) => replyMessage.value = reply,
                        onReplyCloseCallback: () =>
                            replyMessage.value = const ReplyMessage(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> appBarList() {
    return [
      IconButton(
          onPressed: () {
            _sendMessageKey.currentState?.assignReplyMessage(
                msgList.where((item) => item.isSelected == true).first);

            msgList
                .where((item) => item.isSelected == true)
                .forEach((item) => item.isSelected = false);
            setState(() {});
          },
          icon: Icon(Icons.reply)),
      IconButton(onPressed: widget.onDeleteTap, icon: Icon(Icons.delete)),
      IconButton(
          onPressed: () {
            _onForwardTap();
          },
          icon: Icon(Icons.forward)),
      PopupMenuButton(
          key: _menuKey,
          itemBuilder: (_) => (msgList
                      .where((element) =>
                          element.isSelected == true &&
                          element.messageType == MessageType.text)
                      .length >
                  0)
              ? const <PopupMenuItem<String>>[
                  PopupMenuItem<String>(child: Text('Copy'), value: 'Copy'),
                  PopupMenuItem<String>(child: Text('Info'), value: 'Info'),
                ]
              : const <PopupMenuItem<String>>[
                  PopupMenuItem<String>(child: Text('Info'), value: 'Info'),
                ],
          onSelected: (_) async {
            if (_ == "Copy") {
              var text = getCustomText(msgList
                  .where((item) => item.isSelected == true)
                  .first
                  .message);
              await Clipboard.setData(ClipboardData(text: text));

              ScaffoldMessenger.of(context).hideCurrentSnackBar();

              msgList
                  .where((item) => item.isSelected == true)
                  .forEach((item) => item.isSelected = false);
              setState(() {});
              AppUtils.showToastSuccess('Text copied to clipboard!');
            } else {
              widget.onMoreTap?.call();
            }
          })
    ];
  }

  getCustomText(message) {
    final regex = RegExp(r'##&&%(.*?)##&&%');
    const placeholder = '{@}';
    Iterable<Match> matches = regex.allMatches(message);
    List<String> target = [];
    List spans = [];
    for (Match match in matches) {
      target.add(match.group(1) ?? "");
    }
    final updatedString = message.replaceAll(regex, placeholder);
    final tokens = updatedString.split(RegExp(' '));

    var placeHolderindex = 0;
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == placeholder) {
        spans.add(target[placeHolderindex] + ' ');
        placeHolderindex = placeHolderindex + 1;
      } else {
        spans.add(tokens[i] + ' ');
      }
    }
    return spans.join("");
  }

  void _onForwardTap() {
    List<Message> messageList =
        msgList.where((item) => item.isSelected == true).toList();
    widget.onForwardTap?.call(messageList);
  }

  void _onLongPressed(message) {
    widget.onLongPressed?.call(message);
  }

  void _onSendTap(String message, ReplyMessage replyMessage,
      MessageType messageType, List<MultipartFile> files) {
    if (widget.sendMessageBuilder == null) {
      if (widget.onSendTap != null) {
        widget.onSendTap!(message, replyMessage, messageType, files);
      }
      _assignReplyMessage();
    }
    chatController.scrollToLastMessage();
  }

  void _assignReplyMessage() {
    if (replyMessage.value.message.isNotEmpty) {
      replyMessage.value = const ReplyMessage();
    }
  }

  @override
  void dispose() {
    replyMessage.dispose();
    super.dispose();
  }
}
