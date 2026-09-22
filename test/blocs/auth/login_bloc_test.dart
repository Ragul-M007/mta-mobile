import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/auth/login/login_bloc.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for LoginBloc's validation (mirrors _login()'s checks).
///
/// The successful-login path is intentionally not unit-tested here because it
/// awaits `Validators.networkconnectvitiy()` (a static connectivity call that
/// isn't available under `flutter test`); it's covered by the device smoke
/// test and by the analogous setpin/verifypin login tests.
void main() {
  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<LoginBloc, LoginState>(
    'empty email -> LoginValidationError',
    build: () => LoginBloc(api),
    act: (bloc) => bloc.add(const LoginSubmitted('', 'pw')),
    expect: () => [
      isA<LoginValidationError>()
          .having((s) => s.message, 'message', 'Please Enter Your Email Id')
          .having((s) => s.top, 'top', true),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'empty password -> LoginValidationError',
    build: () => LoginBloc(api),
    act: (bloc) => bloc.add(const LoginSubmitted('a@b.com', '')),
    expect: () => [
      isA<LoginValidationError>()
          .having((s) => s.message, 'message', 'Please enter Your Password'),
    ],
  );

  blocTest<LoginBloc, LoginState>(
    'blocked account -> LoginValidationError(top:false)',
    build: () => LoginBloc(api),
    act: (bloc) =>
        bloc.add(const LoginSubmitted('accounts@multitechcorp.in', 'pw')),
    expect: () => [
      isA<LoginValidationError>().having((s) => s.top, 'top', false),
    ],
  );
}
