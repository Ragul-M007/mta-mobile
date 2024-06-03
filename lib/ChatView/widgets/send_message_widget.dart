
import 'dart:io' if (kIsWeb) 'dart:html';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mta/ChatView/extensions/extensions.dart';
import 'package:mta/ChatView/widgets/chatui_textfield.dart';

import '../../../../screens/MentionFiles/flutter_mentions.dart';
import '../controller/chat_controller.dart';
import '../models/models.dart';
import '../utils/constants/constants.dart';
import '../utils/package_strings.dart';
import '../values/enumaration.dart';
import '../values/typedefs.dart';

class SendMessageWidget extends StatefulWidget {
  const SendMessageWidget({
    Key? key,
    required this.onSendTap,
    required this.chatController,
    this.sendMessageConfig,
    this.backgroundColor,
    this.sendMessageBuilder,
    this.onReplyCallback,
    this.userList,
    this.onReplyCloseCallback,
  }) : super(key: key);

  /// Provides call back when user tap on send button on text field.
  final ListCallBack onSendTap;

  /// Provides configuration for text field appearance.
  final SendMessageConfiguration? sendMessageConfig;

  /// Allow user to set background colour.
  final Color? backgroundColor;

  /// Allow user to set custom text field.
  final ReplyMessageWithReturnWidget? sendMessageBuilder;

  /// Provides callback when user swipes chat bubble for reply.
  final ReplyMessageCallBack? onReplyCallback;

  /// Provides call when user tap on close button which is showed in reply pop-up.
  final VoidCallBack? onReplyCloseCallback;

  /// Provides controller for accessing few function for running chat.
  final ChatController chatController;
  
  final List<Map<String, dynamic>>? userList;


  @override
  State<SendMessageWidget> createState() => SendMessageWidgetState();
}

class SendMessageWidgetState extends State<SendMessageWidget> {
  final _textEditingKey = GlobalKey<FlutterMentionsState>();
  final _textEditingController = TextEditingController();
  final ValueNotifier<ReplyMessage> _replyMessage =
      ValueNotifier(const ReplyMessage());

  ReplyMessage get replyMessage => _replyMessage.value;
  final _focusNode = FocusNode();

  ChatUser? get repliedUser => replyMessage.replyTo.isNotEmpty
      ? widget.chatController.getUserFromId(replyMessage.replyTo)
      : null;

  String get _replyTo => replyMessage.replyTo == currentUser?.id
      ? PackageStrings.you
      : repliedUser?.name ?? '';

