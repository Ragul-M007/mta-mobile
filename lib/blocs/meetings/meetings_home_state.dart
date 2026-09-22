part of 'meetings_home_bloc.dart';

abstract class MeetingsHomeState extends Equatable {
  const MeetingsHomeState();

  @override
  List<Object?> get props => [];
}

class MeetingsHomeInitial extends MeetingsHomeState {
  const MeetingsHomeInitial();
}

/// Show the loading spinner (getProfile start).
class MeetingsHomeLoading extends MeetingsHomeState {
  const MeetingsHomeLoading();
}

/// Upcoming meetings fetched — dismiss the spinner and set the lists.
class UpcomingMeetingsLoaded extends MeetingsHomeState {
  final List<MeetingsData> meetings;

  const UpcomingMeetingsLoaded(this.meetings);

  @override
  List<Object?> get props => [meetings];
}

/// `status == false` — dismiss the spinner and clear the lists.
class UpcomingMeetingsEmpty extends MeetingsHomeState {
  const UpcomingMeetingsEmpty();
}

/// Meeting-access fetched — dismiss the spinner and set the create-access flag.
class MeetingAccessLoaded extends MeetingsHomeState {
  final bool access;

  const MeetingAccessLoaded(this.access);

  @override
  List<Object?> get props => [access];
}

/// Error fetching meeting access (catchError) — dismiss the spinner only.
class MeetingAccessError extends MeetingsHomeState {
  const MeetingAccessError();
}
