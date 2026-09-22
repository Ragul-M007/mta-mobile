import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/BackLinkRes.dart';
import 'package:mta/network/ApiService.dart';

part 'contactus_event.dart';
part 'contactus_state.dart';

/// BLoC for the Contact-Us screen.
///
/// Behavior-preserving extraction of `getSocialsMediaLinks()`. The API call and
/// `print` logging move verbatim; the spinner and the `socialLinksData` /
/// `loader` updates stay in the widget via a stream listener. (No status check —
/// the original assumed success and read `response.data![0]` directly.)
class ContactusBloc extends Bloc<ContactusEvent, ContactusState> {
  final ApiService _api;

  ContactusBloc(this._api) : super(const ContactusInitial()) {
    on<SocialLinksRequested>(_onRequested);
  }

  // Mirrors getSocialsMediaLinks()
  Future<void> _onRequested(
      SocialLinksRequested event, Emitter<ContactusState> emit) async {
    emit(const SocialLinksLoading());
    try {
      final response = await _api.getSocialsBackLink();
      print('profileResponse status ${response.toJson()}');
      emit(SocialLinksLoaded(response.data!));
    } catch (onError) {
      print(onError.toString());
      emit(const SocialLinksError());
    }
  }
}
