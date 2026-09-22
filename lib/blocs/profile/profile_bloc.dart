import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/ChangePassReq.dart';
import 'package:mta/models/EditProfileReq.dart';
import 'package:mta/models/ProfileRes.dart';
import 'package:mta/models/SetPinReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC for the Profile screen (6 flows: getProfile, changePass, editProfile,
/// resetPin, removeProPic, deleteUser).
///
/// Behavior-preserving extraction following the established pattern: the BLoC
/// keeps the API calls, SharedPreferences writes (`getIntPreferences`/
/// `savePreferences`/`clearAllPreferences`), `Strings` writes and `print`
/// logging verbatim, and emits states. The widget's listener performs the UI
/// side effects (spinner, toast, navigation, the 12-field setState, the PIN
/// reset). States are command-style (not Equatable) because these submit
/// outcomes repeat.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService _api;

  ProfileBloc(this._api) : super(ProfileInitial()) {
    on<ProfileRequested>(_onRequested);
    on<ProfilePasswordSubmitted>(_onPasswordSubmitted);
    on<ProfileEditSubmitted>(_onEditSubmitted);
    on<ProfilePinSubmitted>(_onPinSubmitted);
    on<ProfileProPicRemoveRequested>(_onProPicRemove);
    on<ProfileUserDeleteRequested>(_onUserDelete);
  }

  // Mirrors getProfile()
  Future<void> _onRequested(
      ProfileRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await _api.profile(Strings.userID!);
      print('profileResponse status ${response.data}');
      emit(ProfileDataLoaded(response.data!));
    } catch (onError) {
      print(onError.toString());
      emit(ProfileErrorDismiss());
    }
  }

  // Mirrors the api.changePass(...) portion of _changePass()
  Future<void> _onPasswordSubmitted(
      ProfilePasswordSubmitted event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await _api.changePass(event.req);
      print('Response status ${response.toJson()}');
      if (response.status!) {
        AppUtils.clearAllPreferences();
        Strings.isLogin = false;
        emit(ProfileNavToLogin(response.message!));
      } else {
        emit(ProfileFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProfileErrorDismiss());
    }
  }

  // Mirrors the api.editProfile(...) portion of _editProfile()
  Future<void> _onEditSubmitted(
      ProfileEditSubmitted event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await _api.editProfile(Strings.userID!, event.req);
      print('Response status ${response.toJson()}');
      if (response.status!) {
        emit(ProfileEditSuccess(response.message!, event.removeImage));
      } else {
        emit(ProfileFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProfileErrorDismiss());
    }
  }

  // Mirrors resetPin()
  Future<void> _onPinSubmitted(
      ProfilePinSubmitted event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final value = await AppUtils.getIntPreferences('userId');
      if (value != null) {
        final response = await _api.setPin(value, event.req);
        if (response.status!) {
          AppUtils.savePreferences("easyAccess", "Y");
          emit(ProfilePinSuccess(response.message!));
        } else {
          emit(ProfileFailure(response.message!));
        }
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProfileErrorDismiss());
    }
  }

  // Mirrors removeProPic()
  Future<void> _onProPicRemove(
      ProfileProPicRemoveRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final response = await _api.removeProPic(Strings.userID!);
      if (response.status!) {
        emit(ProfileProPicSuccess());
      } else {
        emit(ProfileFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProfileErrorDismiss());
    }
  }

  // Mirrors removeUser() — note: the original shows no progress spinner here.
  Future<void> _onUserDelete(
      ProfileUserDeleteRequested event, Emitter<ProfileState> emit) async {
    try {
      final value = await AppUtils.getIntPreferences('userId');
      if (value != null) {
        final response = await _api.deleteUser(value);
        if (response.status!) {
          AppUtils.clearAllPreferences();
          Strings.isLogin = false;
          emit(ProfileNavToLogin(response.message!));
        } else {
          emit(ProfileFailure(response.message!));
        }
      }
    } catch (onError) {
      print(onError.toString());
      emit(ProfileErrorDismiss());
    }
  }
}
