part of 'verifypin_bloc.dart';

abstract class VerifyPinEvent extends Equatable {
  const VerifyPinEvent();

  @override
  List<Object?> get props => [];
}

/// The user submitted the 4-digit PIN (via SUBMIT or auto on the 4th digit).
class VerifyPinSubmitted extends VerifyPinEvent {
  final String pin;

  const VerifyPinSubmitted(this.pin);

  @override
  List<Object?> get props => [pin];
}

/// Forgot-pin: request an OTP for the given registered email.
class ForgotPasswordOtpRequested extends VerifyPinEvent {
  final String email;

  const ForgotPasswordOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Forgot-pin: verify the 5-digit OTP the user entered.
class ResetOtpSubmitted extends VerifyPinEvent {
  final String otp;

  const ResetOtpSubmitted(this.otp);

  @override
  List<Object?> get props => [otp];
}
