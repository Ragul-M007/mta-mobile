part of 'attendance_bloc.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Load the user's projects (mirrors `getProjects()`).
class AttendanceProjectsRequested extends AttendanceEvent {
  const AttendanceProjectsRequested();
}

/// Set the current project then reload projects (mirrors `updateCurrentProject`).
class AttendanceCurrentProjectUpdated extends AttendanceEvent {
  final int projectId;

  const AttendanceCurrentProjectUpdated(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

/// Fetch attendance records for [date] (mirrors `getAttendance(date)`).
class AttendanceForDateRequested extends AttendanceEvent {
  final String date;

  const AttendanceForDateRequested(this.date);

  @override
  List<Object?> get props => [date];
}

/// Submit a check-in / check-out (mirrors `checkInOut(action)`). The location
/// fields come from the widget's top-level globals (`lat`, `long`, `location`,
/// `selectedProject`), passed in so the BLoC stays free of that widget state.
class AttendanceCheckInOutRequested extends AttendanceEvent {
  final dynamic action;
  final double lat;
  final double long;
  final String location;
  final int? projectId;

  const AttendanceCheckInOutRequested({
    required this.action,
    required this.lat,
    required this.long,
    required this.location,
    required this.projectId,
  });

  @override
  List<Object?> get props => [action, lat, long, location, projectId];
}
