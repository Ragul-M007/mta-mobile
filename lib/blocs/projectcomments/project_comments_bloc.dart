import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'project_comments_event.dart';
part 'project_comments_state.dart';

/// BLoC for the Project-Comments screen. Same shape as CommentsBloc, but the
/// PROJECT-level variant: socket query uses `project_id`, the receive event is
/// `project-comments`, and the emit event is `create-project-comment`.
/// Behavior-preserving MOVE — the `project-comments` payload is forwarded via
/// [ProjectCommentsDocLoaded] and the widget builds `Strings.comments` verbatim
/// (the `initialCommentCheck` guard stays widget-side). close() disposes the
/// socket (matching dispose()).
class ProjectCommentsBloc
    extends Bloc<ProjectCommentsEvent, ProjectCommentsState> {
  final ApiService _api;

  IO.Socket? _socket;
  int? _projectId;

  ProjectCommentsBloc(this._api) : super(ProjectCommentsInitial()) {
    on<ProjectCommentsSocketInit>(_onSocketInit);
    on<ProjectCommentsSubscribe>(_onSubscribe);
    on<ProjectCommentsUserCatsRequested>(_onUserCats);
    on<ProjectCommentsProjectRequested>(_onProject);
    on<ProjectCommentsCatsRequested>(_onCats);
    on<ProjectCommentsRemoveRequested>(_onRemove);
    on<ProjectCommentsAudioRequested>(_onAudio);
    on<ProjectCommentsPostEmit>(_onPostEmit);
    on<ProjectCommentsNotificationUpdate>(_onNotification);
    on<ProjectCommentsDocReceived>(_onDocReceived);
    on<ProjectCommentsConnectedInternal>(_onConnectedInternal);
    on<ProjectCommentsReconnectedInternal>(_onReconnectedInternal);
  }

  // Mirrors the socket setup in initState()
  Future<void> _onSocketInit(
      ProjectCommentsSocketInit event, Emitter<ProjectCommentsState> emit) async {
    _projectId = event.projectId;
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'token': Strings.authToken,
        "project_id": _projectId,
        'forceNew': false,
      }
    });
    _socket?.connect();
    _socket?.onConnect((_) {
      print('connect');
    });
    _socket?.on("connect", (_) {
      print('Connected');
      print("Calling function");
      if (!isClosed) add(const ProjectCommentsConnectedInternal());
    });
  }

  Future<void> _onConnectedInternal(ProjectCommentsConnectedInternal event,
      Emitter<ProjectCommentsState> emit) async {
    emit(ProjectCommentsConnectedState());
  }

  // Mirrors getComments() — register the project-comments handler
  Future<void> _onSubscribe(
      ProjectCommentsSubscribe event, Emitter<ProjectCommentsState> emit) async {
    print("Getting comments");
    _socket?.on("project-comments", (_data) {
      if (!isClosed) add(ProjectCommentsDocReceived(_data));
    });
  }

  Future<void> _onDocReceived(
      ProjectCommentsDocReceived event, Emitter<ProjectCommentsState> emit) async {
    emit(ProjectCommentsDocLoaded(event.data));
  }

  // Mirrors getUserCats()
  Future<void> _onUserCats(ProjectCommentsUserCatsRequested event,
      Emitter<ProjectCommentsState> emit) async {
    try {
      final response = await _api.fetchUsers(event.projectId);
      if (response.status!) {
        emit(ProjectCommentsUserCatsLoaded(response.data!));
      } else {
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProjectCommentsDismiss());
    }
  }

  // Mirrors getProjectDetails()
  Future<void> _onProject(ProjectCommentsProjectRequested event,
      Emitter<ProjectCommentsState> emit) async {
    print("project details called");
    try {
      final response = await _api.getProjectName(event.projectId);
      if (response.status!) {
        print("project name ---> {response.data![0].projectName}");
        emit(ProjectCommentsProjectLoaded(response.data![0].projectName ?? ""));
      } else {
        print('No categories');
      }
    } catch (onError) {
      print("Catched $onError");
      emit(ProjectCommentsDismiss());
    }
  }

  // Mirrors getuserCatgories()
  Future<void> _onCats(
      ProjectCommentsCatsRequested event, Emitter<ProjectCommentsState> emit) async {
    try {
      final response = await _api.fetchCats(event.projectId);
      if (response.status!) {
        emit(ProjectCommentsCatsLoaded(response.data!));
      } else {
        emit(ProjectCommentsDismiss());
        print('No categories');
      }
    } catch (onError) {
      print("Catched $onError");
      emit(ProjectCommentsDismiss());
    }
  }

  // Mirrors the removeComment delete-dialog action
  Future<void> _onRemove(
      ProjectCommentsRemoveRequested event, Emitter<ProjectCommentsState> emit) async {
    emit(ProjectCommentsRemoveLoading());
    try {
      final response = await _api.removeComment(event.commentId);
      if (response.status!) {
        emit(ProjectCommentsRemoveOk());
        _reconnect(audioUi: false);
      } else {
        emit(ProjectCommentsRemoveFail());
        print("delete failed");
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProjectCommentsRemoveError());
    }
  }

  // Mirrors sendAudio()'s uploadAudio portion
  Future<void> _onAudio(
      ProjectCommentsAudioRequested event, Emitter<ProjectCommentsState> emit) async {
    try {
      final response = await _api.uploadAudio(event.req);
      if (response.status!) {
        emit(ProjectCommentsAudioOk());
        _reconnect(audioUi: true);
      } else {
        emit(ProjectCommentsAudioFail(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProjectCommentsAudioError());
    }
  }

  // Mirrors the disconnect + connect + on("connect") reconnect pattern
  void _reconnect({required bool audioUi}) {
    _socket?.disconnect();
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected');
      if (!isClosed) add(ProjectCommentsReconnectedInternal(audioUi));
    });
  }

  Future<void> _onReconnectedInternal(ProjectCommentsReconnectedInternal event,
      Emitter<ProjectCommentsState> emit) async {
    emit(ProjectCommentsReconnectedState(event.audioUi));
  }

  // Mirrors postComments()'s socket emit
  Future<void> _onPostEmit(
      ProjectCommentsPostEmit event, Emitter<ProjectCommentsState> emit) async {
    _socket?.emit('create-project-comment', json.encode(event.payload));
  }

  // Mirrors updateNotification()
  Future<void> _onNotification(ProjectCommentsNotificationUpdate event,
      Emitter<ProjectCommentsState> emit) async {
    try {
      final response =
          await _api.updateNotificationStatus(event.notificationId);
      if (response.status!) {
        // AppUtils.showToastError("Unable to update status");
      } else {
        emit(ProjectCommentsNotifFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProjectCommentsNotifError());
    }
  }

  @override
  Future<void> close() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    return super.close();
  }
}
