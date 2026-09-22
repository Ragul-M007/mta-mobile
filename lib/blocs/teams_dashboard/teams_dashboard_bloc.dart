import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/TeamsModel.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

part 'teams_dashboard_event.dart';
part 'teams_dashboard_state.dart';

/// BLoC for the Teams dashboard screen.
///
/// Behavior-preserving extraction of `_TeamsDashboardState.getTeams()` and its
/// push-triggered `getUserCats()` chain. The API calls, `Strings` writes and
/// `print` logging move verbatim; the spinner, list / error-text updates and
/// navigation to `/comments` remain the widget's job via a stream listener.
/// The role-7 webview branch and `getPermission()` stay in the widget — they
/// are UI/device concerns, not networking. Note the push auto-open only fires
/// on the *empty* (status == false) branch here, matching the original.
class TeamsDashboardBloc
    extends Bloc<TeamsDashboardEvent, TeamsDashboardState> {
  final ApiService _api;

  TeamsDashboardBloc(this._api) : super(const TeamsInitial()) {
    on<TeamsRequested>(_onTeamsRequested);
  }

  // Mirrors getTeams()
  Future<void> _onTeamsRequested(
      TeamsRequested event, Emitter<TeamsDashboardState> emit) async {
    emit(const TeamsLoading());
    try {
      final response = await _api.fetchTeams();
      if (response.status!) {
        emit(TeamsLoaded(response.data!));
      } else {
        emit(TeamsEmpty(response.message!));
        if (Strings.isPushAvailable == true) {
          Strings.isPushAvailable = false;
          await _getUserCats(Strings.selectedProject[0].projectId, emit);
        }
      }
    } catch (onError) {
      emit(const TeamsLoadError());
      print(onError.toString());
    }
  }

  // Mirrors getUserCats() — only reached via the push auto-open branch.
  // Preserves the quirk that a failed `fetchUsers` leaves the spinner up.
  Future<void> _getUserCats(proId, Emitter<TeamsDashboardState> emit) async {
    emit(const TeamCommentsLoading());
    try {
      final response = await _api.fetchUsers(proId);
      if (response.status!) {
        Strings.users = response.data!;
        try {
          final catResponse = await _api.fetchCats(proId);
          if (catResponse.status!) {
            Strings.categories = catResponse.data!;
            emit(const TeamCommentsReady());
          } else {
            print('error');
            emit(const TeamCommentsDismissed());
          }
        } catch (onError) {
          print(onError.toString());
          emit(const TeamCommentsDismissed());
        }
      } else {
        print('error');
        // Original does NOT dismiss the spinner on a failed fetchUsers; keep it.
      }
    } catch (onError) {
      print(onError.toString());
      emit(const TeamCommentsDismissed());
    }
  }
}
