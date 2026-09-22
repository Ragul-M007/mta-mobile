part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

/// Step 1 — request an OTP for the registered email.
class ForgotOtpRequested extends ForgotPasswordEvent {
  final String email;

  const ForgotOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Step 2 — verify the 5-digit OTP.
class ForgotOtpSubmitted extends ForgotPasswordEvent {
  final String otp;

  const ForgotOtpSubmitted(this.otp);

  @override
  List<Object?> get props => [otp];
}

/// Step 3 — set the new password.
class NewPasswordSubmitted extends ForgotPasswordEvent {
  final String newPassword;

  const NewPasswordSubmitted(this.newPassword);

  @override
  List<Object?> get props => [newPassword];
}
