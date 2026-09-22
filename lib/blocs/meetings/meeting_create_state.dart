part of 'meeting_create_bloc.dart';

/// Command-style states (not Equatable) — a submit outcome can repeat and must
/// re-fire the widget's listener each time.
abstract class MeetingCreateState {
  const MeetingCreateState();
}

class MeetingCreateInitial extends MeetingCreateState {}

/// Submitting — set `_isLoading = true` and show the EasyLoading spinner.
class MeetingCreateLoading extends MeetingCreateState {}

/// Created — clear loading, success toast, and pop back through the flow (x3).
class MeetingCreated extends MeetingCreateState {}

/// `status == false` — clear loading and show [message] in an error snackbar.
class MeetingCreateFailed extends MeetingCreateState {
  final String message;

  MeetingCreateFailed(this.message);
}

/// Unexpected error (catchError) — clear loading and show a generic error toast.
class MeetingCreateError extends MeetingCreateState {}
