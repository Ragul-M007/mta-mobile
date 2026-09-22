import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'comments_event.dart';
part 'comments_state.dart';

/// BLoC for the (document) Comments screen. Owns the Socket.IO lifecycle
/// (connect, the `document-comments` stream, the `create-document-comment`
/// emit, the reconnect-after-delete/audio) and the REST calls (fetchUsers,
/// getProjectName, fetchCats, removeComment, uploadAudio,
/// updateNotificationStatus).
///
/// Behavior-preserving MOVE. The `document-comments` receive-handler builds
/// `Strings.comments` + scroll UI, so the bloc FORWARDS the raw payload via
/// [CommentsDocLoaded] and the widget's listener builds it (verbatim, keeping
/// the `initialCommentCheck` guard widget-side). Socket callbacks feed internal
/// events guarded by `isClosed`. Reconnect-on-connect emits
/// [CommentsReconnectedState] so the widget re-subscribes + does its UI. close()
/// disposes the socket (matching the original dispose()).
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final ApiService _api;

  IO.Socket? _socket;
  int? _documentId;

  CommentsBloc(this._api) : super(CommentsInitial()) {
    on<CommentsSocketInit>(_onSocketInit);
    on<CommentsSubscribe>(_onSubscribe);
    on<CommentsUserCatsRequested>(_onUserCats);
    on<CommentsProjectRequested>(_onProject);
    on<CommentsCatsRequested>(_onCats);
    on<CommentsRemoveRequested>(_onRemove);
    on<CommentsAudioRequested>(_onAudio);
    on<CommentsPostEmit>(_onPostEmit);
    on<CommentsNotificationUpdate>(_onNotification);
    on<CommentsDocReceived>(_onDocReceived);
    on<CommentsConnectedInternal>(_onConnectedInternal);
    on<CommentsReconnectedInternal>(_onReconnectedInternal);
  }

  // Mirrors the socket setup in initState()
  Future<void> _onSocketInit(
      CommentsSocketInit event, Emitter<CommentsState> emit) async {
    _documentId = event.documentId;
    _socket = IO.io(Strings.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'token': Strings.authToken,
        "document_id": _documentId,
        'forceNew': false,
      }
    });
    _socket?.connect();
    _socket?.onConnect((_) {
      print('connect');
    });
    print("connection established");
    _socket?.on("connect", (_) {
      print('Connected');
      print("Calling function");
      if (!isClosed) add(const CommentsConnectedInternal());
    });
  }

  Future<void> _onConnectedInternal(
      CommentsConnectedInternal event, Emitter<CommentsState> emit) async {
    emit(CommentsConnectedState());
  }

  // Mirrors getComments() — register the document-comments handler
  Future<void> _onSubscribe(
      CommentsSubscribe event, Emitter<CommentsState> emit) async {
    print("Getting comments");
    _socket?.on("document-comments", (_data) {
      if (!isClosed) add(CommentsDocReceived(_data));
    });
  }

  Future<void> _onDocReceived(
      CommentsDocReceived event, Emitter<CommentsState> emit) async {
    emit(CommentsDocLoaded(event.data));
  }

  // Mirrors getUserCats()
  Future<void> _onUserCats(
      CommentsUserCatsRequested event, Emitter<CommentsState> emit) async {
    try {
      final response = await _api.fetchUsers(event.projectId);
      if (response.status!) {
        emit(CommentsUserCatsLoaded(response.data!));
      } else {
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(CommentsDismiss());
    }
  }

  // Mirrors getProjectDetails()
  Future<void> _onProject(
      CommentsProjectRequested event, Emitter<CommentsState> emit) async {
    print("project details called");
    try {
      final response = await _api.getProjectName(event.projectId);
      if (response.status!) {
        print("project name ---> {response.data![0].projectName}");
        emit(CommentsProjectLoaded(response.data![0].projectName ?? ""));
      } else {
        print('No categories');
      }
    } catch (onError) {
      print("Catched $onError");
      emit(CommentsDismiss());
    }
  }

  // Mirrors getuserCatgories()
  Future<void> _onCats(
      CommentsCatsRequested event, Emitter<CommentsState> emit) async {
    try {
      final response = await _api.fetchCats(event.projectId);
      if (response.status!) {
        emit(CommentsCatsLoaded(response.data!));
      } else {
        emit(CommentsDismiss());
        print('No categories');
      }
    } catch (onError) {
      print("Catched $onError");
      emit(CommentsDismiss());
    }
  }

  // Mirrors the removeComment delete-dialog action
  Future<void> _onRemove(
      CommentsRemoveRequested event, Emitter<CommentsState> emit) async {
    emit(CommentsRemoveLoading());
    try {
      final response = await _api.removeComment(event.commentId);
      if (response.status!) {
        emit(CommentsRemoveOk());
        _reconnect(audioUi: false);
      } else {
        emit(CommentsRemoveFail());
        print("delete failed");
      }
    } catch (onError) {
      print(onError.toString());
      emit(CommentsRemoveError());
    }
  }

  // Mirrors sendAudio()'s uploadAudio portion
  Future<void> _onAudio(
      CommentsAudioRequested event, Emitter<CommentsState> emit) async {
    try {
      final response = await _api.uploadAudio(event.req);
      if (response.status!) {
        emit(CommentsAudioOk());
        _reconnect(audioUi: true);
      } else {
        emit(CommentsAudioFail(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(CommentsAudioError());
    }
  }

  // Mirrors the disconnect + connect + on("connect") reconnect pattern
  void _reconnect({required bool audioUi}) {
    _socket?.disconnect();
    _socket?.connect();
    _socket?.on("connect", (_) {
      print('Connected');
      if (!isClosed) add(CommentsReconnectedInternal(audioUi));
    });
  }

  Future<void> _onReconnectedInternal(
      CommentsReconnectedInternal event, Emitter<CommentsState> emit) async {
    emit(CommentsReconnectedState(event.audioUi));
  }

  // Mirrors postComments()'s socket emit
  Future<void> _onPostEmit(
      CommentsPostEmit event, Emitter<CommentsState> emit) async {
    _socket?.emit('create-document-comment', json.encode(event.payload));
  }

  // Mirrors updateNotification()
  Future<void> _onNotification(
      CommentsNotificationUpdate event, Emitter<CommentsState> emit) async {
    try {
      final response =
          await _api.updateNotificationStatus(event.notificationId);
      if (response.status!) {
        // AppUtils.showToastError("Unable to update status");
      } else {
        emit(CommentsNotifFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(CommentsNotifError());
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
