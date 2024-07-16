import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mta/ChatView/extensions/extensions.dart';
import 'package:mta/ChatView/widgets/chat_view_inherited_widget.dart';
import 'package:provider/provider.dart';

import '../../../../network/ApiService.dart';
import '../../../../utilities/apputilities.dart';
import '../../../../utilities/strings.dart';
import '../chatview.dart';
import '../utils/constants/constants.dart';
import 'image_message_view.dart';
import 'text_message_view.dart';
import 'voice_message_view.dart';

class MessageView extends StatefulWidget {
  const MessageView(
      {Key? key,
      required this.message,
      required this.isMessageBySender,
      required this.onLongPress,
      required this.onTap,
      required this.onSelectionTapped,
      required this.isLongPressEnable,
      this.fileName,
      this.chatBubbleMaxWidth,
      this.inComingChatBubbleConfig,
      this.outgoingChatBubbleConfig,
      this.longPressAnimationDuration,
      this.onDoubleTap,
      this.highlightColor = Colors.grey,
      this.shouldHighlight = false,
      this.highlightScale = 1.2,
      this.messageConfig,
      this.onMaxDuration,
      this.controller,
      this.audioDownloadConfirmation})
      : super(key: key);

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Give callback once user long press on chat bubble.
  final DoubleCallBack onLongPress;

  final VoidCallBack onTap;

  final VoidCallBack onSelectionTapped;

  /// Allow users to give max width of chat bubble.
  final double? chatBubbleMaxWidth;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  /// Allow users to give duration of animation when user long press on chat bubble.
  final Duration? longPressAnimationDuration;

  /// Allow user to set some action when user double tap on chat bubble.
  final MessageCallBack? onDoubleTap;

  /// Allow users to pass colour of chat bubble when user taps on replied message.
  final Color highlightColor;

  /// Allow users to turn on/off highlighting chat bubble when user tap on replied message.
  final bool shouldHighlight;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  /// Allow user to giving customisation different types
  /// messages.
  final MessageConfiguration? messageConfig;

  /// Allow user to turn on/off long press tap on chat bubble.
  final bool isLongPressEnable;

  final ChatController? controller;

  final Function(int)? onMaxDuration;
  final Function()? audioDownloadConfirmation;

  final String? fileName;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  MessageConfiguration? get messageConfig => widget.messageConfig;
  var downloadStatus;

  bool get isLongPressEnable => widget.isLongPressEnable;
  var dio = Dio();

