part of 'adddoc_bloc.dart';

abstract class AddDocEvent {
  const AddDocEvent();
}

/// Load the taggable users (mirrors `getUserCats()` → fetchUsers).
class AddDocUsersRequested extends AddDocEvent {
  const AddDocUsersRequested();
}

/// Submit the document (mirrors the addDoc call in `submit()`); [req] built by
/// the widget.
class AddDocSubmitted extends AddDocEvent {
  final AddDocReq req;

  const AddDocSubmitted(this.req);
}

/// Apply the user-access rights (mirrors `UpdateRights()` → userAccess);
/// [users] and [req] built by the widget.
class AddDocRightsRequested extends AddDocEvent {
  final String users;
  final UserAccessReq req;

  const AddDocRightsRequested(this.users, this.req);
}
