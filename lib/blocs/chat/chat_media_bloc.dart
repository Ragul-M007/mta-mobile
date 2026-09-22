import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/Chat/GroupUsersRes.dart';
import 'package:mta/models/Chat/MediaDetailsRes.dart';
import 'package:mta/network/ApiService.dart';

part 'chat_media_event.dart';
part 'chat_media_state.dart';

/// BLoC for the Chat-Media screen (4 flows: getDocumentDetails/getMediaDetails,
/// getUsersByGroupId/getChatUsers, getGroupData, deleteGroup).
///
/// Behavior-preserving extraction: the BLoC keeps the API calls and `print`
/// logging; the widget's listener performs the UI side effects (the
/// `_imageList`/`_videoList`/`_docList`/`chatUsers`/`groupCreatedUserId`
/// setStates, spinner, toast, navigation to ChatGroups). States are
/// command-style (not Equatable).
class ChatMediaBloc extends Bloc<ChatMediaEvent, ChatMediaState> {
  final ApiService _api;

  ChatMediaBloc(this._api) : super(ChatMediaInitial()) {
    on<ChatMediaDocsRequested>(_onDocsRequested);
    on<ChatMediaUsersRequested>(_onUsersRequested);
    on<ChatMediaGroupDataRequested>(_onGroupDataRequested);
    on<ChatMediaDeleteGroupRequested>(_onDeleteGroupRequested);
  }

  // Mirrors getDocumentDetails(type)
  Future<void> _onDocsRequested(
      ChatMediaDocsRequested event, Emitter<ChatMediaState> emit) async {
    try {
      final response = await _api.getMediaDetails(event.groupId, event.type);
      if (response.status!) {
        emit(ChatMediaDocsLoaded(event.type, response.data!));
      } else {
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(ChatMediaErrorDismiss());
    }
  }

  // Mirrors getUsersByGroupId()
  Future<void> _onUsersRequested(
      ChatMediaUsersRequested event, Emitter<ChatMediaState> emit) async {
    try {
      final response = await _api.getChatUsers(event.groupId);
      if (response.status!) {
        emit(ChatMediaUsersLoaded(response.data!));
      } else {
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(ChatMediaErrorDismiss());
    }
  }

  // Mirrors getGroupData()
  Future<void> _onGroupDataRequested(
      ChatMediaGroupDataRequested event, Emitter<ChatMediaState> emit) async {
    try {
      final response = await _api.getGroupData(event.groupId);
      if (response.status!) {
        emit(ChatMediaGroupDataLoaded(response.data?.groupCreatedBy));
      } else {
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(ChatMediaErrorDismiss());
    }
  }

  // Mirrors deleteGroup()
  Future<void> _onDeleteGroupRequested(ChatMediaDeleteGroupRequested event,
      Emitter<ChatMediaState> emit) async {
    emit(ChatMediaDeleteLoading());
    try {
      final response = await _api.deleteGroup(event.groupId);
      if (response.status!) {
        emit(ChatMediaDeleteSuccess(response.comment));
      } else {
        emit(ChatMediaDeleteFailed());
        print('error');
      }
    } catch (onError) {
      print(onError.toString());
      emit(ChatMediaDeleteFailed());
    }
  }
}
