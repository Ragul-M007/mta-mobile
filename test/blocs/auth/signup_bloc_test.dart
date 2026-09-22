import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/auth/signup/signup_bloc.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/SignupReq.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  setUpAll(() => registerFallbackValue(SignUpReq()));

  late MockApiService api;
  setUp(() => api = MockApiService());

  blocTest<SignupBloc, SignupState>(
    'signUp ok -> [Loading, Success]',
    setUp: () => when(() => api.signUp(any()))
        .thenAnswer((_) async => CommonRes(status: true, message: 'ok')),
    build: () => SignupBloc(api),
    act: (bloc) =>
        bloc.add(const SignupSubmitted('Name', '1234567890', 'a@b.com')),
    expect: () => [isA<SignupLoading>(), isA<SignupSuccess>()],
  );

  blocTest<SignupBloc, SignupState>(
    'signUp status=false -> [Loading, Failure(message)]',
    setUp: () => when(() => api.signUp(any()))
        .thenAnswer((_) async => CommonRes(status: false, message: 'exists')),
    build: () => SignupBloc(api),
    act: (bloc) =>
        bloc.add(const SignupSubmitted('Name', '1234567890', 'a@b.com')),
    expect: () => [
      isA<SignupLoading>(),
      isA<SignupFailure>().having((s) => s.message, 'message', 'exists'),
    ],
  );
}
