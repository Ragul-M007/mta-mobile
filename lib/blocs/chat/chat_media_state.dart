part of 'chat_media_bloc.dart';

/// Command-style states (not Equatable).
abstract class ChatMediaState {
  const ChatMediaState();
}

class ChatMediaInitial extends ChatMediaState {}

/// Media of [type] loaded — widget setState (assign the matching list) then
/// dismisses the spinner.
class ChatMediaDocsLoaded extends ChatMediaState {
  final String type;
  final List<MediaData> data;

  ChatMediaDocsLoaded(this.type, this.data);
}

/// Chat users loaded — widget setState(`chatUsers`).
class ChatMediaUsersLoaded extends ChatMediaState {
  final List<GroupChatUsersData> data;

  ChatMediaUsersLoaded(this.data);
}

/// Group metadata loaded — widget setState(`groupCreatedUserId`).
class ChatMediaGroupDataLoaded extends ChatMediaState {
  final int? groupCreatedBy;

  ChatMediaGroupDataLoaded(this.groupCreatedBy);
}

/// A load flow's `catchError` — widget only dismisses the spinner.
class ChatMediaErrorDismiss extends ChatMediaState {}

/// Widget: `AppUtils.showprogress()` (delete start).
class ChatMediaDeleteLoading extends ChatMediaState {}

/// Group deleted — widget dismisses, pushes ChatGroups, then setState with
/// `showToastSuccess(comment ?? "Deleted Successfully")`.
class ChatMediaDeleteSuccess extends ChatMediaState {
  final String? comment;

  ChatMediaDeleteSuccess(this.comment);
}

/// Delete `status == false` or `catchError` — widget dismisses +
/// `showToastError("Something went wrong!")`.
class ChatMediaDeleteFailed extends ChatMediaState {}
