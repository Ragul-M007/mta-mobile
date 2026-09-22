import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mta/models/SignupReq.dart';
import 'package:mta/network/ApiService.dart';

part 'signup_event.dart';
part 'signup_state.dart';

/// BLoC for the SignUp flow. Behavior-preserving extraction of the API call in
/// `_signupRequest()`; the field validation stays in the dialog's UI (as it
/// was), and this BLoC only performs the `api.signUp` request.
class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final ApiService _api;

  SignupBloc(this._api) : super(const SignupInitial()) {
    on<SignupSubmitted>(_onSubmitted);
  }

  // Mirrors the request half of _signupRequest()
  Future<void> _onSubmitted(
      SignupSubmitted event, Emitter<SignupState> emit) async {
    emit(const SignupLoading());
    try {
      SignUpReq request = new SignUpReq();
      request.email = event.email;
      request.name = event.name;
      request.mobileNo = event.phone;
      request.state = "";
      request.city = "";
      request.area = "";
      request.publicUser = 1;
      request.roleId = 7;
      print("check ${jsonEncode(request)}");
      final response = await _api.signUp(request);
      print('Response status ${response.toJson()}');
      if (response.status!) {
        emit(const SignupSuccess());
      } else {
        emit(SignupFailure(response.message!));
      }
    } catch (onError) {
      print(onError.toString());
      emit(SignupError(onError.toString()));
    }
  }
}
