import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:mta/ChatView/extensions/extensions.dart';
import 'package:mta/ChatView/utils/package_strings.dart';

import '../../../../utilities/apputilities.dart';
import '../models/message.dart';
import '../models/models.dart';
import '../utils/constants/constants.dart';
import 'chat_view_inherited_widget.dart';
import 'vertical_line.dart';

class ReplyMessageWidget extends StatelessWidget {
  const ReplyMessageWidget({
    Key? key,
    required this.message,
    this.repliedMessageConfig,
    this.onTap,
  }) : super(key: key);

  /// Provides message instance of chat.
  final Message message;

  /// Provides configurations related to replied message such as textstyle
  /// padding, margin etc. Also, this widget is located upon chat bubble.
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides call back when user taps on replied message.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentUser = ChatViewInheritedWidget.of(context)?.currentUser;
    final replyBySender = message.replyMessage.replyBy == currentUser?.id;
    final textTheme = Theme.of(context).textTheme;
    final replyMessage = message.replyMessage.message;
    final chatController = ChatViewInheritedWidget.of(context)?.chatController;
    final messagedUser =
        chatController?.getUserFromId(message.replyMessage.replyBy);
    final replyBy = replyBySender ? PackageStrings.you : messagedUser?.name;

    print("replyyy $replyMessage");
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: repliedMessageConfig?.margin ??
            const EdgeInsets.only(
              right: horizontalPadding,
              left: horizontalPadding,
              bottom: 4,
            ),
        constraints:
            BoxConstraints(maxWidth: repliedMessageConfig?.maxWidth ?? 280),
        child: Column(
          crossAxisAlignment:
              replyBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              "${PackageStrings.repliedBy} $replyBy",
              style: repliedMessageConfig?.replyTitleTextStyle ??
                  textTheme.bodyMedium!
                      .copyWith(fontSize: 14, letterSpacing: 0.3),
            ),
            const SizedBox(height: 6),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: replyBySender
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!replyBySender)
                    VerticalLine(
                      verticalBarWidth: repliedMessageConfig?.verticalBarWidth,
                      verticalBarColor: repliedMessageConfig?.verticalBarColor,
                      rightPadding: 4,
                    ),
                  Flexible(
                    child: Opacity(
                      opacity: repliedMessageConfig?.opacity ?? 0.8,
                      child: message.replyMessage.messageType.isImage
                          ? (replyMessage.isUrl &&
                                  (replyMessage.contains('.png') ||
                                      replyMessage.contains('.jpeg') ||
                                      replyMessage.contains('.jpg')))
                              ? Container(
                                  height: repliedMessageConfig
                                          ?.repliedImageMessageHeight ??
                                      100,
                                  width: repliedMessageConfig
                                          ?.repliedImageMessageWidth ??
                                      80,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(replyMessage),
                                      fit: BoxFit.fill,
                                    ),
                                    borderRadius:
                                        repliedMessageConfig?.borderRadius ??
                                            BorderRadius.circular(14),
                                  ),
                                )
                              : Container(
                                  height: repliedMessageConfig
                                          ?.repliedImageMessageHeight ??
                                      100,
                                  width: repliedMessageConfig
                                          ?.repliedImageMessageWidth ??
                                      80,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          AppUtils.getFileExt(replyMessage)),
                                      fit: BoxFit.fill,
                                    ),
                                    borderRadius:
                                        repliedMessageConfig?.borderRadius ??
                                            BorderRadius.circular(14),
                                  ),
                                )
                          : Container(
                              constraints: BoxConstraints(
                                maxWidth: repliedMessageConfig?.maxWidth ?? 280,
                              ),
                              padding: repliedMessageConfig?.padding ??
                                  const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                              decoration: BoxDecoration(
                                  borderRadius: _borderRadius(
                                    replyMessage: replyMessage,
                                    replyBySender: replyBySender,
                                  ),
                                  color: Color.fromARGB(255, 2, 32, 93)),
                              child: message.replyMessage.messageType.isVoice
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.mic,
                                          color: repliedMessageConfig
                                                  ?.micIconColor ??
                                              Colors.white,
                                        ),
                                        const SizedBox(width: 2),
                                        if (message.replyMessage
                                                .voiceMessageDuration !=
                                            null)
                                          Text(
                                            message.replyMessage
                                                .voiceMessageDuration!
                                                .toHHMMSS(),
                                            style:
                                                repliedMessageConfig?.textStyle,
                                          ),
                                      ],
                                    )
                                  : Text.rich(TextSpan(
                                      children: customizeText(replyMessage),
                                      style: repliedMessageConfig?.textStyle ??
                                          textTheme.bodyMedium!
                                              .copyWith(color: Colors.black) ??
                                          textTheme.bodyMedium!.copyWith(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                    )),
                            ),
                    ),
                  ),
                  if (replyBySender)
                    VerticalLine(
                      verticalBarWidth: repliedMessageConfig?.verticalBarWidth,
                      verticalBarColor: repliedMessageConfig?.verticalBarColor,
                      leftPadding: 4,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> customizeText(String text) {
    // final regex = RegExp('\'.+\'');
    // final target = regex.stringMatch(testString)!;
    List<InlineSpan> spans = [];

    final regex = RegExp(r'##&&%(.*?)##&&%');
    const placeholder = '{@}';

    Iterable<Match> matches = regex.allMatches(text);
    List<String> target = [];

    for (Match match in matches) {
      // match.group(1) contains the content inside the ##&&% sequence
      print('Content: ${match.group(1)}');
      target.add(match.group(1) ?? "");
    }

    // final target = regex.allMatches(text);
    final updatedString = text.replaceAll(regex, placeholder);
    final tokens = updatedString.split(RegExp(' '));

    print("tokenssss $tokens");

    var placeHolderindex = 0;
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == placeholder) {
        print("iiu $placeHolderindex klklkl ${target[placeHolderindex]}");
        spans.add(TextSpan(
            text: target[placeHolderindex] + ' ',
            style: const TextStyle(
                color: Color.fromARGB(255, 134, 240, 41),
                fontWeight: FontWeight.w600)));
        placeHolderindex = placeHolderindex + 1;
      } else {
        print("adding ${tokens[i]}");
        spans.add(TextSpan(text: tokens[i] + ' '));
      }
    }

    // spans = tokens.map((e) => e == placeholder
    // ? TextSpan(text: target[target.indexOf(e)+1] + ' ', style: const TextStyle(color: Colors.blue))
    // : TextSpan(text: e + ' '))
    // .toList();

    return spans;
  }

  BorderRadiusGeometry _borderRadius({
    required String replyMessage,
    required bool replyBySender,
  }) =>
      replyBySender
          ? repliedMessageConfig?.borderRadius ??
              (replyMessage.length < 37
                  ? BorderRadius.circular(replyBorderRadius1)
                  : BorderRadius.circular(replyBorderRadius2))
          : repliedMessageConfig?.borderRadius ??
              (replyMessage.length < 29
                  ? BorderRadius.circular(replyBorderRadius1)
                  : BorderRadius.circular(replyBorderRadius2));
}
