part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Show the loading spinner (getProjects start).
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Team projects fetched — dismiss the spinner and render [projects].
class DashboardLoaded extends DashboardState {
  final List<Data> projects;

  const DashboardLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

/// Fetch returned `status == false` — dismiss the spinner and show [message]
/// as the empty-state text (mirrors the old `_errText = response.message`).
class DashboardEmpty extends DashboardState {
  final String message;

  const DashboardEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

/// Unexpected error while loading (the old `catchError` path) — dismiss only.
class DashboardLoadError extends DashboardState {
  const DashboardLoadError();
}

// --- push auto-open (getUserCats) sub-flow ---

/// Show the spinner while fetching users + categories for the pushed project.
class DashboardCommentsLoading extends DashboardState {
  const DashboardCommentsLoading();
}

/// Users + categories loaded — dismiss the spinner and navigate to `/comments`.
class DashboardCommentsReady extends DashboardState {
  const DashboardCommentsReady();
}

/// A handled failure in the getUserCats chain — dismiss the spinner only.
class DashboardCommentsDismissed extends DashboardState {
  const DashboardCommentsDismissed();
}
