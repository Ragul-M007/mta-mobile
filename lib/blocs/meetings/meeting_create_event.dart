part of 'meeting_create_bloc.dart';

abstract class MeetingCreateEvent extends Equatable {
  const MeetingCreateEvent();

  @override
  List<Object?> get props => [];
}

/// Submit the meeting (mirrors `submitData()`); [data] is the fully-populated
/// `AddMeetingReq` (location URL already set by the widget).
class MeetingSubmitted extends MeetingCreateEvent {
  final AddMeetingReq data;

  const MeetingSubmitted(this.data);

  @override
  List<Object?> get props => [data];
}