  ChatUser? currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      currentUser = provide!.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    final replyTitle = "${PackageStrings.replyTo} $_replyTo";
    return widget.sendMessageBuilder != null
        ? Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: widget.sendMessageBuilder!(replyMessage),
          )
        : Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height /
                          ((!kIsWeb && Platform.isIOS) ? 24 : 28),
                      color: widget.backgroundColor ?? Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      bottomPadding4,
                      bottomPadding4,
                      bottomPadding4,
                      _bottomPadding,
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ValueListenableBuilder<ReplyMessage>(
                          builder: (_, state, child) {
                            if (state.message.isNotEmpty) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: widget.sendMessageConfig
                                          ?.textFieldBackgroundColor ??
                                      Colors.white,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(14),
                                  ),
                                ),
                                margin: const EdgeInsets.only(
                                  bottom: 17,
                                  right: 0.4,
                                  left: 0.4,
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  leftPadding,
                                  leftPadding,
                                  leftPadding,
                                  30,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 2),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.sendMessageConfig
                                            ?.replyDialogColor ??
                                        Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            replyTitle,
                                            style: TextStyle(
                                              color: widget.sendMessageConfig
                                                      ?.replyTitleColor ??
                                                  Colors.deepPurple,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.25,
                                            ),
                                          ),
                                          IconButton(
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              Icons.close,
                                              color: widget.sendMessageConfig
                                                      ?.closeIconColor ??
                                                  Colors.black,
                                              size: 16,
                                            ),
                                            onPressed: _onCloseTap,
                                          ),
                                        ],
                                      ),
                                      if (state.messageType.isVoice)
                                        _voiceReplyMessageView
                                      else if (state.messageType.isImage)
                                        _imageReplyMessageView
                                      else
                                      Text.rich(TextSpan(
                                      children: customizeText(
                                          state.message),    style:TextStyle(
                                            fontSize: 12,
                                            color: widget.sendMessageConfig
                                                    ?.replyMessageColor ??
                                                Colors.black,
                                          ),)
                            )
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                          valueListenable: _replyMessage,
                        ),
                        ChatUITextField(
                          userList: widget.userList,
                          textEditingKey:_textEditingKey,
                          focusNode: _focusNode,
                          textEditingController: _textEditingController,
                          onPressed: _onPressed,
                          sendMessageConfig: widget.sendMessageConfig,
                          onRecordingComplete: _onRecordingComplete,
                          onImageSelected: _onImageSelected,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  List<InlineSpan> customizeText(String text) 
  {
    // final regex = RegExp('\'.+\'');
    // final target = regex.stringMatch(testString)!;
    List<InlineSpan> spans = [];

    final regex = RegExp(r'##&&%(.*?)##&&%');
    const placeholder = '{@}';

    Iterable<Match> matches = regex.allMatches(text);
    List<String> target = [];

    for (Match match in matches) {
      // match.group(1) contains the content inside the ##&&% sequence
      target.add(match.group(1) ?? "");
    }

    // final target = regex.allMatches(text);
    final updatedString = text.replaceAll(regex, placeholder);
    final tokens = updatedString.split(RegExp(' '));
    var placeHolderindex = 0;
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == placeholder) {
        spans.add(TextSpan(
            text: target[placeHolderindex] + ' ',
            style: const TextStyle(color: Color.fromARGB(255, 97, 136, 243))));
        placeHolderindex = placeHolderindex + 1;
      } else {
        spans.add(TextSpan(text: tokens[i] + ' '));
      }
    }

    // spans = tokens.map((e) => e == placeholder
    // ? TextSpan(text: target[target.indexOf(e)+1] + ' ', style: const TextStyle(color: Colors.blue))
    // : TextSpan(text: e + ' '))
    // .toList();

    return spans;
  }

  Widget get _voiceReplyMessageView {
    return Row(
      children: [
        Icon(
          Icons.mic,
          color: widget.sendMessageConfig?.micIconColor,
        ),
        const SizedBox(width: 4),
        if (replyMessage.voiceMessageDuration != null)
          Text(
            replyMessage.voiceMessageDuration!.toHHMMSS(),
            style: TextStyle(
              fontSize: 12,
              color:
                  widget.sendMessageConfig?.replyMessageColor ?? Colors.black,
            ),
          ),
      ],
    );
  }

  Widget get _imageReplyMessageView {
    return Row(
      children: [
        Icon(
          Icons.file_copy_rounded,
          size: 20,
          color: widget.sendMessageConfig?.replyMessageColor ??
              Colors.grey.shade700,
        ),
        Text(
          PackageStrings.photo,
          style: TextStyle(
            color: widget.sendMessageConfig?.replyMessageColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  void _onRecordingComplete(String? path) {
    if (path != null) {
      widget.onSendTap.call(path, replyMessage, MessageType.voice,[]);
      _assignRepliedMessage();
    }
  }

  void _onImageSelected(String error,ReplyMessage replyMsg,MessageType typ,List<MultipartFile> imagePath, ) 
  {
    debugPrint('Call in Send Message Widget');
    if (imagePath.isNotEmpty) 
    {
      widget.onSendTap.call(error, replyMessage, MessageType.image,imagePath);
      _assignRepliedMessage();
    }
  }

  void _assignRepliedMessage() {
    if (replyMessage.message.isNotEmpty) {
      _replyMessage.value = const ReplyMessage();
    }
  }

  void _onPressed() {
    print("typed valll ${_textEditingKey.currentState!.controller!.markupText}");
    if (_textEditingKey.currentState!.controller!.markupText.isNotEmpty &&
        !_textEditingKey.currentState!.controller!.markupText.startsWith('\n')) {
      widget.onSendTap.call(
        _textEditingKey.currentState!.controller!.markupText.trim(),
        replyMessage,
        MessageType.text,[]
      );
      _assignRepliedMessage();
      _textEditingKey.currentState!.controller!.clear();
      _textEditingController.clear();
    }
  }

  void assignReplyMessage(Message message) {
    if (currentUser != null) {
      _replyMessage.value = ReplyMessage(
        message: message.message,
        replyBy: currentUser!.id,
        replyTo: message.sendBy,
        messageType: message.messageType,
        messageId: message.id,
        voiceMessageDuration: message.voiceMessageDuration,
      );
    }
    FocusScope.of(context).requestFocus(_focusNode);
    if (widget.onReplyCallback != null) widget.onReplyCallback!(replyMessage);
  }

  void _onCloseTap() {
    _replyMessage.value = const ReplyMessage();
    if (widget.onReplyCloseCallback != null) widget.onReplyCloseCallback!();
  }

  double get _bottomPadding => (!kIsWeb && Platform.isIOS)
      ? (_focusNode.hasFocus
          ? bottomPadding1
          : View.of(context).viewPadding.bottom > 0
              ? bottomPadding2
              : bottomPadding3)
      : bottomPadding3;

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    _replyMessage.dispose();
    super.dispose();
  }
}
