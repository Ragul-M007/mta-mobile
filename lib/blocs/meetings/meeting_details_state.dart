part of 'meeting_details_bloc.dart';

/// Command-style states (not Equatable).
abstract class MeetingDetailsState {
  const MeetingDetailsState();
}

class MeetingDetailsInitial extends MeetingDetailsState {}

/// Widget: `AppUtils.showprogress()` (load start).
class MeetingDetailsLoading extends MeetingDetailsState {}

/// Meeting loaded — widget dismisses, setState(`meetingsData`), then the
/// type/location follow-up (`_getAddressFromLink` / `locationData`).
class MeetingDetailsLoaded extends MeetingDetailsState {
  final MeetingDetail data;

  MeetingDetailsLoaded(this.data);
}

/// getMeetings `status == false` or `catchError` — widget only dismisses.
class MeetingDetailsDismiss extends MeetingDetailsState {}

/// updateMeeting success — widget reloads (`getMeetings()`),
/// `showToastSuccess("Meeting updated successfully!")`, then dismisses.
class MeetingUpdateSuccess extends MeetingDetailsState {}

/// updateMeeting `status == false` — widget `showToastError(message)` then
/// dismisses.
class MeetingUpdateFailure extends MeetingDetailsState {
  final String message;

  MeetingUpdateFailure(this.message);
}

/// updateMeeting `catchError` — widget dismisses +
/// `showToastError("Something went wrong!")`.
class MeetingUpdateError extends MeetingDetailsState {}

/// cancelMeeting success — widget `showToastSuccess("Meeting cancelled
/// successfully!")` then pops twice (dialog + screen).
class MeetingCancelSuccess extends MeetingDetailsState {}

/// cancelMeeting `status == false` — widget pops once + `showToastError(message)`.
class MeetingCancelFailure extends MeetingDetailsState {
  final String message;

  MeetingCancelFailure(this.message);
}

/// cancelMeeting `catchError` — widget `showToastError("Something went wrong!")`
/// + pops once.
class MeetingCancelError extends MeetingDetailsState {}
