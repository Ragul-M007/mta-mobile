part of 'project_comments_replies_bloc.dart';

/// Command-style states (not Equatable).
abstract class ProjectCommentsRepliesState {
  const ProjectCommentsRepliesState();
}

class ProjectCommentsRepliesInitial extends ProjectCommentsRepliesState {}

/// Socket connected (initial) — widget calls `getReplies()` (dispatch
/// [ProjectCommentsRepliesSubscribe]).
class ProjectCommentsRepliesConnectedState
    extends ProjectCommentsRepliesState {}

/// A `project-comments` payload — widget runs the verbatim getReplies() handler
/// body (guarded by `initialCommentCheck`) with [data].
class ProjectCommentsRepliesDocLoaded extends ProjectCommentsRepliesState {
  final dynamic data;

  ProjectCommentsRepliesDocLoaded(this.data);
}

/// fetchUsers success — widget setState(`Strings.users`/`users`/`_userIitems`).
class ProjectCommentsRepliesUserCatsLoaded
    extends ProjectCommentsRepliesState {
  final List<FetchMapedUsersData> data;

  ProjectCommentsRepliesUserCatsLoaded(this.data);
}

/// getProjectName success — widget setState(`projectname`).
class ProjectCommentsRepliesProjectLoaded extends ProjectCommentsRepliesState {
  final String name;

  ProjectCommentsRepliesProjectLoaded(this.name);
}

/// fetchCats success — widget dismisses +
/// setState(`Strings.categories`/`cats`/`_catsItems`).
class ProjectCommentsRepliesCatsLoaded extends ProjectCommentsRepliesState {
  final List<CatsData> data;

  ProjectCommentsRepliesCatsLoaded(this.data);
}

/// A flow's `catchError` (or fetchCats else) — widget only dismisses the spinner.
class ProjectCommentsRepliesDismiss extends ProjectCommentsRepliesState {}

/// Widget: `AppUtils.showprogress()` (removeComment start).
class ProjectCommentsRepliesRemoveLoading
    extends ProjectCommentsRepliesState {}

/// removeComment success — widget dismisses +
/// `showToastSuccess("Comment deleted successfully")`.
class ProjectCommentsRepliesRemoveOk extends ProjectCommentsRepliesState {}

/// removeComment `status == false` — no UI (the original only prints).
class ProjectCommentsRepliesRemoveFail extends ProjectCommentsRepliesState {}

/// removeComment `catchError` — widget only dismisses.
class ProjectCommentsRepliesRemoveError extends ProjectCommentsRepliesState {}

/// uploadAudio success — widget dismisses, clears the tag lists,
/// `initialCommentCheck = true`, `showToastSuccess("Audio sent successfully")`.
class ProjectCommentsRepliesAudioOk extends ProjectCommentsRepliesState {}

/// uploadAudio `status == false` — widget dismisses + `showToastErrorTop(message)`.
class ProjectCommentsRepliesAudioFail extends ProjectCommentsRepliesState {
  final String message;

  ProjectCommentsRepliesAudioFail(this.message);
}

/// uploadAudio `catchError` — widget only dismisses.
class ProjectCommentsRepliesAudioError extends ProjectCommentsRepliesState {}

/// Reconnected after delete/audio — widget calls `getReplies()`; for a delete
/// ([audioUi] == false) it also sets `initialCommentCheck = true`, for an audio
/// send it clears the input + unfocuses.
class ProjectCommentsRepliesReconnectedState
    extends ProjectCommentsRepliesState {
  final bool audioUi;

  ProjectCommentsRepliesReconnectedState(this.audioUi);
}

/// updateNotification `status == false` — widget dismisses + `showToastError(message)`.
class ProjectCommentsRepliesNotifFailure extends ProjectCommentsRepliesState {
  final String message;

  ProjectCommentsRepliesNotifFailure(this.message);
}

/// updateNotification `catchError` — widget dismisses +
/// `showToastError("Unable to connect to server")`.
class ProjectCommentsRepliesNotifError extends ProjectCommentsRepliesState {}
