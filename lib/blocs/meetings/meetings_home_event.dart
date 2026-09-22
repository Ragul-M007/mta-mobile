part of 'meetings_home_bloc.dart';

abstract class MeetingsHomeEvent extends Equatable {
  const MeetingsHomeEvent();

  @override
  List<Object?> get props => [];
}

/// Load upcoming meetings + create-meeting access (mirrors `getProfile()`).
class MeetingsHomeRequested extends MeetingsHomeEvent {
  const MeetingsHomeRequested();
}
