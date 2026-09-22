part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load the selected team's projects (mirrors the old `getProjects()`).
class DashboardProjectsRequested extends DashboardEvent {
  const DashboardProjectsRequested();
}
