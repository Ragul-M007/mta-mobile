part of 'create_meeting_bloc.dart';

abstract class CreateMeetingState extends Equatable {
  const CreateMeetingState();

  @override
  List<Object?> get props => [];
}

class CreateMeetingInitial extends CreateMeetingState {
  const CreateMeetingInitial();
}

/// Integrated meetings loaded — widget sets `integratedMeetingsList` (no setState,
/// matching the original plain assignment).
class CreateMeetingIntegratedLoaded extends CreateMeetingState {
  final List<IntegratedMeetings> integrated;

  const CreateMeetingIntegratedLoaded(this.integrated);

  @override
  List<Object?> get props => [integrated];
}

/// Teams loaded — widget sets `teamLists` (no setState).
class CreateMeetingTeamsLoaded extends CreateMeetingState {
  final List<AllTeamsData> teams;

  const CreateMeetingTeamsLoaded(this.teams);

  @override
  List<Object?> get props => [teams];
}

/// Projects loaded — widget sets `projectsList` and calls setState (the only
/// step that rebuilds, exactly like the original).
class CreateMeetingProjectsLoaded extends CreateMeetingState {
  final List<Data> projects;

  const CreateMeetingProjectsLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}
