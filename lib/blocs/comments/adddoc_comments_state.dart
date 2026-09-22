part of 'adddoc_comments_bloc.dart';

/// Command-style states (not Equatable) — the submit outcome repeats.
abstract class AddDocCommentsState {
  const AddDocCommentsState();
}

class AddDocCommentsInitial extends AddDocCommentsState {}

/// Widget: `AppUtils.showprogress()` (submit start).
class AddDocCommentsLoading extends AddDocCommentsState {}

/// Upload succeeded — widget dismisses, `showToastSuccess(...)`, then the
/// 4-way `pushReplacementNamed` branch on `Strings.documentUploadfromProject`
/// + `fromReplies`.
class AddDocCommentsSuccess extends AddDocCommentsState {}

/// `status == false` — widget dismisses + `showToastError(message)`.
class AddDocCommentsFailure extends AddDocCommentsState {
  final String message;

  AddDocCommentsFailure(this.message);
}

/// `catchError` — widget only dismisses the spinner.
class AddDocCommentsErrorDismiss extends AddDocCommentsState {}
