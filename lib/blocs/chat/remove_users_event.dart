part of 'remove_users_bloc.dart';

abstract class RemoveUsersEvent {
  const RemoveUsersEvent();
}

/// Load the group's chat users (mirrors `getUsersByGroupId()`); [groupId] is
/// `widget.groupId`.
class RemoveUsersLoadRequested extends RemoveUsersEvent {
  final int groupId;

  const RemoveUsersLoadRequested(this.groupId);
}

/// Remove the selected users (mirrors `removeUsersToGroupApiCall()`); [req]
/// built by the widget.
class RemoveUsersSubmitted extends RemoveUsersEvent {
  final AddRemoveUserReq req;

  const RemoveUsersSubmitted(this.req);
}
