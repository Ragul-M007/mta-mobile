part of 'meeting_details_bloc.dart';

abstract class MeetingDetailsEvent {
  const MeetingDetailsEvent();
}

/// Load the meeting (mirrors `getMeetings()`); [meetingId] is
/// `widget.meeting_id`.
class MeetingDetailsLoadRequested extends MeetingDetailsEvent {
  final int meetingId;

  const MeetingDetailsLoadRequested(this.meetingId);
}

/// Update the meeting time (mirrors the updateMeeting call); [req] built by the
/// widget.
class MeetingDetailsUpdateRequested extends MeetingDetailsEvent {
  final UpdateMeetingReq req;

  const MeetingDetailsUpdateRequested(this.req);
}

/// Cancel the meeting (mirrors the deleteMeeting call); [req] built by the
/// widget.
class MeetingDetailsCancelRequested extends MeetingDetailsEvent {
  final CancelMeetingReq req;

  const MeetingDetailsCancelRequested(this.req);
}
