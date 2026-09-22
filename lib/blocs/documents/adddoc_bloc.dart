import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/AddDocReq.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/UserAccessreq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';

part 'adddoc_event.dart';
part 'adddoc_state.dart';

/// BLoC for the Add-Document screen (3 flows: getUserCats/fetchUsers,
/// submit/addDoc, UpdateRights/userAccess).
///
/// Behavior-preserving extraction following the established pattern: the BLoC
/// keeps the API calls, `Strings` reads and `print` logging; the widget's
/// listener performs the UI side effects (spinner, toast, navigation, the
/// globals setState, the post-submit `UpdateRights()` chain). States are
/// command-style (not Equatable).
///
/// `UpdateRights` (userAccess) is a fire-and-forget PUT the original fired
/// *after* navigating away, with no UI effect. Its handler therefore emits no
/// state (only the original `print`) so it is immune to the screen's dispose().
class AddDocBloc extends Bloc<AddDocEvent, AddDocState> {
  final ApiService _api;

  AddDocBloc(this._api) : super(AddDocInitial()) {
    on<AddDocUsersRequested>(_onUsersRequested);
    on<AddDocSubmitted>(_onSubmitted);
    on<AddDocRightsRequested>(_onRightsRequested);
  }

  // Mirrors getUserCats()
  Future<void> _onUsersRequested(
      AddDocUsersRequested event, Emitter<AddDocState> emit) async {
    try {
      final response =
          await _api.fetchUsers(Strings.selectedProject[0].projectId!);
      if (response.status!) {
        emit(AddDocUsersLoaded(response.data!));
      } else {
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(AddDocErrorDismiss());
    }
  }

  // Mirrors the api.addDoc(...) portion of submit()
  Future<void> _onSubmitted(
      AddDocSubmitted event, Emitter<AddDocState> emit) async {
    emit(AddDocSubmitLoading());
    try {
      final response = await _api.addDoc(event.req);
      if (response.status!) {
        emit(AddDocSubmitSuccess(response.data?[0].documentId));
      } else {
        emit(AddDocFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(AddDocErrorDismiss());
    }
  }

  // Mirrors the api.userAccess(...) portion of UpdateRights()
  Future<void> _onRightsRequested(
      AddDocRightsRequested event, Emitter<AddDocState> emit) async {
    try {
      final response = await _api.userAccess(event.users, event.req);
      print(response.message);
      if (response.status!) {
      } else {}
    } catch (onError) {
      print(onError.toString());
    }
  }
}
