part of 'chat_groups_bloc.dart';

abstract class ChatGroupsEvent {
  const ChatGroupsEvent();
}

/// Load the group-creation access flag (mirrors `fetchChatCreateAcess()`).
class ChatGroupsAccessRequested extends ChatGroupsEvent {
  const ChatGroupsAccessRequested();
}

/// Create + connect the socket (mirrors `connectSocket()`).
class ChatGroupsConnect extends ChatGroupsEvent {
  final int? projectId;
  final int? teamId;

  const ChatGroupsConnect(this.projectId, this.teamId);
}

/// Internal: a group-list payload arrived on the `all-groups` socket event.
class ChatGroupsAllGroupsReceived extends ChatGroupsEvent {
  final dynamic data;

  const ChatGroupsAllGroupsReceived(this.data);
}

/// Validate a new group's name then open the add-users screen (mirrors
/// `createGroup()`); [req] built by the widget, [groupName] is the raw text.
class ChatGroupsCreateRequested extends ChatGroupsEvent {
  final GroupCreationReq req;
  final String groupName;

  const ChatGroupsCreateRequested(this.req, this.groupName);
}
