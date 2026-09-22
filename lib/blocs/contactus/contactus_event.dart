part of 'contactus_bloc.dart';

abstract class ContactusEvent extends Equatable {
  const ContactusEvent();

  @override
  List<Object?> get props => [];
}

/// Load the social-media back links (mirrors `getSocialsMediaLinks()`).
class SocialLinksRequested extends ContactusEvent {
  const SocialLinksRequested();
}
