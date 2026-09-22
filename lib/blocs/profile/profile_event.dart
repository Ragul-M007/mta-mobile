part of 'profile_bloc.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

/// Load the profile (mirrors `getProfile()`).
class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

/// Change password (mirrors `_changePass()`); [req] built by the widget.
class ProfilePasswordSubmitted extends ProfileEvent {
  final ChangePassReq req;

  const ProfilePasswordSubmitted(this.req);
}

/// Edit profile (mirrors `_editProfile()`); [removeImage] decides the follow-up.
class ProfileEditSubmitted extends ProfileEvent {
  final EditProfileReq req;
  final bool removeImage;

  const ProfileEditSubmitted(this.req, this.removeImage);
}

/// Reset the login PIN (mirrors `resetPin()`); [req] built by the widget.
class ProfilePinSubmitted extends ProfileEvent {
  final SetPinReq req;

  const ProfilePinSubmitted(this.req);
}

/// Remove the profile picture (mirrors `removeProPic()`).
class ProfileProPicRemoveRequested extends ProfileEvent {
  const ProfileProPicRemoveRequested();
}

/// Delete the account (mirrors the static `removeUser()`).
class ProfileUserDeleteRequested extends ProfileEvent {
  const ProfileUserDeleteRequested();
}
