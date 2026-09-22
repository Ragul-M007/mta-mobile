import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'replies_event.dart';
part 'replies_state.dart';

/// BLoC for the (document comment) Replies screen. Same shape as [CommentsBloc]:
/// owns the Socket.IO lifecycle (connect, the `document-comments` stream, the
/// `create-document-comment` emit, reconnect-after-delete/audio, plus the
/// attach-file disconnect) and the REST calls. Behavior-preserving MOVE — the
/// `document-comments` receive-handler is forwarded via [RepliesDocLoaded] and
/// the widget builds `Strings.comments` verbatim (the `initialCommentCheck`
/// guard stays widget-side). close() disposes the socket (matching dispose()).
class RepliesBloc extends Bloc<RepliesEvent, RepliesState> {
  final ApiService _api;

  IO.Socket? _socket;
  int? _documentId;

  RepliesBloc(this._api) : super(RepliesInitial()) {
    on<RepliesSocketInit>(_onSocketInit);
    on<RepliesSubscribe>(_onSubscribe);
    on<RepliesUserCatsRequested>(_onUserCats);
    on<RepliesProjectRequested>(_onProject);
    on<RepliesCatsRequested>(_onCats);
    on<RepliesRemoveRequested>(_onRemove);
    on<RepliesAudioRequested>(_onAudio);
    on<RepliesPostEmit>(_onPostEmit);
    on<RepliesNotificationUpdate>(_onNotification);
    on<RepliesDisconnect>(_onDisconnect);
    on<RepliesDocReceived>(_onDocReceived);
    on<RepliesConnectedInternal>(_onConnectedInternal);
    on<RepliesReconnectedInternal>(_onReconnectedInternal);
  }

  // Mirrors the socket setup in initState()
  Future<void> _onSocketInit(
      RepliesSocketInit event, Emitter<RepliesState> emit) async {
    _documentId = event.documentId;
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'token': Strings.authToken, "document_id": _documentId}
    });
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected');
      if (!isClosed) add(const RepliesConnectedInternal());
    });
  }

  Future<void> _onConnectedInternal(
      RepliesConnectedInternal event, Emitter<RepliesState> emit) async {
    emit(RepliesConnectedState());
  }

  // Mirrors getReplies() — register the document-comments handler
  Future<void> _onSubscribe(
      RepliesSubscribe event, Emitter<RepliesState> emit) async {
    print("Getting replied");
    _socket?.on("document-comments", (_data) {
      if (!isClosed) add(RepliesDocReceived(_data));
    });
  }

  Future<void> _onDocReceived(
      RepliesDocReceived event, Emitter<RepliesState> emit) async {
    emit(RepliesDocLoaded(event.data));
  }

  // Mirrors getUserCats()
  Future<void> _onUserCats(
      RepliesUserCatsRequested event, Emitter<RepliesState> emit) async {
    try {
      final response = await _api.fetchUsers(event.projectId);
      if (response.status!) {
        emit(RepliesUserCatsLoaded(response.data!));
      } else {
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(RepliesDismiss());
    }
  }

  // Mirrors getProjectDetails()
  Future<void> _onProject(
      RepliesProjectRequested event, Emitter<RepliesState> emit) async {
    print("project details called");
    try {
      final response = await _api.getProjectName(event.projectId);
      if (response.status!) {
        print("project name ---> {response.data![0].projectName}");
        emit(RepliesProjectLoaded(response.data![0].projectName ?? ""));
      } else {
        print('No categories');
      }
    } catch (onError) {
      print("Catched $onError");
      emit(RepliesDismiss());
    }
  }

  // Mirrors getuserCatgories()
  Future<void> _onCats(
      RepliesCatsRequested event, Emitter<RepliesState> emit) async {
    try {
      final response = await _api.fetchCats(event.projectId);
      if (response.status!) {
        emit(RepliesCatsLoaded(response.data!));
      } else {
        emit(RepliesDismiss());
        print('No categories');
      }
    } catch (onError) {
      print("Catched $onError");
      emit(RepliesDismiss());
    }
  }

  // Mirrors the removeComment delete-dialog action
  Future<void> _onRemove(
      RepliesRemoveRequested event, Emitter<RepliesState> emit) async {
    emit(RepliesRemoveLoading());
    try {
      final response = await _api.removeComment(event.commentId);
      if (response.status!) {
        emit(RepliesRemoveOk());
        _reconnect(audioUi: false);
      } else {
        emit(RepliesRemoveFail());
        print("delete failed");
      }
    } catch (onError) {
      print(onError.toString());
      emit(RepliesRemoveError());
    }
  }

  // Mirrors sendAudio()'s uploadAudio portion
  Future<void> _onAudio(
      RepliesAudioRequested event, Emitter<RepliesState> emit) async {
    try {
      final response = await _api.uploadAudio(event.req);
      if (response.status!) {
        emit(RepliesAudioOk());
        _reconnect(audioUi: true);
      } else {
        emit(RepliesAudioFail(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(RepliesAudioError());
    }
  }

  // Mirrors the disconnect + connect + on("connect") reconnect pattern
  void _reconnect({required bool audioUi}) {
    _socket?.disconnect();
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected');
      if (!isClosed) add(RepliesReconnectedInternal(audioUi));
    });
  }

  Future<void> _onReconnectedInternal(
      RepliesReconnectedInternal event, Emitter<RepliesState> emit) async {
    emit(RepliesReconnectedState(event.audioUi));
  }

  // Mirrors postReplies()'s socket emit
  Future<void> _onPostEmit(
      RepliesPostEmit event, Emitter<RepliesState> emit) async {
    _socket?.emit('create-document-comment', json.encode(event.payload));
  }

  // Mirrors updateNotification()
  Future<void> _onNotification(
      RepliesNotificationUpdate event, Emitter<RepliesState> emit) async {
    try {
      final response =
          await _api.updateNotificationStatus(event.notificationId);
      if (response.status!) {
        // AppUtils.showToastError("Unable to update status");
      } else {
        emit(RepliesNotifFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(RepliesNotifError());
    }
  }

  // Mirrors the attach-file onTap `_socket?.disconnect()`
  Future<void> _onDisconnect(
      RepliesDisconnect event, Emitter<RepliesState> emit) async {
    _socket?.disconnect();
  }

  @override
  Future<void> close() {
    _socket?.disconnect();
    _socket?.dispose();
    return super.close();
  }
}
