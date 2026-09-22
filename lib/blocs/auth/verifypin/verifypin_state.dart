part of 'verifypin_bloc.dart';

/// Post-login navigation targets — mirrors signin()'s notification-aware
/// navigation branches exactly (widget performs the Navigator calls, reading
/// Strings for the chat arguments just like the old code).
enum VerifyPinDestination {
  attendance,
  projectComments,
  projectCommentsReplies,
  comments,
  replies,
  viewDoc,
  chat,
  projects,
  teamsDashboard,
}

abstract class VerifyPinState extends Equatable {
  const VerifyPinState();

  @override
  List<Object?> get props => [];
}

class VerifyPinInitial extends VerifyPinState {
  const VerifyPinInitial();
}

/// Show the loading spinner (EasyLoading) — shared by all three flows.
class VerifyPinLoading extends VerifyPinState {
  const VerifyPinLoading();
}

/// A handled failure (response.status == false) — show [message] as a toast.
class VerifyPinFailure extends VerifyPinState {
  final String message;

  const VerifyPinFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// An unexpected error (the original catchError path) — dismiss loader only.
class VerifyPinError extends VerifyPinState {
  final String error;

  const VerifyPinError(this.error);

  @override
  List<Object?> get props => [error];
}

/// PIN verified — navigate to [destination].
class VerifyPinAuthenticated extends VerifyPinState {
  final VerifyPinDestination destination;

  const VerifyPinAuthenticated(this.destination);

  @override
  List<Object?> get props => [destination];
}

/// Forgot-pin OTP was sent — close the forgot dialog and open the OTP dialog.
class ForgotOtpSent extends VerifyPinState {
  final String email;

  const ForgotOtpSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// OTP verified — close the OTP dialog and go to Set-PIN.
class ResetOtpVerified extends VerifyPinState {
  const ResetOtpVerified();
}
