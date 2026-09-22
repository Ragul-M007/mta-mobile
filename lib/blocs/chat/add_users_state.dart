part of 'add_users_bloc.dart';

/// Command-style states (not Equatable).
abstract class AddUsersState {
  const AddUsersState();
}

class AddUsersInitial extends AddUsersState {}

/// Widget: `AppUtils.showprogress()` (load start).
class AddUsersLoading extends AddUsersState {}

/// Users loaded — widget setState(`chatUsers`) + the `isSelected` selection
/// loop, then dismisses the spinner.
class AddUsersLoaded extends AddUsersState {
  final List<AddUsersData> data;

  AddUsersLoaded(this.data);
}

/// Load `status == false` — widget shows `"Unable to load users"`.
/// NOTE: the original does NOT dismiss the spinner here (quirk preserved).
class AddUsersLoadFailed extends AddUsersState {}

/// Load `catchError` — widget dismisses + `showToastError(message)`.
class AddUsersLoadError extends AddUsersState {
  final String message;

  AddUsersLoadError(this.message);
}

/// Widget: `AppUtils.showprogress()` (createGroup start).
class AddUsersCreateLoading extends AddUsersState {}

/// createGroup success (add-users already emitted in the BLoC) — widget
/// dismisses, `Navigator.pop(context)`, then `showToastSuccess(message)`.
class AddUsersCreatedNav extends AddUsersState {
  final String message;

  AddUsersCreatedNav(this.message);
}

/// createGroup `status == false` — widget dismisses + `showToastError(message)`.
class AddUsersCreateFailed extends AddUsersState {
  final String message;

  AddUsersCreateFailed(this.message);
}

/// createGroup `catchError` — widget dismisses + `showToastError(message)`.
class AddUsersCreateError extends AddUsersState {
  final String message;

  AddUsersCreateError(this.message);
}

/// Direct add-users (not from create) — add-users already emitted in the BLoC;
/// widget `showToastSuccess("Successfully Added the users")` + `Navigator.pop`.
class AddUsersAddedNav extends AddUsersState {}
