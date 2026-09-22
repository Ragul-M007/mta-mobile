part of 'chat_groups_bloc.dart';

/// Command-style states (not Equatable).
abstract class ChatGroupsState {
  const ChatGroupsState();
}

class ChatGroupsInitial extends ChatGroupsState {}

/// getAccessDetails success — widget setState(`Strings.groupCreationAccess`).
class ChatGroupsAccessLoaded extends ChatGroupsState {
  final int? groupCreateAccess;

  ChatGroupsAccessLoaded(this.groupCreateAccess);
}

/// `all-groups` matched this team/project — widget setState(`groupList` = items,
/// `loading` = false).
class ChatGroupsLoaded extends ChatGroupsState {
  final List<GroupDetails> items;

  ChatGroupsLoaded(this.items);
}

/// `all-groups` did not match — widget setState(`loading` = false) only.
class ChatGroupsLoadedNoMatch extends ChatGroupsState {}

/// Widget: `AppUtils.showprogress()` (createGroup start).
class ChatGroupsCreateLoading extends ChatGroupsState {}

/// checkGroupName success — widget dismisses, clears the fields, pops the
/// dialog, and pushes the add-users screen with [req]
/// (`.whenComplete(connectSocket)`).
class ChatGroupsCreateOk extends ChatGroupsState {
  final GroupCreationReq req;

  ChatGroupsCreateOk(this.req);
}

/// checkGroupName `status == false` — widget dismisses + `showToastError(message)`.
class ChatGroupsCreateFailed extends ChatGroupsState {
  final String message;

  ChatGroupsCreateFailed(this.message);
}

/// checkGroupName `catchError` — widget dismisses + `showToastError(message)`.
class ChatGroupsCreateError extends ChatGroupsState {
  final String message;

  ChatGroupsCreateError(this.message);
}
