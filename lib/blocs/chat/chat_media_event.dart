part of 'chat_media_bloc.dart';

abstract class ChatMediaEvent {
  const ChatMediaEvent();
}

/// Load media of a [type] ("image"/"video"/"document") — mirrors
/// `getDocumentDetails(type)`.
class ChatMediaDocsRequested extends ChatMediaEvent {
  final int groupId;
  final String type;

  const ChatMediaDocsRequested(this.groupId, this.type);
}

/// Load the group's chat users — mirrors `getUsersByGroupId()`.
class ChatMediaUsersRequested extends ChatMediaEvent {
  final int groupId;

  const ChatMediaUsersRequested(this.groupId);
}

/// Load the group metadata — mirrors `getGroupData()`.
class ChatMediaGroupDataRequested extends ChatMediaEvent {
  final int groupId;

  const ChatMediaGroupDataRequested(this.groupId);
}

/// Delete the group — mirrors `deleteGroup()`.
class ChatMediaDeleteGroupRequested extends ChatMediaEvent {
  final int groupId;

  const ChatMediaDeleteGroupRequested(this.groupId);
}
