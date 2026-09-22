import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/DashboardRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

part 'projects_event.dart';
part 'projects_state.dart';

/// BLoC for the Projects screen.
///
/// Behavior-preserving extraction of the former `_ProjectsState.getProjects()`
/// and its push-triggered `getUserCats()` chain. The API calls, `Strings`
/// writes, `print` logging and the `isPushAvailable` auto-open branch are moved
/// verbatim; only the UI side effects (progress spinner, project-list / error
/// text updates, navigation to `/comments`) are emitted as states for the
/// widget to perform via a `BlocListener`.
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ApiService _api;

  ProjectsBloc(this._api) : super(const ProjectsInitial()) {
    on<ProjectsRequested>(_onProjectsRequested);
  }

  // Mirrors _ProjectsState.getProjects()
  Future<void> _onProjectsRequested(
      ProjectsRequested event, Emitter<ProjectsState> emit) async {
    emit(const ProjectsLoading());
    try {
      final response = await _api.projects(Strings.userID!);
      if (response.status!) {
        emit(ProjectsLoaded(response.data!));
        if (Strings.isPushAvailable == true) {
          Strings.isPushAvailable = false;
          await _getUserCats(Strings.selectedProject[0].projectId, emit);
        }
      } else {
        emit(ProjectsEmpty(response.message!));
        if (Strings.isPushAvailable == true) {
          Strings.isPushAvailable = false;
          await _getUserCats(Strings.selectedProject[0].projectId, emit);
        }
      }
    } catch (onError) {
      emit(const ProjectsLoadError());
      print(onError.toString());
    }
  }

  // Mirrors _ProjectsState.getUserCats() — only reached via the push auto-open
  // branch above. Preserves the original quirk that a failed `fetchUsers`
  // (status == false) leaves the spinner up (no dismissing state is emitted).
  Future<void> _getUserCats(proId, Emitter<ProjectsState> emit) async {
    emit(const ProjectCommentsLoading());
    try {
      final response = await _api.fetchUsers(proId);
      if (response.status!) {
        Strings.users = response.data!;
        try {
          final catResponse = await _api.fetchCats(proId);
          if (catResponse.status!) {
            Strings.categories = catResponse.data!;
            emit(const ProjectCommentsReady());
          } else {
            print('error');
            emit(const ProjectCommentsDismissed());
          }
        } catch (onError) {
          print(onError.toString());
          emit(const ProjectCommentsDismissed());
        }
      } else {
        print('error');
        // Original does NOT dismiss the spinner on a failed fetchUsers; keep it.
      }
    } catch (onError) {
      print(onError.toString());
      emit(const ProjectCommentsDismissed());
    }
  }
}
