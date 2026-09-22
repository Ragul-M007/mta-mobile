import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/Chat/ChatMessageWithPageCountRes.dart';
import 'package:mta/models/Chat/GroupUsersRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/GroupReq.dart';
import 'package:mta/models/GroupRes.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'chat_screen_event.dart';
part 'chat_screen_state.dart';

/// BLoC for the Chat screen. Owns the Socket.IO lifecycle (connect, join-group,
/// update-message-readed-user, create-message, forward-message; group-messages
/// + group-users-list streams), the ApiService REST calls, and the direct-Dio
/// file/audio upload.
///
/// Behavior-preserving MOVE. Because the socket receive-handlers build ChatView
/// `Message`/`ChatController`/`ChatUser` objects (UI-layer construction), the
/// bloc FORWARDS the raw socket payloads to the widget via
/// [ChatGroupMessagesSocket] / [ChatGroupUsersSocket] and the widget's listener
/// builds those objects — keeping UI construction in the widget. Socket
/// callbacks that must push UI feed internal events guarded by `isClosed`.
///
/// Matching the original screen, close() DOES dispose the socket
/// (`disconnect()` + `dispose()`). `joinGroup` is re-entrant (re-emits +
/// re-registers handlers) exactly as before, triggered on connect, and after a
/// delete or an upload.
class ChatScreenBloc extends Bloc<ChatScreenEvent, ChatScreenState> {
  final ApiService _api;
  final Dio _dio = Dio();

  IO.Socket? _socket;
  int? _groupId;
  int? _projectId;
  int? _teamId;

  ChatScreenBloc(this._api) : super(ChatInitial()) {
    on<ChatSocketInit>(_onSocketInit);
    on<ChatJoinRequested>(_onJoin);
    on<ChatUsersRequested>(_onUsers);
    on<ChatDeleteRequested>(_onDelete);
    on<ChatSendText>(_onSendText);
    on<ChatForwardEmit>(_onForwardEmit);
    on<ChatForwardListRequested>(_onForwardList);
    on<ChatReadUsersRequested>(_onReadUsers);
    on<ChatUploadRequested>(_onUpload);
    on<ChatGroupUsersReceived>(_onGroupUsersReceived);
    on<ChatGroupMessagesReceived>(_onGroupMessagesReceived);
  }

