part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

/// Show the loading spinner (EasyLoading).
class ForgotLoading extends ForgotPasswordState {
  const ForgotLoading();
}

/// A handled failure (response.status == false).
/// [top] mirrors the original toast type: forgotPass/otpVerify use a normal
/// toast (top=false); changePass uses showToastErrorTop (top=true).
class ForgotFailure extends ForgotPasswordState {
  final String message;
  final bool top;

  const ForgotFailure(this.message, {this.top = false});

  @override
  List<Object?> get props => [message, top];
}

/// An unexpected error (the original catchError path) — dismiss loader only.
class ForgotError extends ForgotPasswordState {
  final String error;

  const ForgotError(this.error);

  @override
  List<Object?> get props => [error];
}

/// forgotPass succeeded — close the forgot dialog, open the OTP dialog.
class ForgotOtpSent extends ForgotPasswordState {
  const ForgotOtpSent();
}

/// OTP verified — close the OTP dialog, open the change-password dialog.
class ForgotOtpVerified extends ForgotPasswordState {
  const ForgotOtpVerified();
}

/// Password changed — clear + close the dialog and show a success toast.
class PasswordChanged extends ForgotPasswordState {
  final String message;

  const PasswordChanged(this.message);

  @override
  List<Object?> get props => [message];
}
