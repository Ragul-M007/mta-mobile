part of 'meeting_history_bloc.dart';

abstract class MeetingHistoryEvent extends Equatable {
  const MeetingHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load meeting history for [date] (mirrors `getMeetings()`; date derived from
/// the optional `picked` filter by the widget).
class MeetingHistoryRequested extends MeetingHistoryEvent {
  final String date;

  const MeetingHistoryRequested(this.date);

  @override
  List<Object?> get props => [date];
}
