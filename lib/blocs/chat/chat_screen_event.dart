part of 'chat_screen_bloc.dart';

abstract class ChatScreenEvent {
  const ChatScreenEvent();
}

/// Create + connect the socket (mirrors the IO.io setup in initState()).
class ChatSocketInit extends ChatScreenEvent {
  final int? groupId;
  final int? projectId;
  final int? teamId;

  const ChatSocketInit(this.groupId, this.projectId, this.teamId);
}

/// Join the group (mirrors `joinGroup()`): emit join-group +
/// update-message-readed-user and (re)register the message/user-list handlers.
class ChatJoinRequested extends ChatScreenEvent {
  const ChatJoinRequested();
}

/// Load the group's chat users (mirrors `getUsersByGroupId()`).
class ChatUsersRequested extends ChatScreenEvent {
  final int groupId;

  const ChatUsersRequested(this.groupId);
}

/// Delete a message (mirrors `deleteMessagesById()`).
class ChatDeleteRequested extends ChatScreenEvent {
  final int msgId;
  final int grpId;

  const ChatDeleteRequested(this.msgId, this.grpId);
}

/// Send a text message (mirrors `updateChat()` — emit `create-message`).
class ChatSendText extends ChatScreenEvent {
  final String msg;
  final dynamic parentMsgId;

  const ChatSendText(this.msg, this.parentMsgId);
}

/// Forward selected messages (mirrors `updateForwardMessage()` — emit
/// `forward-message`); the widget computed [documentIds] from the messages.
class ChatForwardEmit extends ChatScreenEvent {
  final List<int> documentIds;
  final List<int> receiverGroupIds;

  const ChatForwardEmit(this.documentIds, this.receiverGroupIds);
}

/// Fetch the group list for the forward popup (mirrors the fetchGroupList call
/// in `_onForwardTap()`).
class ChatForwardListRequested extends ChatScreenEvent {
  final GroupReq req;

  const ChatForwardListRequested(this.req);
}

/// Fetch the read-receipt users (mirrors `getReadUsers()`).
class ChatReadUsersRequested extends ChatScreenEvent {
  final dynamic msgID;

  const ChatReadUsersRequested(this.msgID);
}

/// Upload a file/audio message (mirrors `uploadFile()`); [formData] built by
/// the widget.
class ChatUploadRequested extends ChatScreenEvent {
  final dynamic formData;

  const ChatUploadRequested(this.formData);
}

/// Internal: a `group-users-list` payload arrived on the socket.
class ChatGroupUsersReceived extends ChatScreenEvent {
  final dynamic data;

  const ChatGroupUsersReceived(this.data);
}

/// Internal: a `group-messages` payload arrived on the socket.
class ChatGroupMessagesReceived extends ChatScreenEvent {
  final dynamic data;

  const ChatGroupMessagesReceived(this.data);
}
