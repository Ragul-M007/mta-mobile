part of 'add_users_bloc.dart';

abstract class AddUsersEvent {
  const AddUsersEvent();
}

/// Create + connect the socket (mirrors the IO.io setup in initState()).
class AddUsersSocketInit extends AddUsersEvent {
  final int? groupId;
  final int? projectId;
  final int? teamId;

  const AddUsersSocketInit(this.groupId, this.projectId, this.teamId);
}

/// Load the selectable users (mirrors `getUnlinkUsersByGroupId()`).
class AddUsersLoadRequested extends AddUsersEvent {
  final bool? fromCreateGroup;
  final int? groupId;
  final int? projectId;
  final int? teamId;

  const AddUsersLoadRequested(
      this.fromCreateGroup, this.groupId, this.projectId, this.teamId);
}

/// Submit the selection (mirrors `updateSelectedUsers()`): either createGroup
/// (then emit add-users) or emit add-users directly. [selectedUsers] built by
/// the widget.
class AddUsersSubmitRequested extends AddUsersEvent {
  final bool? fromCreateGroup;
  final GroupCreationReq? groupData;
  final List<int> selectedUsers;

  const AddUsersSubmitRequested(
      this.fromCreateGroup, this.groupData, this.selectedUsers);
}
