part of 'project_comments_bloc.dart';

/// Command-style states (not Equatable).
abstract class ProjectCommentsState {
  const ProjectCommentsState();
}

class ProjectCommentsInitial extends ProjectCommentsState {}

/// Socket connected (initial) — widget calls `getComments()` (dispatch
/// [ProjectCommentsSubscribe]).
class ProjectCommentsConnectedState extends ProjectCommentsState {}

/// A `project-comments` payload — widget runs the verbatim getComments() handler
/// body (guarded by `initialCommentCheck`) with [data].
class ProjectCommentsDocLoaded extends ProjectCommentsState {
  final dynamic data;

  ProjectCommentsDocLoaded(this.data);
}

/// fetchUsers success — widget setState(`Strings.users`/`users`/`_userIitems`).
class ProjectCommentsUserCatsLoaded extends ProjectCommentsState {
  final List<FetchMapedUsersData> data;

  ProjectCommentsUserCatsLoaded(this.data);
}

/// getProjectName success — widget setState(`projectname`).
class ProjectCommentsProjectLoaded extends ProjectCommentsState {
  final String name;

  ProjectCommentsProjectLoaded(this.name);
}

/// fetchCats success — widget dismisses +
/// setState(`Strings.categories`/`cats`/`_catsItems`).
class ProjectCommentsCatsLoaded extends ProjectCommentsState {
  final List<CatsData> data;

  ProjectCommentsCatsLoaded(this.data);
}

/// A flow's `catchError` (or fetchCats else) — widget only dismisses the spinner.
class ProjectCommentsDismiss extends ProjectCommentsState {}

/// Widget: `AppUtils.showprogress()` (removeComment start).
class ProjectCommentsRemoveLoading extends ProjectCommentsState {}

/// removeComment success — widget dismisses +
/// `showToastSuccess("Comment deleted successfully")`.
class ProjectCommentsRemoveOk extends ProjectCommentsState {}

/// removeComment `status == false` — no UI (the original only prints).
class ProjectCommentsRemoveFail extends ProjectCommentsState {}

/// removeComment `catchError` — widget only dismisses.
class ProjectCommentsRemoveError extends ProjectCommentsState {}

/// uploadAudio success — widget dismisses + `showToastSuccess("Audio sent
/// successfully")` + clears the tag lists (CatData/UserData/taged*).
class ProjectCommentsAudioOk extends ProjectCommentsState {}

/// uploadAudio `status == false` — widget dismisses + `showToastErrorTop(message)`.
class ProjectCommentsAudioFail extends ProjectCommentsState {
  final String message;

  ProjectCommentsAudioFail(this.message);
}

/// uploadAudio `catchError` — widget only dismisses.
class ProjectCommentsAudioError extends ProjectCommentsState {}

/// Reconnected after delete/audio — widget sets `initialCommentCheck = true`,
/// calls `getComments()`, and (when [audioUi]) clears the input + unfocuses.
class ProjectCommentsReconnectedState extends ProjectCommentsState {
  final bool audioUi;

  ProjectCommentsReconnectedState(this.audioUi);
}

/// updateNotification `status == false` — widget dismisses + `showToastError(message)`.
class ProjectCommentsNotifFailure extends ProjectCommentsState {
  final String message;

  ProjectCommentsNotifFailure(this.message);
}

/// updateNotification `catchError` — widget dismisses +
/// `showToastError("Unable to connect to server")`.
class ProjectCommentsNotifError extends ProjectCommentsState {}
