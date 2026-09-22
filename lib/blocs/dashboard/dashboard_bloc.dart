import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// BLoC for the Dashboard (team → projects) screen at route `/dashboard`.
///
/// Behavior-preserving extraction of `_DashboardState.getProjects()` (which
/// fetches `fetchProjectByTeams(selectedTeamId)`) and its push-triggered
/// `getUserCats()` chain. The API calls, `Strings` writes and `print` logging
/// move verbatim; the spinner, list / error-text updates and navigation to
/// `/comments` remain the widget's job via a stream listener. The role-7
/// webview branch and `getPermission()` stay in the widget.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiService _api;

  DashboardBloc(this._api) : super(const DashboardInitial()) {
    on<DashboardProjectsRequested>(_onProjectsRequested);
  }

  // Mirrors getProjects()
  Future<void> _onProjectsRequested(
      DashboardProjectsRequested event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    try {
      final response = await _api.fetchProjectByTeams(Strings.selectedTeamId!);
      if (response.status!) {
        print("messagee from api ${response.message}");
        emit(DashboardLoaded(response.data!));
        if (Strings.isPushAvailable == true) {
          Strings.isPushAvailable = false;
          await _getUserCats(Strings.selectedProject[0].projectId, emit);
        }
      } else {
        emit(DashboardEmpty(response.message!));
        if (Strings.isPushAvailable == true) {
          Strings.isPushAvailable = false;
          await _getUserCats(Strings.selectedProject[0].projectId, emit);
        }
      }
    } catch (onError) {
      emit(const DashboardLoadError());
      print(onError.toString());
    }
  }

  // Mirrors getUserCats() — only reached via the push auto-open branch.
  // Preserves the quirk that a failed `fetchUsers` leaves the spinner up.
  Future<void> _getUserCats(proId, Emitter<DashboardState> emit) async {
    emit(const DashboardCommentsLoading());
    try {
      final response = await _api.fetchUsers(proId);
      if (response.status!) {
        Strings.users = response.data!;
        try {
          final catResponse = await _api.fetchCats(proId);
          if (catResponse.status!) {
            Strings.categories = catResponse.data!;
            emit(const DashboardCommentsReady());
          } else {
            print('error');
            emit(const DashboardCommentsDismissed());
          }
        } catch (onError) {
          print(onError.toString());
          emit(const DashboardCommentsDismissed());
        }
      } else {
        print('error');
        // Original does NOT dismiss the spinner on a failed fetchUsers; keep it.
      }
    } catch (onError) {
      print(onError.toString());
      emit(const DashboardCommentsDismissed());
    }
  }
}
