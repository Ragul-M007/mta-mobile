part of 'projects_bloc.dart';

abstract class ProjectsState extends Equatable {
  const ProjectsState();

  @override
  List<Object?> get props => [];
}

class ProjectsInitial extends ProjectsState {
  const ProjectsInitial();
}

/// Show the loading spinner (getProjects start).
class ProjectsLoading extends ProjectsState {
  const ProjectsLoading();
}

/// Projects fetched — dismiss the spinner and render [projects].
class ProjectsLoaded extends ProjectsState {
  final List<Data> projects;

  const ProjectsLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

/// Fetch returned `status == false` — dismiss the spinner and show [message]
/// as the empty-state text (mirrors the old `_errText = response.message`).
class ProjectsEmpty extends ProjectsState {
  final String message;

  const ProjectsEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

/// Unexpected error while loading projects (the old `catchError` path) —
/// dismiss the spinner only (the original just printed).
class ProjectsLoadError extends ProjectsState {
  const ProjectsLoadError();
}

// --- push auto-open (getUserCats) sub-flow ---

/// Show the spinner while fetching users + categories for the pushed project.
class ProjectCommentsLoading extends ProjectsState {
  const ProjectCommentsLoading();
}

/// Users + categories loaded — dismiss the spinner and navigate to `/comments`.
class ProjectCommentsReady extends ProjectsState {
  const ProjectCommentsReady();
}

/// A handled failure in the getUserCats chain — dismiss the spinner only.
class ProjectCommentsDismissed extends ProjectsState {
  const ProjectCommentsDismissed();
}
