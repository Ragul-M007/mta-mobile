import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/auth/verifypin/verifypin_bloc.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/ForgotPassReq.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/models/LoginRes.dart';
import 'package:mta/models/validateOTPReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Verify-PIN flows after their move into
/// [VerifyPinBloc]: the login/role/destination logic and the forgot-pin →
/// OTP → set-pin sequence, matching the original `_VerifypinState`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(LoginReq());
    registerFallbackValue(ForgotPassReq());
    registerFallbackValue(ValidateOTPReq());
  });

  late MockApiService api;

  setUp(() {
    api = MockApiService();
    SharedPreferences.setMockInitialValues({'emailId': 'a@b.com'});
    Strings.fromForgotPassword = false;
    Strings.FromNotification = false;
    Strings.fromNotificationComments = false;
    Strings.fromNotificationDocuments = false;
    Strings.fromNotificationChat = false;
    Strings.roleId = null;
    Strings.isLogin = false;
    Strings.authToken = '';
    Strings.fcmToken = 'fcm';
  });

  LoginRes okLogin({String role = 'STAFF'}) => LoginRes(
        status: true,
        message: 'ok',
        token: 'tok',
        data: LoginResData(
          userId: 5,
          emailId: 'a@b.com',
          name: 'Tester',
          role: role,
          userImg: null,
        ),
      );

  group('VerifyPinSubmitted (login)', () {
    blocTest<VerifyPinBloc, VerifyPinState>(
      'STAFF, no notification -> [Loading, Authenticated(teamsDashboard)] + Strings',
      setUp: () =>
          when(() => api.login(any())).thenAnswer((_) async => okLogin()),
      build: () => VerifyPinBloc(api),
      act: (bloc) => bloc.add(const VerifyPinSubmitted('1234')),
      expect: () => [
        isA<VerifyPinLoading>(),
        isA<VerifyPinAuthenticated>().having((s) => s.destination, 'destination',
            VerifyPinDestination.teamsDashboard),
      ],
      verify: (_) {
        expect(Strings.roleId, 2);
        expect(Strings.authToken, 'tok');
        expect(Strings.isLogin, true);
      },
    );

    blocTest<VerifyPinBloc, VerifyPinState>(
      'CLIENT (role 6) -> Authenticated(projects)',
      setUp: () => when(() => api.login(any()))
          .thenAnswer((_) async => okLogin(role: 'CLIENT')),
      build: () => VerifyPinBloc(api),
      act: (bloc) => bloc.add(const VerifyPinSubmitted('1234')),
      expect: () => [
        isA<VerifyPinLoading>(),
        isA<VerifyPinAuthenticated>().having(
            (s) => s.destination, 'destination', VerifyPinDestination.projects),
      ],
      verify: (_) => expect(Strings.roleId, 6),
    );

    blocTest<VerifyPinBloc, VerifyPinState>(
      'login status=false -> [Loading, Failure(message)]',
      setUp: () => when(() => api.login(any()))
          .thenAnswer((_) async => LoginRes(status: false, message: 'wrong pin')),
      build: () => VerifyPinBloc(api),
      act: (bloc) => bloc.add(const VerifyPinSubmitted('1234')),
      expect: () => [
        isA<VerifyPinLoading>(),
        isA<VerifyPinFailure>().having((s) => s.message, 'message', 'wrong pin'),
      ],
    );
  });

  group('forgot-pin -> OTP -> set-pin', () {
    blocTest<VerifyPinBloc, VerifyPinState>(
      'forgotPass ok then otpVerify ok -> [Loading, ForgotOtpSent, Loading, ResetOtpVerified]',
      setUp: () {
        when(() => api.forgotPass(any()))
            .thenAnswer((_) async => CommonRes(status: true, message: 'sent'));
        when(() => api.otpVerify(any()))
            .thenAnswer((_) async => CommonRes(status: true, message: 'ok'));
      },
      build: () => VerifyPinBloc(api),
      act: (bloc) async {
        bloc.add(const ForgotPasswordOtpRequested('a@b.com'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ResetOtpSubmitted('12345'));
      },
      expect: () => [
        isA<VerifyPinLoading>(),
        isA<ForgotOtpSent>().having((s) => s.email, 'email', 'a@b.com'),
        isA<VerifyPinLoading>(),
        isA<ResetOtpVerified>(),
      ],
      verify: (_) => expect(Strings.fromForgotPassword, true),
    );
  });
}
