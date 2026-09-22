part of 'projects_bloc.dart';

abstract class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the project list (mirrors the old `getProjects()` in `initState`).
class ProjectsRequested extends ProjectsEvent {
  const ProjectsRequested();
}
