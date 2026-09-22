import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/Chat/AddRemoveUserListRes.dart';
import 'package:mta/models/Chat/GroupCreationReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'add_users_event.dart';
part 'add_users_state.dart';

/// BLoC for the Add-Users-Into-Group screen. Owns BOTH the REST calls
/// (getUnlinkUsersByGroupId → getUsers/getUnlinkedUsers, createGroup) and the
/// Socket.IO lifecycle (connect, `join-group`, `add-users-into-group` emits).
///
/// Behavior-preserving MOVE of the socket + API logic verbatim. The widget's
/// listener performs the UI side effects (spinner, toast, the chatUsers
/// setState + selection loop, navigation). States are command-style (not
/// Equatable).
///
/// NOTE on the socket: the original screen NEVER disposed the socket, and it
/// emits `add-users-into-group` immediately before `Navigator.pop`. Disposing
/// the socket on close() could drop that queued emit, so — matching the
/// original — [close] does NOT dispose `_socket` (the connection lingers, as it
/// did before). `_groupId` is mutable: set at init and updated on createGroup
/// success (the original mutated `widget.groupId`).
class AddUsersBloc extends Bloc<AddUsersEvent, AddUsersState> {
  final ApiService _api;

  IO.Socket? _socket;
  int? _groupId;
  int? _projectId;
  int? _teamId;

  AddUsersBloc(this._api) : super(AddUsersInitial()) {
    on<AddUsersSocketInit>(_onSocketInit);
    on<AddUsersLoadRequested>(_onLoad);
    on<AddUsersSubmitRequested>(_onSubmit);
  }

  // Mirrors the socket setup in initState()
  Future<void> _onSocketInit(
      AddUsersSocketInit event, Emitter<AddUsersState> emit) async {
    _groupId = event.groupId;
    _projectId = event.projectId;
    _teamId = event.teamId;
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': false,
      'query': {
        'token': Strings.authToken,
        'group_id': _groupId,
        "group_type": _projectId == null ? "team" : "project",
        "project_id": _projectId,
        "team_id": _teamId
      }
    });
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected');
      _joinGroup();
    });
  }

  // Mirrors joinGroup()
  void _joinGroup() {
    _socket?.emit(
        'join-group',
        json.encode({
          "group_id": _groupId,
        }));
  }

  // Mirrors the socket emit in addUsersToGroupApiCall()
  void _emitAddUsers(List<int> selectedUsers) {
    print("dddtt ${jsonEncode(selectedUsers)}");
    _socket?.emit('add-users-into-group',
        json.encode({"group_id": _groupId, "user_id": selectedUsers}));
  }

  // Mirrors getUnlinkUsersByGroupId()
  Future<void> _onLoad(
      AddUsersLoadRequested event, Emitter<AddUsersState> emit) async {
    emit(AddUsersLoading());
    try {
      final AddUsersListRes response = event.fromCreateGroup == true
          ? await _api.getUsers(event.projectId == null ? "team" : "project",
              event.teamId, event.projectId)
          : await _api.getUnlinkedUsers(event.groupId!);
      if (response.status!) {
        emit(AddUsersLoaded(response.data!));
      } else {
        emit(AddUsersLoadFailed());
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(AddUsersLoadError(onError.toString()));
    }
  }

  // Mirrors updateSelectedUsers()'s branch (createGroup vs addUsersToGroupApiCall)
  Future<void> _onSubmit(
      AddUsersSubmitRequested event, Emitter<AddUsersState> emit) async {
    if (event.fromCreateGroup == true) {
      // Mirrors createGroup()
      emit(AddUsersCreateLoading());
      try {
        final response = await _api.createGroup(event.groupData!);
        if (response.status!) {
          _groupId = response.data!.groupId;
          _emitAddUsers(event.selectedUsers);
          emit(AddUsersCreatedNav(response.message ?? "Error"));
        } else {
          emit(AddUsersCreateFailed(response.message ?? "Error"));
        }
      } catch (onError) {
        print(onError.toString());
        emit(AddUsersCreateError(onError.toString()));
      }
    } else {
      _emitAddUsers(event.selectedUsers);
      emit(AddUsersAddedNav());
    }
  }
}
