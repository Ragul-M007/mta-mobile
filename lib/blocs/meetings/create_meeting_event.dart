part of 'create_meeting_bloc.dart';

abstract class CreateMeetingEvent extends Equatable {
  const CreateMeetingEvent();

  @override
  List<Object?> get props => [];
}

/// Load the form's data (integrated meetings → teams → projects), mirroring the
/// old `getIntegratedMeetings()` chain in `initState`.
class CreateMeetingDataRequested extends CreateMeetingEvent {
  const CreateMeetingDataRequested();
}
