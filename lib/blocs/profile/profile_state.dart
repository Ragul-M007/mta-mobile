part of 'profile_bloc.dart';

/// Command-style states (not Equatable). Because the profile flows are submits
/// whose outcomes repeat (a second failure with the same message must re-fire
/// the listener), the states are intentionally non-Equatable so `bloc` never
/// dedups them.
///
/// The BLoC keeps the API calls, SharedPreferences writes, `Strings` writes and
/// `print` logging (all context-free); the widget's listener performs the UI
/// side effects each state names (spinner, toast, navigation, setState).
abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {}

/// Widget: `AppUtils.showprogress()`.
class ProfileLoading extends ProfileState {}

/// Profile fetched — widget dismisses the spinner and runs the big getProfile()
/// setState with [data].
class ProfileDataLoaded extends ProfileState {
  final List<ProfileData> data;

  ProfileDataLoaded(this.data);
}

/// A flow's `catchError` (and the getProfile failure) — widget only dismisses
/// the spinner (the `print` already ran in the BLoC).
class ProfileErrorDismiss extends ProfileState {}

/// `status == false` on any submit — widget dismisses + `showToastError(message)`.
class ProfileFailure extends ProfileState {
  final String message;

  ProfileFailure(this.message);
}

/// Password changed / account deleted — widget dismisses, `showToastSuccess`,
/// then `Navigator.popAndPushNamed(context, "/login")`.
/// (prefs cleared + `Strings.isLogin = false` already done in the BLoC.)
class ProfileNavToLogin extends ProfileState {
  final String message;

  ProfileNavToLogin(this.message);
}

/// Profile edited — widget dismisses + `showToastSuccess`, then either removes
/// the pro-pic ([removeImage] == true → dispatch [ProfileProPicRemoveRequested])
/// or pops the edit dialog and reloads the profile.
class ProfileEditSuccess extends ProfileState {
  final String message;
  final bool removeImage;

  ProfileEditSuccess(this.message, this.removeImage);
}

/// PIN reset — widget dismisses + `showToastSuccess`, pops the PIN dialog and
/// clears the 4 PIN fields. (`easyAccess` pref saved in the BLoC.)
class ProfilePinSuccess extends ProfileState {
  final String message;

  ProfilePinSuccess(this.message);
}

/// Profile picture removed — widget dismisses, pops, reloads the profile and
/// toasts the fixed success message.
class ProfileProPicSuccess extends ProfileState {}
