part of 'signup_bloc.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object?> get props => [];
}

class SignupInitial extends SignupState {
  const SignupInitial();
}

/// Show the loading spinner (EasyLoading).
class SignupLoading extends SignupState {
  const SignupLoading();
}

/// Sign-up rejected (response.status == false) — show [message] as a toast.
class SignupFailure extends SignupState {
  final String message;

  const SignupFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// An unexpected error (the original catchError path) — dismiss loader only.
class SignupError extends SignupState {
  final String error;

  const SignupError(this.error);

  @override
  List<Object?> get props => [error];
}

/// Sign-up succeeded — close the signup dialog and show the success dialog.
class SignupSuccess extends SignupState {
  const SignupSuccess();
}
