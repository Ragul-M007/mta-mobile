part of 'members_selection_bloc.dart';

/// Command-style states (not Equatable) — per-id fetches and submit outcomes
/// can repeat and must re-fire the widget's listener each time.
abstract class MembersSelectionState {
  const MembersSelectionState();
}

class MembersSelectionInitial extends MembersSelectionState {}

/// A team's users loaded — widget sets `teamUsersLists["$teamId"]` + `totalUser`.
class TeamUsersLoaded extends MembersSelectionState {
  final dynamic teamId;
  final List<UsersData> users;

  TeamUsersLoaded(this.teamId, this.users);
}

/// `status == false` for a team — widget clears `teamUsersLists["$teamId"]`.
class TeamUsersEmpty extends MembersSelectionState {
  final dynamic teamId;

  TeamUsersEmpty(this.teamId);
}

/// A project's users loaded — widget sets `projectUsersLists["$projectId"]` + `totalUser`.
class ProjectUsersLoaded extends MembersSelectionState {
  final dynamic projectId;
  final List<FetchMapedUsersData> users;

  ProjectUsersLoaded(this.projectId, this.users);
}

/// `status == false` for a project — widget clears `projectUsersLists["$projectId"]`.
class ProjectUsersEmpty extends MembersSelectionState {
  final dynamic projectId;

  ProjectUsersEmpty(this.projectId);
}

// --- submit (createMeeting) ---

/// Submitting — show the spinner.
class MembersSubmitLoading extends MembersSelectionState {}

/// Created — success toast, clear the button debounce and pop back (x2).
class MembersMeetingCreated extends MembersSelectionState {}

/// `status == false` — error snackbar + clear the button debounce + dismiss.
class MembersSubmitFailed extends MembersSelectionState {
  final String message;

  MembersSubmitFailed(this.message);
}

/// Unexpected error (catchError) — dismiss, clear debounce, generic error toast.
class MembersSubmitError extends MembersSelectionState {}
