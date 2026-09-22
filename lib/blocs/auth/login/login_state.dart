part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

/// A field validation error — show [message] as a toast.
/// [top] mirrors the original: true = showToastErrorTop, false = showToastError.
class LoginValidationError extends LoginState {
  final String message;
  final bool top;

  const LoginValidationError(this.message, {this.top = true});

  @override
  List<Object?> get props => [message, top];
}

/// Show the loading spinner (EasyLoading).
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// Login rejected (response.status == false) — show the "Login Failed" dialog.
class LoginFailed extends LoginState {
  final String message;

  const LoginFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// An unexpected error (the original catchError path) — dismiss loader only.
class LoginError extends LoginState {
  final String error;

  const LoginError(this.error);

  @override
  List<Object?> get props => [error];
}

/// Login succeeded — navigate to Set-PIN.
class LoginSuccess extends LoginState {
  const LoginSuccess();
}
