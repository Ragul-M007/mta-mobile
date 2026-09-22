part of 'comments_bloc.dart';

/// Command-style states (not Equatable).
abstract class CommentsState {
  const CommentsState();
}

class CommentsInitial extends CommentsState {}

/// Socket connected (initial) — widget calls `getComments()` (dispatch
/// [CommentsSubscribe]).
class CommentsConnectedState extends CommentsState {}

/// A `document-comments` payload — widget runs the verbatim getComments()
/// handler body (guarded by `initialCommentCheck`) with [data].
class CommentsDocLoaded extends CommentsState {
  final dynamic data;

  CommentsDocLoaded(this.data);
}

/// fetchUsers success — widget setState(`Strings.users`/`users`/`_userIitems`).
class CommentsUserCatsLoaded extends CommentsState {
  final List<FetchMapedUsersData> data;

  CommentsUserCatsLoaded(this.data);
}

/// getProjectName success — widget setState(`projectname`).
class CommentsProjectLoaded extends CommentsState {
  final String name;

  CommentsProjectLoaded(this.name);
}

/// fetchCats success — widget dismisses +
/// setState(`Strings.categories`/`cats`/`_catsItems`).
class CommentsCatsLoaded extends CommentsState {
  final List<CatsData> data;

  CommentsCatsLoaded(this.data);
}

/// A flow's `catchError` (or fetchCats else) — widget only dismisses the spinner.
class CommentsDismiss extends CommentsState {}

/// Widget: `AppUtils.showprogress()` (removeComment start).
class CommentsRemoveLoading extends CommentsState {}

/// removeComment success — widget dismisses +
/// `showToastSuccess("Comment deleted successfully")`.
class CommentsRemoveOk extends CommentsState {}

/// removeComment `status == false` — no UI (the original only prints).
class CommentsRemoveFail extends CommentsState {}

/// removeComment `catchError` — widget only dismisses.
class CommentsRemoveError extends CommentsState {}

/// uploadAudio success — widget dismisses +
/// `showToastSuccess("Audio sent successfully")`.
class CommentsAudioOk extends CommentsState {}

/// uploadAudio `status == false` — widget dismisses + `showToastErrorTop(message)`.
class CommentsAudioFail extends CommentsState {
  final String message;

  CommentsAudioFail(this.message);
}

/// uploadAudio `catchError` — widget only dismisses.
class CommentsAudioError extends CommentsState {}

/// Reconnected after delete/audio — widget sets `initialCommentCheck = true`,
/// calls `getComments()`, and (when [audioUi]) bumps commentsCount + clears the
/// input + unfocuses.
class CommentsReconnectedState extends CommentsState {
  final bool audioUi;

  CommentsReconnectedState(this.audioUi);
}

/// updateNotification `status == false` — widget dismisses + `showToastError(message)`.
class CommentsNotifFailure extends CommentsState {
  final String message;

  CommentsNotifFailure(this.message);
}

/// updateNotification `catchError` — widget dismisses +
/// `showToastError("Unable to connect to server")`.
class CommentsNotifError extends CommentsState {}
