part of 'replies_bloc.dart';

/// Command-style states (not Equatable).
abstract class RepliesState {
  const RepliesState();
}

class RepliesInitial extends RepliesState {}

/// Socket connected (initial) — widget calls `getReplies()` (dispatch
/// [RepliesSubscribe]).
class RepliesConnectedState extends RepliesState {}

/// A `document-comments` payload — widget runs the verbatim getReplies() handler
/// body (guarded by `initialCommentCheck`) with [data].
class RepliesDocLoaded extends RepliesState {
  final dynamic data;

  RepliesDocLoaded(this.data);
}

/// fetchUsers success — widget setState(`Strings.users`/`users`/`_userIitems`).
class RepliesUserCatsLoaded extends RepliesState {
  final List<FetchMapedUsersData> data;

  RepliesUserCatsLoaded(this.data);
}

/// getProjectName success — widget setState(`projectname`).
class RepliesProjectLoaded extends RepliesState {
  final String name;

  RepliesProjectLoaded(this.name);
}

/// fetchCats success — widget dismisses +
/// setState(`Strings.categories`/`cats`/`_catsItems`).
class RepliesCatsLoaded extends RepliesState {
  final List<CatsData> data;

  RepliesCatsLoaded(this.data);
}

/// A flow's `catchError` (or fetchCats else) — widget only dismisses the spinner.
class RepliesDismiss extends RepliesState {}

/// Widget: `AppUtils.showprogress()` (removeComment start).
class RepliesRemoveLoading extends RepliesState {}

/// removeComment success — widget dismisses +
/// `showToastSuccess("Comment deleted successfully")`.
class RepliesRemoveOk extends RepliesState {}

/// removeComment `status == false` — no UI (the original only prints).
class RepliesRemoveFail extends RepliesState {}

/// removeComment `catchError` — widget only dismisses.
class RepliesRemoveError extends RepliesState {}

/// uploadAudio success — widget only dismisses (the success toast happens in the
/// reconnect UI for this screen).
class RepliesAudioOk extends RepliesState {}

/// uploadAudio `status == false` — widget dismisses + `showToastErrorTop(message)`.
class RepliesAudioFail extends RepliesState {
  final String message;

  RepliesAudioFail(this.message);
}

/// uploadAudio `catchError` — widget only dismisses.
class RepliesAudioError extends RepliesState {}

/// Reconnected after delete/audio — widget sets `initialCommentCheck = true`,
/// calls `getReplies()`, and (when [audioUi]) toasts "Audio sent successfully",
/// bumps commentsCount, clears the input + unfocuses.
class RepliesReconnectedState extends RepliesState {
  final bool audioUi;

  RepliesReconnectedState(this.audioUi);
}

/// updateNotification `status == false` — widget dismisses + `showToastError(message)`.
class RepliesNotifFailure extends RepliesState {
  final String message;

  RepliesNotifFailure(this.message);
}

/// updateNotification `catchError` — widget dismisses +
/// `showToastError("Unable to connect to server")`.
class RepliesNotifError extends RepliesState {}
