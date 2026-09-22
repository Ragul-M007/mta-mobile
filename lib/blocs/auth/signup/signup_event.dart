part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

/// The user tapped SIGNUP with validated name / phone / email.
class SignupSubmitted extends SignupEvent {
  final String name;
  final String phone;
  final String email;

  const SignupSubmitted(this.name, this.phone, this.email);

  @override
  List<Object?> get props => [name, phone, email];
}
