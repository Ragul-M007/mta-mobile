part of 'viewdoclist_bloc.dart';

/// Command-style states (not Equatable).
abstract class ViewDocListState {
  const ViewDocListState();
}

class ViewDocInitial extends ViewDocListState {}

/// Widget: `AppUtils.showprogress()` (getDocs / getUserCats start).
class ViewDocLoading extends ViewDocListState {}

/// Category documents loaded — widget dismisses + setState(`_categorydocsList`).
class ViewDocCategoryLoaded extends ViewDocListState {
  final List<FetchCategoryDoc> data;

  ViewDocCategoryLoaded(this.data);
}

/// Project documents loaded — widget dismisses + setState(`_docsList`).
class ViewDocProjectLoaded extends ViewDocListState {
  final List<ProjectDocData> data;

  ViewDocProjectLoaded(this.data);
}

/// `status == false` on getDocs — widget dismisses + setState(`_errText`).
class ViewDocEmpty extends ViewDocListState {}

/// A flow's `catchError` — widget only dismisses the spinner.
class ViewDocErrorDismiss extends ViewDocListState {}

/// getUserCats finished — widget dismisses + `Navigator.pushNamed('/comments')`.
/// (`Strings.users`/`Strings.categories` already written in the BLoC.)
class ViewDocCommentsNav extends ViewDocListState {}

/// updateNotification `status == false` — widget dismisses +
/// `showToastError(message)`.
class ViewDocNotifFailure extends ViewDocListState {
  final String message;

  ViewDocNotifFailure(this.message);
}

/// updateNotification `catchError` — widget dismisses +
/// `showToastError("Unable to connect to server")`.
class ViewDocNotifError extends ViewDocListState {}
