import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/ChatView/models/AddRemoveUserReq.dart';
import 'package:mta/models/Chat/GroupUsersRes.dart';
import 'package:mta/network/ApiService.dart';

part 'remove_users_event.dart';
part 'remove_users_state.dart';

/// BLoC for the Remove-Users-In-Group screen (2 flows: getUsersByGroupId /
/// getChatUsers, removeUsersToGroupApiCall / removeUsersintoGroup).
///
/// Behavior-preserving extraction: the BLoC keeps the API calls and `print`
/// logging; the widget's listener performs the UI side effects (spinner, toast,
/// the chatUsers setState + selection loop, navigation). States are
/// command-style (not Equatable).
///
/// Quirk preserved: the getChatUsers `status == false` path shows a toast but
/// does NOT dismiss the spinner (mirrors [RemoveUsersLoadFailed]).
class RemoveUsersBloc extends Bloc<RemoveUsersEvent, RemoveUsersState> {
  final ApiService _api;

  RemoveUsersBloc(this._api) : super(RemoveUsersInitial()) {
    on<RemoveUsersLoadRequested>(_onLoad);
    on<RemoveUsersSubmitted>(_onSubmit);
  }

  // Mirrors getUsersByGroupId()
  Future<void> _onLoad(
      RemoveUsersLoadRequested event, Emitter<RemoveUsersState> emit) async {
    emit(RemoveUsersLoading());
    try {
      final response = await _api.getChatUsers(event.groupId);
      if (response.status!) {
        emit(RemoveUsersLoaded(response.data!));
      } else {
        emit(RemoveUsersLoadFailed());
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(RemoveUsersLoadError(onError.toString()));
    }
  }

  // Mirrors removeUsersToGroupApiCall()
  Future<void> _onSubmit(
      RemoveUsersSubmitted event, Emitter<RemoveUsersState> emit) async {
    print("req  ${jsonEncode(event.req)}");
    try {
      final response = await _api.removeUsersintoGroup(event.req);
      if (response.status!) {
        emit(RemoveUsersRemoveSuccess(response.message));
      } else {
        print('error');
        emit(RemoveUsersRemoveFailed(response.message));
      }
    } catch (onError) {
      print(onError.toString());
      emit(RemoveUsersRemoveError());
    }
  }
}
