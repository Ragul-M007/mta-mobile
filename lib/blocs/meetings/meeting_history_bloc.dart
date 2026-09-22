import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/MeetingsDataRes.dart';
import 'package:mta/network/ApiService.dart';

part 'meeting_history_event.dart';
part 'meeting_history_state.dart';

/// BLoC for the Meeting History screen.
///
/// Behavior-preserving extraction of `_MeetingHistoryState.getMeetings()`. The
/// API call and `print` logging move verbatim; `setState` of `meetingsData`
/// stays in the widget via a stream listener. The screen shows no spinner (the
/// original's progress calls are commented out), so no loading state is emitted.
/// The date (from the optional `picked` filter) is computed by the widget and
/// passed in the event.
class MeetingHistoryBloc extends Bloc<MeetingHistoryEvent, MeetingHistoryState> {
  final ApiService _api;

  MeetingHistoryBloc(this._api) : super(const MeetingHistoryInitial()) {
    on<MeetingHistoryRequested>(_onRequested);
  }

  // Mirrors getMeetings()
  Future<void> _onRequested(
      MeetingHistoryRequested event, Emitter<MeetingHistoryState> emit) async {
    try {
      final response = await _api.getMeetingHistory(event.date);
      if (response.status!) {
        emit(MeetingHistoryLoaded(response.data ?? []));
      } else {
        emit(const MeetingHistoryEmpty());
      }
    } catch (onError) {
      print(onError.toString());
      // Original catchError only prints (progress dismiss is commented out).
    }
  }
}
