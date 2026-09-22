part of 'remove_users_bloc.dart';

/// Command-style states (not Equatable).
abstract class RemoveUsersState {
  const RemoveUsersState();
}

class RemoveUsersInitial extends RemoveUsersState {}

/// Widget: `AppUtils.showprogress()` (load start).
class RemoveUsersLoading extends RemoveUsersState {}

/// Chat users loaded — widget clears + assigns `chatUsers`, runs the
/// `isSelected` selection loop, and dismisses the spinner (verbatim block).
class RemoveUsersLoaded extends RemoveUsersState {
  final List<GroupChatUsersData> data;

  RemoveUsersLoaded(this.data);
}

/// getChatUsers `status == false` — widget shows `"Unable to load users"`.
/// NOTE: the original does NOT dismiss the spinner here (quirk preserved).
class RemoveUsersLoadFailed extends RemoveUsersState {}

/// getChatUsers `catchError` — widget dismisses + `showToastError(message)`.
class RemoveUsersLoadError extends RemoveUsersState {
  final String message;

  RemoveUsersLoadError(this.message);
}

/// removeUsersintoGroup success — widget `showToastSuccess(message ?? "Success")`
/// then `Navigator.pop(context)`.
class RemoveUsersRemoveSuccess extends RemoveUsersState {
  final String? message;

  RemoveUsersRemoveSuccess(this.message);
}

/// removeUsersintoGroup `status == false` — widget
/// `showToastError(message ?? "Failed")`.
class RemoveUsersRemoveFailed extends RemoveUsersState {
  final String? message;

  RemoveUsersRemoveFailed(this.message);
}

/// removeUsersintoGroup `catchError` — widget only dismisses the spinner.
class RemoveUsersRemoveError extends RemoveUsersState {}
