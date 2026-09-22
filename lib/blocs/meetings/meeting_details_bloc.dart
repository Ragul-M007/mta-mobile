import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/MeetingDetails.dart';
import 'package:mta/models/UpdateMeetingReq.dart';
import 'package:mta/models/cancelMeetingReq.dart';
import 'package:mta/network/ApiService.dart';

part 'meeting_details_event.dart';
part 'meeting_details_state.dart';

/// BLoC for the Meeting-Details screen (3 flows: getMeetings/getMeetingById,
/// updateMeeting, cancelMeeting/deleteMeeting).
///
/// Behavior-preserving extraction: the BLoC keeps the API calls and `print`
/// logging; the widget's listener performs the UI side effects (spinner, toast,
/// the `meetingsData` setState + type/location follow-up, navigation). States
/// are command-style (not Equatable).
class MeetingDetailsBloc
    extends Bloc<MeetingDetailsEvent, MeetingDetailsState> {
  final ApiService _api;

  MeetingDetailsBloc(this._api) : super(MeetingDetailsInitial()) {
    on<MeetingDetailsLoadRequested>(_onLoad);
    on<MeetingDetailsUpdateRequested>(_onUpdate);
    on<MeetingDetailsCancelRequested>(_onCancel);
  }

  // Mirrors getMeetings()
  Future<void> _onLoad(
      MeetingDetailsLoadRequested event, Emitter<MeetingDetailsState> emit) async {
    print(">>>>:${event.meetingId}");
    emit(MeetingDetailsLoading());
    try {
      final response = await _api.getMeetingById(event.meetingId);
      print(">>>>>>11:${response.status!}");
      if (response.status!) {
        emit(MeetingDetailsLoaded(response.data!));
      } else {
        emit(MeetingDetailsDismiss());
      }
    } catch (onError) {
      print(">>>>>err:${onError}");
      emit(MeetingDetailsDismiss());
    }
  }

  // Mirrors the api.updateMeeting(...) portion of updateMeeting()
  Future<void> _onUpdate(
      MeetingDetailsUpdateRequested event, Emitter<MeetingDetailsState> emit) async {
    try {
      final response = await _api.updateMeeting(event.req);
      if (response.status!) {
        emit(MeetingUpdateSuccess());
      } else {
        emit(MeetingUpdateFailure(response.message!));
      }
    } catch (onError) {
      emit(MeetingUpdateError());
    }
  }

  // Mirrors the api.deleteMeeting(...) portion of cancelMeeting()
  Future<void> _onCancel(
      MeetingDetailsCancelRequested event, Emitter<MeetingDetailsState> emit) async {
    try {
      final response = await _api.deleteMeeting(event.req);
      if (response.status!) {
        emit(MeetingCancelSuccess());
      } else {
        emit(MeetingCancelFailure(response.message!));
      }
    } catch (onError) {
      emit(MeetingCancelError());
    }
  }
}
