import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/AddMeetingReq.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/TeamUsersRes.dart';
import 'package:mta/network/ApiService.dart';

part 'members_selection_event.dart';
part 'members_selection_state.dart';

/// BLoC for the members-selection step of meeting creation.
///
/// Behavior-preserving extraction of `getTeamsUsers()`, `getProjectUsers()` and
/// the `api.createMeeting(...)` portion of `submitData()`. API calls and `print`
/// logging move verbatim; the widget keeps the `teamUsersLists`/`projectUsersLists`
/// Maps, the `totalUser` accumulation, the `isButtonEnabled` debounce, the
/// spinner, toasts, error snackbar and navigation — driven by the states via a
/// stream listener. States are command-style (not Equatable): per-id fetches and
/// submit outcomes can repeat and must re-fire the listener each time.
class MembersSelectionBloc
    extends Bloc<MembersSelectionEvent, MembersSelectionState> {
  final ApiService _api;

  MembersSelectionBloc(this._api) : super(MembersSelectionInitial()) {
    on<TeamUsersRequested>(_onTeamUsers);
    on<ProjectUsersRequested>(_onProjectUsers);
    on<MembersMeetingSubmitted>(_onSubmitted);
  }

  // Mirrors getTeamsUsers()
  Future<void> _onTeamUsers(
      TeamUsersRequested event, Emitter<MembersSelectionState> emit) async {
    try {
      final response = await _api.fetchTeamUsers(event.teamId);
      if (response.status!) {
        emit(TeamUsersLoaded(event.teamId, response.data!));
      } else {
        emit(TeamUsersEmpty(event.teamId));
      }
    } catch (onError) {
      print(onError.toString());
    }
  }

  // Mirrors getProjectUsers()
  Future<void> _onProjectUsers(
      ProjectUsersRequested event, Emitter<MembersSelectionState> emit) async {
    try {
      final response = await _api.fetchUsers(event.projectId);
      if (response.status!) {
        emit(ProjectUsersLoaded(event.projectId, response.data ?? []));
      } else {
        emit(ProjectUsersEmpty(event.projectId));
      }
    } catch (onError) {
      print(onError.toString());
    }
  }

  // Mirrors the api.createMeeting(...) branch of submitData() (type == "2")
  Future<void> _onSubmitted(
      MembersMeetingSubmitted event, Emitter<MembersSelectionState> emit) async {
    emit(MembersSubmitLoading());
    try {
      final response = await _api.createMeeting(event.data);
      if (response.status!) {
        emit(MembersMeetingCreated());
      } else {
        emit(MembersSubmitFailed(response.message!));
      }
    } catch (onError) {
      emit(MembersSubmitError());
    }
  }
}
