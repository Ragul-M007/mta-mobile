part of 'adddoc_bloc.dart';

/// Command-style states (not Equatable) — the submit outcomes repeat, so the
/// listener must re-fire on each.
abstract class AddDocState {
  const AddDocState();
}

class AddDocInitial extends AddDocState {}

/// Users fetched — widget runs the globals setState (`Strings.users`, `users`,
/// `_userIitems`) with [data].
class AddDocUsersLoaded extends AddDocState {
  final List<FetchMapedUsersData> data;

  AddDocUsersLoaded(this.data);
}

/// Widget: `AppUtils.showprogress()` (submit start).
class AddDocSubmitLoading extends AddDocState {}

/// Document added — widget dismisses, navigates to `/viewdoclist`, stores the
/// [documentId] in `Strings.docID`, then runs `UpdateRights()` + setState.
class AddDocSubmitSuccess extends AddDocState {
  final int? documentId;

  AddDocSubmitSuccess(this.documentId);
}

/// `status == false` on submit — widget dismisses + `showToastError(message)`.
class AddDocFailure extends AddDocState {
  final String message;

  AddDocFailure(this.message);
}

/// A flow's `catchError` — widget only dismisses the spinner (the `print`
/// already ran in the BLoC).
class AddDocErrorDismiss extends AddDocState {}
