part of 'contactus_bloc.dart';

abstract class ContactusState extends Equatable {
  const ContactusState();

  @override
  List<Object?> get props => [];
}

class ContactusInitial extends ContactusState {
  const ContactusInitial();
}

/// Show the loading spinner.
class SocialLinksLoading extends ContactusState {
  const SocialLinksLoading();
}

/// Back links loaded — widget maps them into `socialLinksData` + clears `loader`.
class SocialLinksLoaded extends ContactusState {
  final List<Data> data;

  const SocialLinksLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Unexpected error (catchError) — dismiss the spinner only.
class SocialLinksError extends ContactusState {
  const SocialLinksError();
}
