import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mta/models/MeetingsDataRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

part 'meetings_home_event.dart';
part 'meetings_home_state.dart';

/// BLoC for the Meetings home screen.
///
/// Behavior-preserving extraction of `_MeetingscontentState.getProfile()`,
/// which fires `getMeetings()` (upcoming meetings) and `getMeetingAccess()`
/// (create-meeting permission). API calls and `print` logging move verbatim;
/// the spinner, `setState` of the lists and the access flag remain the widget's
/// job via a stream listener. The original fired the two calls concurrently;
/// here they run in sequence (independent data — same end result).
class MeetingsHomeBloc extends Bloc<MeetingsHomeEvent, MeetingsHomeState> {
  final ApiService _api;

  MeetingsHomeBloc(this._api) : super(const MeetingsHomeInitial()) {
    on<MeetingsHomeRequested>(_onRequested);
  }

  // Mirrors getProfile()
  Future<void> _onRequested(
      MeetingsHomeRequested event, Emitter<MeetingsHomeState> emit) async {
    emit(const MeetingsHomeLoading());
    await _getMeetings(emit);
    await _getMeetingAccess(emit);
  }

  // Mirrors getMeetings()
  Future<void> _getMeetings(Emitter<MeetingsHomeState> emit) async {
    print(">>>>>>");
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final formattedDate = formatter.format(now);
    try {
      final response = await _api.getUpcomingMeeting(formattedDate);
      if (response.status!) {
        emit(UpcomingMeetingsLoaded(response.data ?? []));
      } else {
        emit(const UpcomingMeetingsEmpty());
      }
    } catch (onError) {
      print(onError.toString());
      // Original catchError does NOT dismiss the spinner (commented out) — so
      // emit no dismissing state here; getMeetingAccess dismisses it next.
    }
  }

  // Mirrors the getMeetingAccess() call inside getProfile()
  Future<void> _getMeetingAccess(Emitter<MeetingsHomeState> emit) async {
    try {
      final response = await _api.getMeetingAccess(Strings.userID!);
      print('profileResponse status ${response.data}');
      emit(MeetingAccessLoaded(response.data!.access!));
    } catch (onError) {
      print(onError.toString());
      emit(const MeetingAccessError());
    }
  }
}
