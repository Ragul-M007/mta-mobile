part of 'teams_dashboard_bloc.dart';

abstract class TeamsDashboardEvent extends Equatable {
  const TeamsDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load the user's teams (mirrors the old `getTeams()` in `initState`).
class TeamsRequested extends TeamsDashboardEvent {
  const TeamsRequested();
}
