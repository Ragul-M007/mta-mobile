part of 'members_selection_bloc.dart';

abstract class MembersSelectionEvent extends Equatable {
  const MembersSelectionEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch a team's users (mirrors `getTeamsUsers(team_id)`).
class TeamUsersRequested extends MembersSelectionEvent {
  final dynamic teamId;

  const TeamUsersRequested(this.teamId);

  @override
  List<Object?> get props => [teamId];
}

/// Fetch a project's users (mirrors `getProjectUsers(project_id)`).
class ProjectUsersRequested extends MembersSelectionEvent {
  final dynamic projectId;

  const ProjectUsersRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Submit the meeting for the online (type "2") path (mirrors `submitData()`).
class MembersMeetingSubmitted extends MembersSelectionEvent {
  final AddMeetingReq data;

  const MembersMeetingSubmitted(this.data);

  @override
  List<Object?> get props => [data];
}
