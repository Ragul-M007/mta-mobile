import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/models/SetPinReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';

part 'setpin_event.dart';
part 'setpin_state.dart';

/// BLoC for the Set-PIN screen.
///
/// Behavior-preserving extraction of the former `_SetpinState.signin()`,
/// `forgotPin()` and `signinafterpin()` methods. The API calls,
/// `Strings`/SharedPreferences writes, role mapping, print logging and
/// navigation *decisions* are unchanged; only UI side effects (progress
/// spinner, toast, navigation) are emitted as states for the widget to
/// perform via a `BlocListener`.
class SetpinBloc extends Bloc<SetpinEvent, SetpinState> {
  final ApiService _api;

  SetpinBloc(this._api) : super(const SetpinInitial()) {
    on<SetpinSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
      SetpinSubmitted event, Emitter<SetpinState> emit) async {
    // Mirrors the original SUBMIT button's branch on Strings.fromForgotPassword.
    if (Strings.fromForgotPassword == true) {
      await _forgotPin(event.pin, emit);
    } else {
      await _signin(event.pin, emit);
    }
  }

  // Mirrors _SetpinState.signin()
  Future<void> _signin(String pin, Emitter<SetpinState> emit) async {
    emit(const SetpinLoading());
    try {
      final setpinreq = SetPinReq();
      setpinreq.loginpin = pin;
      final userId = await AppUtils.getIntPreferences('userId');
      final response = await _api.setPin(userId, setpinreq);
      print('setPinResponse status ${response.toJson()}');
      if (response.status!) {
        AppUtils.savePreferences("easyAccess", "Y");
        Strings.isLogin = true;
        await _signinafterpin(pin, emit);
      } else {
        emit(SetpinFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(SetpinError(onError.toString()));
    }
  }

  // Mirrors _SetpinState.forgotPin()
  Future<void> _forgotPin(String pin, Emitter<SetpinState> emit) async {
    emit(const SetpinLoading());
    try {
      final emailId = await AppUtils.getStringPreferences('emailId');
      final setpinreq = SetPinReq();
      setpinreq.loginpin = pin;
      setpinreq.emailId = emailId;
      print("data ${jsonEncode(setpinreq)}");
      final userId = await AppUtils.getIntPreferences('userId');
      final response = await _api.setForgotPin(userId, setpinreq);
      print('setPinResponse status ${response.toJson()}');
      if (response.status!) {
        AppUtils.savePreferences("easyAccess", "Y");
        Strings.isLogin = true;
        await _signinafterpin(pin, emit);
      } else {
        emit(SetpinFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(SetpinError(onError.toString()));
    }
  }

  // Mirrors _SetpinState.signinafterpin()
  Future<void> _signinafterpin(String pin, Emitter<SetpinState> emit) async {
    try {
      final emailId = await AppUtils.getStringPreferences('emailId');
      final loginreq = LoginReq();
      loginreq.email = emailId;
      loginreq.loginpin = pin;
      loginreq.token = Strings.fcmToken;
      final dat = jsonEncode(loginreq);
      print(dat);
      final response = await _api.login(loginreq);
      print('verifyPinResponse status ${response.toJson()}');

      void assignroles() {
        if (response.data?.role == "ADMIN") {
          Strings.roleId = 1;
        } else if (response.data?.role == "STAFF") {
          Strings.roleId = 2;
        } else if (response.data?.role == "VENDOR") {
          Strings.roleId = 3;
        } else if (response.data?.role == "CONSULTANTS") {
          Strings.roleId = 4;
        } else if (response.data?.role == "CONTRACTORS") {
          Strings.roleId = 5;
        } else if (response.data?.role == "CLIENT") {
          Strings.roleId = 6;
        } else if (response.data?.role == "PUBLICUSER") {
          Strings.roleId = 7;
        }

        print("rolee IId ${Strings.roleId}");
        AppUtils.savePreferences("roleId", "${Strings.roleId}");
      }

      if (response.status!) {
        AppUtils.savePreferences("emailId", response.data!.emailId);
        AppUtils.savePreferences("userId", response.data!.userId);
        if (response.data!.userImg != null) {
          AppUtils.savePreferences("profilePic", response.data!.userImg);
          Strings.profilePic = response.data!.userImg!;
        } else {
          AppUtils.savePreferences("profilePic", "");
          Strings.profilePic = "";
        }
        Strings.userID = response.data!.userId;
        Strings.authToken = response.token!;
        Strings.username = response.data!.name;
        assignroles();
        AppUtils.savePreferences("easyAccess", "Y");
        AppUtils.savePreferences("authToken", response.token);
        Strings.isLogin = true;
        if (Strings.FromNotification) {
          Strings.FromNotification = false;
          emit(const SetpinAuthenticated(SetpinDestination.attendance));
        } else {
          if (Strings.roleId == 6) {
            emit(const SetpinAuthenticated(SetpinDestination.projects));
          } else {
            emit(const SetpinAuthenticated(SetpinDestination.teamsDashboard));
          }
        }
      } else {
        emit(SetpinFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(SetpinError(onError.toString()));
    }
  }
}
