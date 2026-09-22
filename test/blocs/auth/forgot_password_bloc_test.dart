import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/auth/forgot_password/forgot_password_bloc.dart';
import 'package:mta/models/ChangePassReq.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/ForgotPassReq.dart';
import 'package:mta/models/validateOTPReq.dart';
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  setUpAll(() {
    registerFallbackValue(ForgotPassReq());
    registerFallbackValue(ValidateOTPReq());
    registerFallbackValue(ChangePassReq());
  });

  late MockApiService api;
  setUp(() => api = MockApiService());

  blocTest<ForgotPasswordBloc, ForgotPasswordState>(
    'forgot -> otp -> change (all ok) -> Sent, Verified, Changed',
    setUp: () {
      when(() => api.forgotPass(any()))
          .thenAnswer((_) async => CommonRes(status: true, message: 'sent'));
      when(() => api.otpVerify(any()))
          .thenAnswer((_) async => CommonRes(status: true, message: 'ok'));
      when(() => api.changePass(any()))
          .thenAnswer((_) async => CommonRes(status: true, message: 'changed'));
    },
    build: () => ForgotPasswordBloc(api),
    act: (bloc) async {
      bloc.add(const ForgotOtpRequested('a@b.com'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ForgotOtpSubmitted('12345'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const NewPasswordSubmitted('newpass'));
    },
    expect: () => [
      isA<ForgotLoading>(),
      isA<ForgotOtpSent>(),
      isA<ForgotLoading>(),
      isA<ForgotOtpVerified>(),
      isA<ForgotLoading>(),
      isA<PasswordChanged>().having((s) => s.message, 'message', 'changed'),
    ],
  );

  blocTest<ForgotPasswordBloc, ForgotPasswordState>(
    'forgotPass status=false -> [Loading, Failure]',
    setUp: () => when(() => api.forgotPass(any()))
        .thenAnswer((_) async => CommonRes(status: false, message: 'no user')),
    build: () => ForgotPasswordBloc(api),
    act: (bloc) => bloc.add(const ForgotOtpRequested('a@b.com')),
    expect: () => [
      isA<ForgotLoading>(),
      isA<ForgotFailure>().having((s) => s.message, 'message', 'no user'),
    ],
  );
}
