import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/auth/setpin/setpin_bloc.dart';
import 'package:mta/models/LoginReq.dart';
import 'package:mta/models/LoginRes.dart';
import 'package:mta/models/SetPinReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Set-PIN flow after its move into [SetpinBloc].
/// Verifies the same API calls, Strings writes, role mapping and navigation
/// decisions the original `_SetpinState` produced.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(SetPinReq());
    registerFallbackValue(LoginReq());
  });

  late MockApiService api;

  setUp(() {
    api = MockApiService();
    SharedPreferences.setMockInitialValues({'userId': 5, 'emailId': 'a@b.com'});
    Strings.fromForgotPassword = false;
    Strings.FromNotification = false;
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

  group('signin (fromForgotPassword == false)', () {
    blocTest<SetpinBloc, SetpinState>(
      'setPin ok + login ok -> [Loading, Authenticated(teamsDashboard)] and writes Strings',
      setUp: () {
        when(() => api.setPin(any(), any()))
            .thenAnswer((_) async => LoginRes(status: true, message: 'ok'));
        when(() => api.login(any())).thenAnswer((_) async => okLogin());
      },
      build: () => SetpinBloc(api),
      act: (bloc) => bloc.add(const SetpinSubmitted('1234')),
      expect: () => [
        isA<SetpinLoading>(),
        isA<SetpinAuthenticated>().having((s) => s.destination, 'destination',
            SetpinDestination.teamsDashboard),
      ],
      verify: (_) {
        expect(Strings.roleId, 2); // STAFF
        expect(Strings.authToken, 'tok');
        expect(Strings.isLogin, true);
      },
    );

    blocTest<SetpinBloc, SetpinState>(
      'setPin status=false -> [Loading, Failure(message)]',
      setUp: () {
        when(() => api.setPin(any(), any())).thenAnswer(
            (_) async => LoginRes(status: false, message: 'bad pin'));
      },
      build: () => SetpinBloc(api),
      act: (bloc) => bloc.add(const SetpinSubmitted('1234')),
      expect: () => [
        isA<SetpinLoading>(),
        isA<SetpinFailure>().having((s) => s.message, 'message', 'bad pin'),
      ],
    );

    blocTest<SetpinBloc, SetpinState>(
      'CLIENT role -> Authenticated(projects)',
      setUp: () {
        when(() => api.setPin(any(), any()))
            .thenAnswer((_) async => LoginRes(status: true));
        when(() => api.login(any()))
            .thenAnswer((_) async => okLogin(role: 'CLIENT'));
      },
      build: () => SetpinBloc(api),
      act: (bloc) => bloc.add(const SetpinSubmitted('1234')),
      expect: () => [
        isA<SetpinLoading>(),
        isA<SetpinAuthenticated>()
            .having((s) => s.destination, 'destination', SetpinDestination.projects),
      ],
      verify: (_) => expect(Strings.roleId, 6),
    );
  });

  group('forgotPin (fromForgotPassword == true)', () {
    blocTest<SetpinBloc, SetpinState>(
      'setForgotPin ok + login ok -> [Loading, Authenticated]',
      setUp: () {
        Strings.fromForgotPassword = true;
        when(() => api.setForgotPin(any(), any()))
            .thenAnswer((_) async => LoginRes(status: true, message: 'ok'));
        when(() => api.login(any())).thenAnswer((_) async => okLogin());
      },
      build: () => SetpinBloc(api),
      act: (bloc) => bloc.add(const SetpinSubmitted('1234')),
      expect: () => [isA<SetpinLoading>(), isA<SetpinAuthenticated>()],
    );
  });
}