  @override
  void initState() {
    super.initState();
    downloadStatus = widget.message.status;
    if (isLongPressEnable) {
      _animationController = AnimationController(
        vsync: this,
        duration: widget.longPressAnimationDuration ??
            const Duration(milliseconds: 250),
        upperBound: 0.1,
        lowerBound: 0.0,
      );
      if (widget.message.status != MessageStatus.read &&
          !widget.isMessageBySender) {
        widget.inComingChatBubbleConfig?.onMessageRead?.call(widget.message);
      }
      _animationController?.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController?.reverse();
        }
      });
    }
  }

  downloadAudio() {
    downloadfile(widget.message.message, widget.message.fileName);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: isLongPressEnable ? _onLongPressStart : null,
      onTap: widget.onTap,
      onDoubleTap: () {
        if (widget.onDoubleTap != null) widget.onDoubleTap!(widget.message);
      },
      child: (() {
        if (isLongPressEnable) {
          return AnimatedBuilder(
            builder: (_, __) {
              return Transform.scale(
                scale: 1 - _animationController!.value,
                child: _messageView,
              );
            },
            animation: _animationController!,
          );
        } else {}
      }()),
    );
  }

  Widget get _messageView {
    print("message view ${downloadStatus}  ${widget.message.createdAt}");
    final message = widget.message.message;
    final emojiMessageConfiguration = messageConfig?.emojiMessageConfig;
    return Padding(
      padding: EdgeInsets.only(
        bottom: widget.message.reaction.reactions.isNotEmpty ? 6 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          (() {
                if (message.isAllEmoji) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: emojiMessageConfiguration?.padding ??
                            EdgeInsets.fromLTRB(
                              leftPadding2,
                              4,
                              leftPadding2,
                              widget.message.reaction.reactions.isNotEmpty
                                  ? 14
                                  : 0,
                            ),
                        child: Transform.scale(
                          scale: widget.shouldHighlight
                              ? widget.highlightScale
                              : 1.0,
                          child: Text(
                            message,
                            style: emojiMessageConfiguration?.textStyle ??
                                const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (widget.message.messageType.isImage) {
                  return ImageMessageView(
                    message: widget.message,
                    isMessageBySender: widget.isMessageBySender,
                    imageMessageConfig: messageConfig?.imageMessageConfig,
                    messageReactionConfig: messageConfig?.messageReactionConfig,
                    highlightImage: widget.shouldHighlight,
                    highlightScale: widget.highlightScale,
                    onSelectionTapped: widget.onSelectionTapped,
                  );
                } else if (widget.message.messageType.isText) {
                  return TextMessageView(
                    inComingChatBubbleConfig: widget.inComingChatBubbleConfig,
                    outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
                    isMessageBySender: widget.isMessageBySender,
                    message: widget.message,
                    chatBubbleMaxWidth: widget.chatBubbleMaxWidth,
                    messageReactionConfig: messageConfig?.messageReactionConfig,
                    highlightColor: widget.highlightColor,
                    highlightMessage: widget.shouldHighlight,
                  );
                } else if (widget.message.messageType.isVoice) {
                  print(
                      "message view11 $downloadStatus ${widget.message.createdAt}");
                  return VoiceMessageView(
                    parentDownloadStatus: downloadStatus,
                    fileName: widget.fileName,
                    screenWidth: MediaQuery.of(context).size.width,
                    message: widget.message,
                    config: messageConfig?.voiceMessageConfig,
                    onMaxDuration: widget.onMaxDuration,
                    isMessageBySender: widget.isMessageBySender,
                    messageReactionConfig: messageConfig?.messageReactionConfig,
                    inComingChatBubbleConfig: widget.inComingChatBubbleConfig,
                    outgoingChatBubbleConfig: widget.outgoingChatBubbleConfig,
                    downloadAudioRequest: downloadAudio,
                    onSelectionTapped: widget.onSelectionTapped,
                  );
                } else if (widget.message.messageType.isCustom &&
                    messageConfig?.customMessageBuilder != null) {
                  return messageConfig?.customMessageBuilder!(widget.message);
                }
              }()) ??
              const SizedBox(),
          ValueListenableBuilder(
            valueListenable: widget.message.statusNotifier,
            builder: (context, value, child) {
              if (widget.isMessageBySender &&
                  widget.controller?.initialMessageList.last.id ==
                      widget.message.id &&
                  widget.message.status == MessageStatus.read) {
                if (ChatViewInheritedWidget.of(context)
                        ?.featureActiveConfig
                        .lastSeenAgoBuilderVisibility ??
                    true) {
                  return widget.outgoingChatBubbleConfig?.receiptsWidgetConfig
                          ?.lastSeenAgoBuilder
                          ?.call(
                              widget.message,
                              applicationDateFormatter(
                                  widget.message.createdAt)) ??
                      lastSeenAgoBuilder(widget.message,
                          applicationDateFormatter(widget.message.createdAt));
                }
                return const SizedBox();
              }
              return const SizedBox();
            },
          )
        ],
      ),
    );
  }

  downloadfile(
    serverURL,
    filename,
  ) async {
    // AppUtils.showprogress();
    // AppUtils.showToast('Downloading');

    //var fileName = filename;//filenames[1];
    var extn = AppUtils.getFileExtension(serverURL);
    var nospace = filename.replaceAll(' ', '');
    var fileName = nospace + extn;
    print("url--> $fileName");
    var basePath = Strings.basePath;

    String fullPath = "$basePath/$fileName";
    print("filepath $fullPath");

    var downloadedFile = await download2(dio, serverURL, '$basePath/$fileName');

    // setState(() {
    //      initializePlayer(downloadedFile);
    // });
    // initState();
    // var downloadedFile = await downloadFile(serverURL, fileName, path!);
    //AppUtils.openFile(downloadedFile);
  }

  Future download2(Dio dio, String url, String savePath) async {
    try {
      var myUrl = url;
      Response response = await dio.get(
        myUrl,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      print(response.headers);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
      var filePath;
      if (response.statusCode == 200) {
        AppUtils.dismissprogress();
        filePath = savePath;
        file = File(filePath);
        updateDownloadStatus(int.parse(widget.message.id), context);

        setState(() {
          downloadStatus = MessageStatus.downloaded;
        });
      } else if (response.statusCode == 404) {
        AppUtils.dismissprogress();
        AppUtils.showToastError("Sorry, File  not Found !");
      } else {
        AppUtils.dismissprogress();
        filePath = 'Error code: ' + response.statusCode.toString();
      }
      return filePath;
    } catch (e) {
      AppUtils.dismissprogress();
      var filePath = 'Error $e';
      print(e);
      return filePath;
    }
  }

  updateDownloadStatus(msgId, context) async {
    final api = Provider.of<ApiService>(context, listen: false);
    api.updateDownloadStatus(msgId, 1).then((response) {
      print("response ${response.status}");
      if (response.status == true) {
        print("truee downloaded");
        widget.audioDownloadConfirmation!();

        // AppUtils.showToastError("update status successfully");
      } else {
        AppUtils.dismissprogress();
        AppUtils.showToastError(response.message!);
      }
    }).catchError((onError) {
      AppUtils.dismissprogress();
      AppUtils.showToastError("Unable to connect to server");
      print(onError.toString());
    });
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      AppUtils.showprogresswithpercent(received / total);
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

  void _onLongPressStart(LongPressStartDetails details) async {
    await _animationController?.forward();
    widget.onLongPress(
      details.globalPosition.dy - 120 - 64,
      details.globalPosition.dx,
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
