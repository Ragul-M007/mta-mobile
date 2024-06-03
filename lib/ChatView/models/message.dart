
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../chatview.dart';

class Message {
  /// Provides id
  final String id;

  /// Used for accessing widget's render box.
  final GlobalKey key;

  /// Provides actual message it will be text or image/audio file path.
  final String message;

  /// Provides message created date time.
  final DateTime createdAt;

  /// Provides id of sender of message.
  final String sendBy;

  /// Provides reply message if user triggers any reply on any message.
  final ReplyMessage replyMessage;

  /// Represents reaction on message.
  final Reaction reaction;

  /// Provides message type.
  final MessageType messageType;

  /// Status of the message.
  final ValueNotifier<MessageStatus> _status;

  /// Provides max duration for recorded voice message.
  Duration? voiceMessageDuration;

  String? fileName;

  Message({
    this.id = '',
    required this.message,
    required this.createdAt,
    required this.sendBy,
    this.replyMessage = const ReplyMessage(),
    Reaction? reaction,
    this.messageType = MessageType.text,
    this.voiceMessageDuration,
    this.fileName,
    MessageStatus status = MessageStatus.downloadPending,
  })  : reaction = reaction ?? Reaction(reactions: [], reactedUserIds: []),
        key = GlobalKey(),
        _status = ValueNotifier(status),
        assert(
          (messageType.isVoice
              ? ((defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.android))
              : true),
          "Voice messages are only supported with android and ios platform",
        );

  /// curret messageStatus
  MessageStatus get status => _status.value;

  /// For [MessageStatus] ValueNotfier which is used to for rebuilds
  /// when state changes.
  /// Using ValueNotfier to avoid usage of setState((){}) in order
  /// rerender messages with new receipts.
  ValueNotifier<MessageStatus> get statusNotifier => _status;

  /// This setter can be used to update message receipts, after which the configured
  /// builders will be updated.
  set setStatus(MessageStatus messageStatus) {
    _status.value = messageStatus;
  }

  factory Message.fromJson(Map<String, dynamic> json) => Message(
      fileName:json["file_name"],
      id: json["id"],
      message: json["message"],
      createdAt: json["createdAt"],
      sendBy: json["sendBy"],
      replyMessage: ReplyMessage.fromJson(json["reply_message"]),
      reaction: Reaction.fromJson(json["reaction"]),
      messageType: json["message_type"],
      voiceMessageDuration: json["voice_message_duration"],
      status: json['status']);

  Map<String, dynamic> toJson() => {
        'file_name':fileName,
        'id': id,
        'message': message,
        'createdAt': createdAt,
        'sendBy': sendBy,
        'reply_message': replyMessage.toJson(),
        'reaction': reaction.toJson(),
        'message_type': messageType,
        'voice_message_duration': voiceMessageDuration,
        'status': status.name
      };
}
