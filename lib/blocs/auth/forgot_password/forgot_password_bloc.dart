import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/ChangePassReq.dart';
import 'package:mta/models/ForgotPassReq.dart';
import 'package:mta/models/validateOTPReq.dart';
import 'package:mta/network/ApiService.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

/// BLoC for the login-screen Forgot-Password chain:
/// forgotPass -> OTP verify -> change password. Behavior-preserving extraction
/// of `_generateOtp()`, `otpVerifyCall()` and `setNewPass()`; the presence /
/// length / match validations stay in the dialogs' UI, as they were.
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ApiService _api;

  /// Set on forgotPass success, reused by otpVerify and changePass — mirrors
  /// the old `emailIdforVerification` global.
  String _emailForVerification = '';

  ForgotPasswordBloc(this._api) : super(const ForgotPasswordInitial()) {
    on<ForgotOtpRequested>(_onOtpRequested);
    on<ForgotOtpSubmitted>(_onOtpSubmitted);
    on<NewPasswordSubmitted>(_onNewPasswordSubmitted);
  }

  // Mirrors _generateOtp() (forgotPass API)
  Future<void> _onOtpRequested(
      ForgotOtpRequested event, Emitter<ForgotPasswordState> emit) async {
    emit(const ForgotLoading());
    try {
      ForgotPassReq request = ForgotPassReq();
      request.emailId = event.email;
      final response = await _api.forgotPass(request);
      print('Response status ${response.toJson()}');
      if (response.status!) {
        _emailForVerification = event.email;
        emit(const ForgotOtpSent());
      } else {
        emit(ForgotFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ForgotError(onError.toString()));
    }
  }

  // Mirrors otpVerifyCall()
  Future<void> _onOtpSubmitted(
      ForgotOtpSubmitted event, Emitter<ForgotPasswordState> emit) async {
    emit(const ForgotLoading());
    try {
      ValidateOTPReq request = ValidateOTPReq();
      request.emailId = _emailForVerification;
      request.otp = event.otp;
      final response = await _api.otpVerify(request);
      print('Response status ${response.toJson()}');
      if (response.status!) {
        emit(const ForgotOtpVerified());
      } else {
        emit(ForgotFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ForgotError(onError.toString()));
    }
  }

  // Mirrors setNewPass()
  Future<void> _onNewPasswordSubmitted(
      NewPasswordSubmitted event, Emitter<ForgotPasswordState> emit) async {
    emit(const ForgotLoading());
    try {
      ChangePassReq request = ChangePassReq();
      request.emailId = _emailForVerification;
      request.newPassword = event.newPassword;
      final response = await _api.changePass(request);
      print('Response status ${response.toJson()}');
      if (response.status!) {
        emit(PasswordChanged(response.message!));
      } else {
        emit(ForgotFailure(response.message!, top: true));
      }
    } catch (onError) {
      print(onError.toString());
      emit(ForgotError(onError.toString()));
    }
  }
}
