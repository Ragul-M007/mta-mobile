part of 'attendance_bloc.dart';

/// Command-style states: each emission drives a one-off UI side effect in the
/// widget's `BlocListener` (spinner / toast / setState of the screen's globals /
/// list refresh). They are intentionally **not** `Equatable` — unlike the
/// auth/projects BLoCs — because the same outcome legitimately repeats (e.g. a
/// successful check-in immediately followed by a check-out, or two empty date
/// fetches) and must re-fire the listener every time instead of being
/// de-duplicated by bloc's identical-state guard.
abstract class AttendanceState {
  const AttendanceState();
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

// --- getProjects() / updateCurrentProject() ---

/// Show the spinner while (re)loading projects.
class AttendanceProjectsLoading extends AttendanceState {}

/// Projects loaded — widget sets `_projectLists`, `selectedProject`, `location`.
class AttendanceProjectsLoaded extends AttendanceState {
  final List<Data>? projects;
  final Data? selectedProject;

  AttendanceProjectsLoaded(this.projects, this.selectedProject);
}

/// `status == false` while loading projects — dismiss spinner + error toast.
class AttendanceProjectsFailure extends AttendanceState {
  final String message;

  AttendanceProjectsFailure(this.message);
}

/// Unexpected error loading projects (catchError) — dismiss spinner only.
class AttendanceProjectsError extends AttendanceState {}

/// setCurrentProject returned `status == false` — dismiss spinner + error toast.
class AttendanceCurrentProjectFailure extends AttendanceState {
  final String message;

  AttendanceCurrentProjectFailure(this.message);
}

// --- getAttendance() ---

/// Show the spinner while loading attendance records.
class AttendanceRecordsLoading extends AttendanceState {}

/// Records present — widget sets `_attendancemain` and runs formatAttendanceData().
class AttendanceRecordsLoaded extends AttendanceState {
  final List<AttendanceData> records;

  AttendanceRecordsLoaded(this.records);
}

/// No records for the date — widget clears `_attendancemain` and `_attendance`.
class AttendanceRecordsEmpty extends AttendanceState {}

/// `status == false` fetching records — widget clears `_attendance` + toast.
class AttendanceRecordsFailure extends AttendanceState {
  final String message;

  AttendanceRecordsFailure(this.message);
}

/// Unexpected error fetching records (catchError) — widget clears `_attendance`.
class AttendanceRecordsError extends AttendanceState {}

// --- checkInOut() ---

/// Show the spinner while submitting a check-in / check-out.
class AttendanceCheckLoading extends AttendanceState {}

/// Check-in/out succeeded — widget shows success toast and refreshes the list.
class AttendanceCheckSuccess extends AttendanceState {
  final String message;

  AttendanceCheckSuccess(this.message);
}

/// `status == false` on check-in/out — dismiss spinner + error toast.
class AttendanceCheckFailure extends AttendanceState {
  final String message;

  AttendanceCheckFailure(this.message);
}

/// Unexpected error on check-in/out (catchError) — dismiss spinner only.
class AttendanceCheckError extends AttendanceState {}
