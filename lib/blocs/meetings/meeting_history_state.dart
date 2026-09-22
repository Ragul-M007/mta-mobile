part of 'meeting_history_bloc.dart';

abstract class MeetingHistoryState extends Equatable {
  const MeetingHistoryState();

  @override
  List<Object?> get props => [];
}

class MeetingHistoryInitial extends MeetingHistoryState {
  const MeetingHistoryInitial();
}

/// History fetched — set `meetingsData` to [meetings].
class MeetingHistoryLoaded extends MeetingHistoryState {
  final List<MeetingsData> meetings;

  const MeetingHistoryLoaded(this.meetings);

  @override
  List<Object?> get props => [meetings];
}

/// `status == false` — clear `meetingsData`.
class MeetingHistoryEmpty extends MeetingHistoryState {
  const MeetingHistoryEmpty();
}
