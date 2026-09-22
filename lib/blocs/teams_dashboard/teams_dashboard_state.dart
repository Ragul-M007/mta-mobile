part of 'teams_dashboard_bloc.dart';

abstract class TeamsDashboardState extends Equatable {
  const TeamsDashboardState();

  @override
  List<Object?> get props => [];
}

class TeamsInitial extends TeamsDashboardState {
  const TeamsInitial();
}

/// Show the loading spinner (getTeams start).
class TeamsLoading extends TeamsDashboardState {
  const TeamsLoading();
}

/// Teams fetched — dismiss the spinner and render [teams].
class TeamsLoaded extends TeamsDashboardState {
  final List<TeamsData> teams;

  const TeamsLoaded(this.teams);

  @override
  List<Object?> get props => [teams];
}

/// Fetch returned `status == false` — dismiss the spinner and show [message]
/// as the empty-state text (mirrors the old `_errText = response.message`).
class TeamsEmpty extends TeamsDashboardState {
  final String message;

  const TeamsEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

/// Unexpected error while loading teams (the old `catchError` path) — dismiss
/// the spinner only (the original just printed).
class TeamsLoadError extends TeamsDashboardState {
  const TeamsLoadError();
}

// --- push auto-open (getUserCats) sub-flow ---

/// Show the spinner while fetching users + categories for the pushed project.
class TeamCommentsLoading extends TeamsDashboardState {
  const TeamCommentsLoading();
}

/// Users + categories loaded — dismiss the spinner and navigate to `/comments`.
class TeamCommentsReady extends TeamsDashboardState {
  const TeamCommentsReady();
}

/// A handled failure in the getUserCats chain — dismiss the spinner only.
class TeamCommentsDismissed extends TeamsDashboardState {
  const TeamCommentsDismissed();
}
