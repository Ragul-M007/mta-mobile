import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';
import 'package:mta/utilities/validators.dart';

part 'login_event.dart';
part 'login_state.dart';

/// BLoC for the main Login flow (email + password -> Set-PIN).
///
/// Behavior-preserving extraction of `_LoginContentState._login()` (the
/// validation + connectivity check) and `loginreq()` (the API call, `Strings`
/// writes and navigation decision). The widget performs the UI side effects
/// (toasts, spinner, "Login Failed" dialog, navigation) via a `BlocListener`.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ApiService _api;

  LoginBloc(this._api) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  // Mirrors _login(): validation, then connectivity check, then loginreq().
  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    final email = event.email;
    final password = event.password;
    if (email.isEmpty) {
      emit(const LoginValidationError("Please Enter Your Email Id"));
    } else if (password.isEmpty) {
      emit(const LoginValidationError("Please enter Your Password"));
    } else if (password.trim() == "") {
      emit(const LoginValidationError("Please enter Your Password"));
    } else if (email.trim() == "accounts@multitechcorp.in") {
      emit(const LoginValidationError(
          "Sorry! You doesn't have access on Mobile App. Kindly Login from the Web Application.",
          top: false));
    } else {
      bool network = await Validators.networkconnectvitiy();
      if (network) {
        await _loginreq(email, password, emit);
      }
    }
  }

  // Mirrors loginreq()
  Future<void> _loginreq(
      String email, String password, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    try {
      final loginreq = LoginReq();
      loginreq.email = email;
      loginreq.password = password;
      loginreq.token = Strings.fcmToken;
      Strings.authToken = '';
      print("loqinrequest ---> ${jsonEncode(loginreq)}");
      final response = await _api.login(loginreq);
      print('loginResponse status ${response.toJson()}');

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
      }

      if (response.status!) {
        print("inside status");
        AppUtils.savePreferences("emailId", response.data?.emailId);
        AppUtils.savePreferences("userId", response.data?.userId);
        AppUtils.savePreferences("username", response.data?.name);
        if (response.data?.userImg != null) {
          print("inside if img");
          AppUtils.savePreferences("profilePic", response.data?.userImg);
          Strings.profilePic = response.data!.userImg!;
        } else {
          print("inside elseif img");
          AppUtils.savePreferences("profilePic", "");
          Strings.profilePic = "";
        }
        Strings.userID = response.data!.userId;
        Strings.username = response.data!.name;
        assignroles();
        Strings.authToken = response.token!;
        print("role${Strings.roleId}");
        emit(const LoginSuccess());
      } else {
        emit(LoginFailed(response.message ?? "Unknown Error"));
      }
    } catch (onError) {
      print(onError.toString());
      emit(LoginError(onError.toString()));
    }
  }
}
