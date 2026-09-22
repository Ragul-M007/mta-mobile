import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/ForgotPassReq.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/models/validateOTPReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';

part 'verifypin_event.dart';
part 'verifypin_state.dart';

/// BLoC for the Verify-PIN (app-launch) screen.
///
/// Behavior-preserving extraction of `_VerifypinState.signin()`,
/// `_generateOtp()` and `otpVerifyCall()`. The API calls, `Strings`/prefs
/// writes, role mapping, print logging and navigation *decisions* are
/// unchanged; the widget performs the UI side effects (spinner, toast,
/// dialogs, navigation) from the emitted states via a `BlocListener`.
class VerifyPinBloc extends Bloc<VerifyPinEvent, VerifyPinState> {
  final ApiService _api;

  /// Set when a forgot-pin OTP is generated, read when the OTP is verified —
  /// mirrors the old `emailIdforVerification` screen field.
  String _emailForVerification = '';

  VerifyPinBloc(this._api) : super(const VerifyPinInitial()) {
    on<VerifyPinSubmitted>(_onPinSubmitted);
    on<ForgotPasswordOtpRequested>(_onForgotOtpRequested);
    on<ResetOtpSubmitted>(_onResetOtpSubmitted);
  }

  // Mirrors _VerifypinState.signin()
  Future<void> _onPinSubmitted(
      VerifyPinSubmitted event, Emitter<VerifyPinState> emit) async {
    emit(const VerifyPinLoading());
    try {
      final emailId = await AppUtils.getStringPreferences('emailId');
      final loginreq = LoginReq();
      loginreq.email = emailId;
      loginreq.loginpin = event.pin;
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
        AppUtils.savePreferences("roleId", "${Strings.roleId}");
      }

      if (response.status!) {
        AppUtils.savePreferences("emailId", response.data!.emailId);
        AppUtils.savePreferences("userId", response.data!.userId);
        AppUtils.savePreferences("username", response.data!.name);
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
        Strings.userID = response.data!.userId;
        assignroles();
        AppUtils.savePreferences("easyAccess", "Y");
        AppUtils.savePreferences("authToken", response.token);
        Strings.isLogin = true;
        emit(VerifyPinAuthenticated(_resolveDestination()));
      } else {
        emit(VerifyPinFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(VerifyPinError(onError.toString()));
    }
  }

  /// Mirrors the notification-aware navigation branch inside signin()'s
  /// success path (widget performs the actual Navigator calls).
  VerifyPinDestination _resolveDestination() {
    if (Strings.FromNotification) {
      Strings.FromNotification = false;
      return VerifyPinDestination.attendance;
    } else if (Strings.fromNotificationComments) {
      if (Strings.selectedProDocument[0].projectComments == "true") {
        if (Strings.selectedProDocument[0].commentId == null) {
          return VerifyPinDestination.projectComments;
        } else {
          return VerifyPinDestination.projectCommentsReplies;
        }
      } else {
        if (Strings.selectedProDocument[0].commentId == null) {
          return VerifyPinDestination.comments;
        } else {
          return VerifyPinDestination.replies;
        }
      }
    } else if (Strings.fromNotificationDocuments) {
      return VerifyPinDestination.viewDoc;
    } else if (Strings.fromNotificationChat) {
      return VerifyPinDestination.chat;
    } else {
      if (Strings.roleId == 6) {
        return VerifyPinDestination.projects;
      } else {
        return VerifyPinDestination.teamsDashboard;
      }
    }
  }

  // Mirrors _VerifypinState._generateOtp() (the forgotPass API call)
  Future<void> _onForgotOtpRequested(
      ForgotPasswordOtpRequested event, Emitter<VerifyPinState> emit) async {
    emit(const VerifyPinLoading());
    try {
      final request = ForgotPassReq();
      request.emailId = event.email;
      final response = await _api.forgotPass(request);
      print('Response status ${response.toJson()}');
      if (response.status!) {
        _emailForVerification = event.email;
        emit(ForgotOtpSent(event.email));
      } else {
        emit(VerifyPinFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(VerifyPinError(onError.toString()));
    }
  }

  // Mirrors _VerifypinState.otpVerifyCall()
  Future<void> _onResetOtpSubmitted(
      ResetOtpSubmitted event, Emitter<VerifyPinState> emit) async {
    emit(const VerifyPinLoading());
    try {
      final request = ValidateOTPReq();
      request.emailId = _emailForVerification;
      request.otp = event.otp;
      print("data ${request.emailId}");
      print("data ${request.otp}");
      final response = await _api.otpVerify(request);
      print('Response status ${response.toJson()}');
      if (response.status!) {
        Strings.fromForgotPassword = true;
        emit(const ResetOtpVerified());
      } else {
        emit(VerifyPinFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(VerifyPinError(onError.toString()));
    }
  }
}
