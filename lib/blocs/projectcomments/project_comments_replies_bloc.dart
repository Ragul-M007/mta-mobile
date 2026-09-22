import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'project_comments_replies_event.dart';
part 'project_comments_replies_state.dart';

/// BLoC for the Project-Comment Replies screen. The PROJECT-level reply variant:
/// socket query uses `project_id`, the receive event is `project-comments`, and
/// the emit is `create-project-comment` via `emitWithAck` (with parent_comment_id
/// built by the widget). Behavior-preserving MOVE — the `project-comments`
/// payload is forwarded via [ProjectCommentsRepliesDocLoaded] and the widget
/// builds `Strings.comments` verbatim (the `initialCommentCheck` guard stays
/// widget-side). close() disposes the socket (matching dispose()).
class ProjectCommentsRepliesBloc
    extends Bloc<ProjectCommentsRepliesEvent, ProjectCommentsRepliesState> {
  final ApiService _api;

  IO.Socket? _socket;
  int? _projectId;

  ProjectCommentsRepliesBloc(this._api)
      : super(ProjectCommentsRepliesInitial()) {
    on<ProjectCommentsRepliesSocketInit>(_onSocketInit);
    on<ProjectCommentsRepliesSubscribe>(_onSubscribe);
    on<ProjectCommentsRepliesUserCatsRequested>(_onUserCats);
    on<ProjectCommentsRepliesProjectRequested>(_onProject);
    on<ProjectCommentsRepliesCatsRequested>(_onCats);
    on<ProjectCommentsRepliesRemoveRequested>(_onRemove);
    on<ProjectCommentsRepliesAudioRequested>(_onAudio);
    on<ProjectCommentsRepliesPostEmit>(_onPostEmit);
    on<ProjectCommentsRepliesNotificationUpdate>(_onNotification);
    on<ProjectCommentsRepliesDisconnect>(_onDisconnect);
    on<ProjectCommentsRepliesDocReceived>(_onDocReceived);
    on<ProjectCommentsRepliesConnectedInternal>(_onConnectedInternal);
    on<ProjectCommentsRepliesReconnectedInternal>(_onReconnectedInternal);
  }

  // Mirrors the socket setup in initState()
  Future<void> _onSocketInit(ProjectCommentsRepliesSocketInit event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    _projectId = event.projectId;
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'token': Strings.authToken, "project_id": _projectId}
    });
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected init');
      if (!isClosed) add(const ProjectCommentsRepliesConnectedInternal());
    });
    _socket?.onDisconnect((_) => print('Connected dis'));
  }

  Future<void> _onConnectedInternal(ProjectCommentsRepliesConnectedInternal event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    emit(ProjectCommentsRepliesConnectedState());
  }

  // Mirrors getReplies() — register the project-comments handler
  Future<void> _onSubscribe(ProjectCommentsRepliesSubscribe event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    print("Getting replied");
    _socket?.on("project-comments", (_data) {
      if (!isClosed) add(ProjectCommentsRepliesDocReceived(_data));
    });
  }

  Future<void> _onDocReceived(ProjectCommentsRepliesDocReceived event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    emit(ProjectCommentsRepliesDocLoaded(event.data));
  }

  // Mirrors getUserCats()
  Future<void> _onUserCats(ProjectCommentsRepliesUserCatsRequested event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    try {
      final response = await _api.fetchUsers(event.projectId);
      if (response.status!) {
        emit(ProjectCommentsRepliesUserCatsLoaded(response.data!));
      } else {
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProjectCommentsRepliesDismiss());
    }
  }

  // Mirrors getProjectDetails()
  Future<void> _onProject(ProjectCommentsRepliesProjectRequested event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    print("project details called");
    try {
      final response = await _api.getProjectName(event.projectId);
      if (response.status!) {
        print("project name ---> {response.data![0].projectName}");
        emit(ProjectCommentsRepliesProjectLoaded(
            response.data![0].projectName ?? ""));
      } else {
        print('No categories');
      }
    } catch (onError) {
      print("Catched $onError");
      emit(ProjectCommentsRepliesDismiss());
    }
  }

  // Mirrors getuserCatgories()
  Future<void> _onCats(ProjectCommentsRepliesCatsRequested event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    try {
      final response = await _api.fetchCats(event.projectId);
      if (response.status!) {
        emit(ProjectCommentsRepliesCatsLoaded(response.data!));
      } else {
        emit(ProjectCommentsRepliesDismiss());
        print('No categories');
      }
    } catch (onError) {
      print("Catched $onError");
      emit(ProjectCommentsRepliesDismiss());
    }
  }

  // Mirrors the removeComment delete-dialog action
  Future<void> _onRemove(ProjectCommentsRepliesRemoveRequested event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    emit(ProjectCommentsRepliesRemoveLoading());
    try {
      final response = await _api.removeComment(event.commentId);
      if (response.status!) {
        emit(ProjectCommentsRepliesRemoveOk());
        _reconnect(audioUi: false);
      } else {
        emit(ProjectCommentsRepliesRemoveFail());
        print("delete failed");
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProjectCommentsRepliesRemoveError());
    }
  }

  // Mirrors sendAudio()'s uploadAudio portion
  Future<void> _onAudio(ProjectCommentsRepliesAudioRequested event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    try {
      final response = await _api.uploadAudio(event.req);
      if (response.status!) {
        emit(ProjectCommentsRepliesAudioOk());
        _reconnect(audioUi: true);
      } else {
        emit(ProjectCommentsRepliesAudioFail(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProjectCommentsRepliesAudioError());
    }
  }

  // Mirrors the disconnect + connect + on("connect") reconnect pattern
  void _reconnect({required bool audioUi}) {
    _socket?.disconnect();
    _socket?.connect();
    _socket?.on("connect", (_) {
      if (!isClosed) add(ProjectCommentsRepliesReconnectedInternal(audioUi));
    });
  }

  Future<void> _onReconnectedInternal(
      ProjectCommentsRepliesReconnectedInternal event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    emit(ProjectCommentsRepliesReconnectedState(event.audioUi));
  }

  // Mirrors postReplies()'s socket emitWithAck
  Future<void> _onPostEmit(ProjectCommentsRepliesPostEmit event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    _socket?.emitWithAck(
        'create-project-comment', json.encode(event.payload), ack: (datal) {
      print('ack $datal');
      if (datal != null) {
        print('from server $datal');
      } else {
        print("Null");
      }
    });
  }

  // Mirrors updateNotification()
  Future<void> _onNotification(ProjectCommentsRepliesNotificationUpdate event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    try {
      final response =
          await _api.updateNotificationStatus(event.notificationId);
      if (response.status!) {
        // AppUtils.showToastError("Unable to update status");
      } else {
        emit(ProjectCommentsRepliesNotifFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProjectCommentsRepliesNotifError());
    }
  }

  // Mirrors the attach-file onTap `_socket?.disconnect()`
  Future<void> _onDisconnect(ProjectCommentsRepliesDisconnect event,
      Emitter<ProjectCommentsRepliesState> emit) async {
    _socket?.disconnect();
  }

  @override
  Future<void> close() {
    _socket?.disconnect();
    _socket?.dispose();
    return super.close();
  }
}
