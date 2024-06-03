
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mta/ChatView/extensions/extensions.dart';

import '../chatview.dart';



class CustomImageView extends StatefulWidget {
  const CustomImageView({
    Key? key,
    required this.message,
    required this.isMessageBySender,
    this.imageMessageConfig,
    this.messageReactionConfig,
    this.highlightImage = false,
    this.highlightScale = 1.2,
  }) : super(key: key);

  /// Provides message instance of chat.
  final Message message;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration for image message appearance.
  final ImageMessageConfiguration? imageMessageConfig;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Represents flag of highlighting image when user taps on replied image.
  final bool highlightImage;

  /// Provides scale of highlighted image when user taps on replied image.
  final double highlightScale;

  String get imageUrl => message.message;

  



  @override
  State<CustomImageView> createState() => _CustomImageViewState();
}

class _CustomImageViewState extends State<CustomImageView> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          widget.isMessageBySender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => widget.imageMessageConfig?.onTap != null
                  ? widget.imageMessageConfig?.onTap!(widget.imageUrl)
                  : null,
              child: Transform.scale(
                scale: widget.highlightImage ? widget.highlightScale : 1.0,
                alignment: widget.isMessageBySender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  padding: widget.imageMessageConfig?.padding ?? EdgeInsets.zero,
                  margin: widget.imageMessageConfig?.margin ??
                      EdgeInsets.only(
                        top: 6,
                        right: widget.isMessageBySender ? 6 : 0,
                        left: widget.isMessageBySender ? 0 : 6,
                        bottom: widget.message.reaction.reactions.isNotEmpty ? 15 : 0,
                      ),
                  height: widget.imageMessageConfig?.height ?? 200,
                  width: widget.imageMessageConfig?.width ?? 150,
                  child: ClipRRect(
                    borderRadius: widget.imageMessageConfig?.borderRadius ??
                        BorderRadius.circular(14),
                    child: (() {
                      if (widget.imageUrl.isUrl) 
                      {
                        return Image.network(
                          widget.imageUrl,
                          fit: BoxFit.fitHeight,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        );
                      } 
                      else if (widget.imageUrl.fromMemory) {
                        return Image.memory(
                          base64Decode(widget.imageUrl
                              .substring(widget.imageUrl.indexOf('base64') + 7)),
                          fit: BoxFit.fill,
                        );
                      } else {
                        return Image.file(
                          File(widget.imageUrl),
                          fit: BoxFit.fill,
                        );
                      }
                    }()),
                  ),
                ),
              ),
            ),
            
          ],
        ),
      ],
    );
  }
}
