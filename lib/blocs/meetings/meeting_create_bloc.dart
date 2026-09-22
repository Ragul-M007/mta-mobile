import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/AddMeetingReq.dart';
import 'package:mta/network/ApiService.dart';

part 'meeting_create_event.dart';
part 'meeting_create_state.dart';

/// BLoC for creating a meeting (the submit step in `location_selection.dart`).
///
/// Behavior-preserving extraction of `submitData()`'s `api.createMeeting(...)`
/// call and `print` logging. The `_isLoading` flag, EasyLoading spinner, toasts,
/// error snackbar and the triple `Navigator.pop` remain the widget's job via a
/// stream listener. The location URL on `addMeetingData` is still computed by
/// the widget (from `_markedLocation`) before the event is dispatched.
///
/// States are command-style (not Equatable): a submit can legitimately repeat
/// and fail with the same message, and must re-fire the listener each time.
class MeetingCreateBloc extends Bloc<MeetingCreateEvent, MeetingCreateState> {
  final ApiService _api;

  MeetingCreateBloc(this._api) : super(MeetingCreateInitial()) {
    on<MeetingSubmitted>(_onSubmitted);
  }

  // Mirrors the api.createMeeting(...) portion of submitData()
  Future<void> _onSubmitted(
      MeetingSubmitted event, Emitter<MeetingCreateState> emit) async {
    emit(MeetingCreateLoading());
    print(">AddMeeting:${jsonEncode(event.data)}");
    try {
      final response = await _api.createMeeting(event.data);
      if (response.status!) {
        emit(MeetingCreated());
      } else {
        emit(MeetingCreateFailed(response.message!));
      }
    } catch (onError) {
      emit(MeetingCreateError());
    }
  }
}