  // Mirrors the socket setup in initState()
  Future<void> _onSocketInit(
      ChatSocketInit event, Emitter<ChatScreenState> emit) async {
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
      if (!isClosed) add(const ChatJoinRequested());
    });
  }

  // Mirrors joinGroup()
  Future<void> _onJoin(
      ChatJoinRequested event, Emitter<ChatScreenState> emit) async {
    _socket?.emit(
        'join-group',
        json.encode({
          "group_id": _groupId,
        }));
    // updateUsersReadMessage()
    _socket?.emit(
        'update-message-readed-user',
        json.encode({
          "group_id": _groupId,
        }));
    // getMessages() — register the group-messages handler
    print("getting messages");
    _socket?.on("group-messages", (_data) {
      if (!isClosed) add(ChatGroupMessagesReceived(_data));
    });
    // getUsersList() — register the group-users-list handler
    _socket?.on("group-users-list", (_data) {
      if (!isClosed) add(ChatGroupUsersReceived(_data));
    });
  }

  Future<void> _onGroupMessagesReceived(
      ChatGroupMessagesReceived event, Emitter<ChatScreenState> emit) async {
    emit(ChatGroupMessagesSocket(event.data));
  }

  Future<void> _onGroupUsersReceived(
      ChatGroupUsersReceived event, Emitter<ChatScreenState> emit) async {
    emit(ChatGroupUsersSocket(event.data));
  }

  // Mirrors getUsersByGroupId()
  Future<void> _onUsers(
      ChatUsersRequested event, Emitter<ChatScreenState> emit) async {
    try {
      final response = await _api.getChatUsers(event.groupId);
      if (response.status!) {
        emit(ChatUsersLoaded(response.data ?? []));
      } else {
        print('error');
      }
    } catch (onError) {
      AppUtils.dismissprogress();
      print(onError.toString());
    }
  }

  // Mirrors deleteMessagesById()
  Future<void> _onDelete(
      ChatDeleteRequested event, Emitter<ChatScreenState> emit) async {
    try {
      final response = await _api.deleteMessage(event.msgId, event.grpId);
      if (response.status!) {
        emit(ChatDeleteOk(response.message ?? "Deleted Successfully"));
      } else {
        print('error');
        emit(ChatDeleteFail());
      }
    } catch (onError) {
      print(onError.toString());
      emit(ChatDeleteError());
    }
  }

  // Mirrors updateChat() — emit create-message
  Future<void> _onSendText(
      ChatSendText event, Emitter<ChatScreenState> emit) async {
    _socket?.emitWithAck(
        'create-message',
        json.encode({
          "message": event.msg,
          "group_id": _groupId,
          "user_id": Strings.userID,
          "parent_message_id": event.parentMsgId
        }), ack: (_data) {
      print("dataaa ${_data}");
    });
  }

  // Mirrors updateForwardMessage() — emit forward-message
  Future<void> _onForwardEmit(
      ChatForwardEmit event, Emitter<ChatScreenState> emit) async {
    _socket?.emitWithAck(
        'forward-message',
        json.encode({
          "document_id": event.documentIds,
          "receiver_group_id": event.receiverGroupIds,
          "sender_group_id": _groupId.toString(),
          "user_id": Strings.userID!.toString()
        }));
  }

  // Mirrors the api.fetchGroupList(...) portion of _onForwardTap()
  Future<void> _onForwardList(
      ChatForwardListRequested event, Emitter<ChatScreenState> emit) async {
    emit(ChatForwardListLoading());
    try {
      final response = await _api.fetchGroupList(event.req);
      if (response.status!) {
        emit(ChatForwardListLoaded(response.data!));
      } else {
        emit(ChatForwardListFailed(response.message!));
      }
    } catch (onError) {
      emit(ChatForwardListError());
    }
  }

  // Mirrors getReadUsers()
  Future<void> _onReadUsers(
      ChatReadUsersRequested event, Emitter<ChatScreenState> emit) async {
    try {
      final response = await _api.getReadedUsers(event.msgID);
      if (response.status!) {
        emit(ChatReadUsersLoaded(response.data ?? []));
      } else {
        emit(ChatReadUsersFailed(response.message ?? "Unknown Error"));
      }
    } catch (onError) {
      emit(ChatReadUsersError(onError.toString()));
    }
  }

  // Mirrors uploadFile()
  Future<void> _onUpload(
      ChatUploadRequested event, Emitter<ChatScreenState> emit) async {
    try {
      var myUrl = '${Strings.baseUrl}/chat/createMessage';
      var response = await _dio.post(
        myUrl,
        data: event.formData,
        onSendProgress: (received, total) {
          if (total != -1) {
            AppUtils.showUploadProgressWithPercent(received / total);
            print((received / total * 100).toStringAsFixed(0) + "%");
          }
        },
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );

      print("response ${response.statusMessage}");
      print("status code ${response.statusCode}");
      if (response.statusCode == 200) {
        if (!isClosed) add(const ChatJoinRequested());
        AppUtils.dismissprogress();
      } else if (response.statusCode == 404) {
        AppUtils.dismissprogress();
        AppUtils.showToastError("Sorry, File  not Found !");
      } else {
        AppUtils.dismissprogress();
      }
    } catch (e) {
      AppUtils.dismissprogress();
      print(e);
    }
  }

  /// Pagination (mirrors the api call inside getMessagesWithPageCount()); the
  /// widget builds the ChatView Message list from the returned response.
  Future<ChatMessageWithPageCountRes> loadMoreMessages(
      int groupId, int pageNo) {
    return _api.getMessagesWithPageCount(groupId, pageNo);
  }

  @override
  Future<void> close() {
    print("dispose called");
    _socket?.disconnect();
    _socket?.dispose();
    return super.close();
  }
}
