import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mta/ChatView/utils/package_strings.dart';

import '../values/typedefs.dart';

class ReplyPopupWidget extends StatelessWidget {
  const ReplyPopupWidget({
    Key? key,
    required this.sendByCurrentUser,
    required this.isCopyButtonEnabled,
    required this.onUnsendTap,
    required this.onReplyTap,
    required this.onForwardTap,
    required this.onCopyTap,
    required this.onReportTap,
    required this.onMoreTap,
    this.buttonTextStyle,
    this.topBorderColor,
  }) : super(key: key);

  /// Represents message is sent by current user or not.
  final bool sendByCurrentUser;

  /// Checks message type is text or not to enable copy button.
  final bool isCopyButtonEnabled;

  /// Provides call back when user tap on unsend button.
  final VoidCallBack onUnsendTap;

  /// Provides call back when user tap on reply button.
  final VoidCallBack onReplyTap;

  /// Provides call back when user tap on reply button.
  final VoidCallBack onForwardTap;

  /// Provides call back when user tap on copy button.
  final VoidCallBack onCopyTap;

  /// Provides call back when user tap on report button.
  final VoidCallBack onReportTap;

  /// Provides call back when user tap on more button.
  final VoidCallBack onMoreTap;

  /// Allow user to set text style of button are showed in reply snack bar.
  final TextStyle? buttonTextStyle;

  /// Allow user to set color of top border of reply snack bar.
  final Color? topBorderColor;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        buttonTextStyle ?? const TextStyle(fontSize: 14, color: Colors.black);
    final deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      height: deviceWidth > 500
          ? deviceWidth * 0.15
          : isCopyButtonEnabled
              ? deviceWidth * 0.53
              : deviceWidth * 0.43,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        border: Border(
            top: BorderSide(
                color: topBorderColor ?? Colors.grey.shade400, width: 1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onReplyTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10),
              child: Row(
                children: [
                  Icon(Icons.reply_rounded),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: onReplyTap,
                    child: Text(
                      PackageStrings.reply,
                      style: textStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCopyButtonEnabled)
            GestureDetector(
              onTap: onCopyTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 10, top: 0),
                child: Row(
                  children: [
                    Icon(Icons.content_copy),
                    SizedBox(width: 5),
                    InkWell(
                      onTap: onCopyTap,
                      child: Text(
                        PackageStrings.copy,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (sendByCurrentUser)
            GestureDetector(
              onTap: onUnsendTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      onTap: onUnsendTap,
                      child: Text(
                        PackageStrings.unsend,
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          GestureDetector(
            onTap: onForwardTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10, top: 0),
              child: Row(
                children: [
                  Icon(Icons.forward),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: onForwardTap,
                    child: Text(
                      PackageStrings.forward,
                      style: textStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onMoreTap,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.info_rounded),
                  SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: onMoreTap,
                    child: Text(
                      PackageStrings.info,
                      style: textStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
