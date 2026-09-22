part of 'chat_screen_bloc.dart';

/// Command-style states (not Equatable).
abstract class ChatScreenState {
  const ChatScreenState();
}

class ChatInitial extends ChatScreenState {}

/// getChatUsers success — widget builds `chtusers` + `addMentionUsers` from
/// [data] (verbatim setState).
class ChatUsersLoaded extends ChatScreenState {
  final List<GroupChatUsersData> data;

  ChatUsersLoaded(this.data);
}

/// `group-users-list` socket payload — widget rebuilds `chtusers` +
/// `flutterMentionUserList` (verbatim setState).
class ChatGroupUsersSocket extends ChatScreenState {
  final dynamic data;

  ChatGroupUsersSocket(this.data);
}

/// `group-messages` socket payload — widget rebuilds `msgList` + `_chatController`
/// and sets `isloading=false` (verbatim setState).
class ChatGroupMessagesSocket extends ChatScreenState {
  final dynamic data;

  ChatGroupMessagesSocket(this.data);
}

/// deleteMessage success — widget unSelectList([]) + setState(toastSuccess +
/// joinGroup) + isSelectionEnabled=false.
class ChatDeleteOk extends ChatScreenState {
  final String message;

  ChatDeleteOk(this.message);
}

/// deleteMessage `status == false` — widget unSelectList([]) +
/// isSelectionEnabled=false.
class ChatDeleteFail extends ChatScreenState {}

/// deleteMessage `catchError` — widget dismisses + unSelectList([]).
class ChatDeleteError extends ChatScreenState {}

/// Widget: `AppUtils.showprogress()` (forward-list fetch start).
class ChatForwardListLoading extends ChatScreenState {}

/// fetchGroupList success — widget dismisses + `showListPopup(groups, messages)`
/// (messages held in a widget field).
class ChatForwardListLoaded extends ChatScreenState {
  final List<Data> groups;

  ChatForwardListLoaded(this.groups);
}

/// fetchGroupList `status == false` — widget dismisses + `showToastError(message)`.
class ChatForwardListFailed extends ChatScreenState {
  final String message;

  ChatForwardListFailed(this.message);
}

/// fetchGroupList `catchError` — widget dismisses + isSelectionEnabled=false +
/// `showToastError("Something went wrong!")`.
class ChatForwardListError extends ChatScreenState {}

/// getReadedUsers success — widget setState(`_readUsersList`) + unSelectList([])
/// + `showReadUsersDialog()`.
class ChatReadUsersLoaded extends ChatScreenState {
  final List<FetchMapedUsersData> data;

  ChatReadUsersLoaded(this.data);
}

/// getReadedUsers `status == false` — widget `showToastError(message)` +
/// unSelectList([]).
class ChatReadUsersFailed extends ChatScreenState {
  final String message;

  ChatReadUsersFailed(this.message);
}

/// getReadedUsers `catchError` — widget unSelectList([]) + `showToastError(message)`.
class ChatReadUsersError extends ChatScreenState {
  final String message;

  ChatReadUsersError(this.message);
}
