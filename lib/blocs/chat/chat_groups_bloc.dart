import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/Chat/GroupChatListRes.dart';
import 'package:mta/models/Chat/GroupCreationReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'chat_groups_event.dart';
part 'chat_groups_state.dart';

/// BLoC for the Chat-Groups list screen. Owns the REST calls
/// (fetchChatCreateAcess → getAccessDetails, createGroup → checkGroupName) and
/// the Socket.IO lifecycle (connect + the `all-groups` group-list stream).
///
/// Behavior-preserving MOVE. The socket's `all-groups` callback fires outside
/// any bloc event handler, so it feeds an internal [ChatGroupsAllGroupsReceived]
/// event (guarded by `isClosed`, mirroring the original `if (mounted)` guard)
/// which the handler turns into a state. The widget's listener performs the UI
/// side effects (setState of `groupList`/`loading`, spinner, toast, navigation).
///
/// NOTE: like the original, the socket is never disposed (close() leaves it),
/// and re-dispatching [ChatGroupsConnect] creates a fresh socket (the original
/// re-called connectSocket() on whenComplete). `_projectId`/`_teamId` come from
/// [ChatGroupsConnect].
class ChatGroupsBloc extends Bloc<ChatGroupsEvent, ChatGroupsState> {
  final ApiService _api;

  IO.Socket? _socket;
  int? _projectId;
  int? _teamId;

  ChatGroupsBloc(this._api) : super(ChatGroupsInitial()) {
    on<ChatGroupsAccessRequested>(_onAccess);
    on<ChatGroupsConnect>(_onConnect);
    on<ChatGroupsAllGroupsReceived>(_onAllGroups);
    on<ChatGroupsCreateRequested>(_onCreate);
  }

  // Mirrors fetchChatCreateAcess()
  Future<void> _onAccess(
      ChatGroupsAccessRequested event, Emitter<ChatGroupsState> emit) async {
    try {
      final response = await _api.getAccessDetails();
      if (response.status!) {
        emit(ChatGroupsAccessLoaded(response.data!.groupCreateAccess));
      }
    } catch (onError) {
      print(onError.toString());
      //getProjects();
    }
  }

  // Mirrors connectSocket()
  Future<void> _onConnect(
      ChatGroupsConnect event, Emitter<ChatGroupsState> emit) async {
    _projectId = event.projectId;
    _teamId = event.teamId;
    print("teamid ${_teamId}  projectid ${_projectId}");
    print("trying to connect socket");
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': false,
      'query': {
        'token': Strings.authToken,
        "group_type": _projectId == null ? "team" : "project",
        "project_group_id": _projectId,
        "team_id": _teamId
      }
    });
    _socket?.connect();
    _socket?.onConnect((_) {
      print('connect');
    });
    _socket?.on("connect", (_) {
      print('Connected');
      print("Calling function");
      _registerAllGroups();
    });
  }

  // Mirrors getChats()
  void _registerAllGroups() {
    _socket?.on("all-groups", (_data) {
      print("dataa from all groups $_data");
      if (!isClosed) add(ChatGroupsAllGroupsReceived(_data));
    });
  }

  Future<void> _onAllGroups(ChatGroupsAllGroupsReceived event,
      Emitter<ChatGroupsState> emit) async {
    var formattedRes = GroupListRes.fromJson(event.data);

    if (formattedRes.userId == Strings.userID &&
        ((formattedRes.projectId != null &&
                formattedRes.projectId == _projectId) ||
            (formattedRes.teamId != null && formattedRes.teamId == _teamId))) {
      final items = <GroupDetails>[];
      for (var item in formattedRes.groupDetails ?? []) {
        items.add(item);
      }
      emit(ChatGroupsLoaded(items));
    } else {
      print("else");
      emit(ChatGroupsLoadedNoMatch());
    }
  }

  // Mirrors the api.checkGroupName(...) portion of createGroup()
  Future<void> _onCreate(
      ChatGroupsCreateRequested event, Emitter<ChatGroupsState> emit) async {
    emit(ChatGroupsCreateLoading());
    try {
      final response = await _api.checkGroupName(event.groupName);
      if (response.status!) {
        emit(ChatGroupsCreateOk(event.req));
      } else {
        emit(ChatGroupsCreateFailed(response.message ?? "Error"));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ChatGroupsCreateError(onError.toString()));
    }
  }
}
