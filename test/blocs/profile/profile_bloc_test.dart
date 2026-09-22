import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/profile/profile_bloc.dart';
import 'package:mta/models/ChangePassReq.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/EditProfileReq.dart';
import 'package:mta/models/LoginRes.dart';
import 'package:mta/models/ProfileRes.dart';
import 'package:mta/models/SetPinReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/utilities/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Profile flows after their move into [ProfileBloc].
/// The BLoC keeps the API calls / prefs / `Strings` writes; the widget performs
/// the UI side effects. These tests verify the state sequences (and the prefs /
/// `Strings` writes) that reproduce the original `_ProfileContentState` methods.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(ChangePassReq());
    registerFallbackValue(EditProfileReq());
    registerFallbackValue(SetPinReq());
  });

  late MockApiService api;

  setUp(() {
    api = MockApiService();
    SharedPreferences.setMockInitialValues({'userId': 5});
    Strings.userID = 5;
    Strings.isLogin = true;
    Strings.roleId = 2;
  });

  group('getProfile (ProfileRequested)', () {
    blocTest<ProfileBloc, ProfileState>(
      'success -> [Loading, DataLoaded]',
      setUp: () {
        when(() => api.profile(any())).thenAnswer(
          (_) async => ProfileRes(status: true, data: [ProfileData()]),
        );
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(const ProfileRequested()),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileDataLoaded>().having((s) => s.data.length, 'len', 1),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'throws -> [Loading, ErrorDismiss]',
      setUp: () {
        when(() => api.profile(any())).thenThrow(Exception('network'));
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(const ProfileRequested()),
      expect: () => [isA<ProfileLoading>(), isA<ProfileErrorDismiss>()],
    );
  });

  group('changePass (ProfilePasswordSubmitted)', () {
    blocTest<ProfileBloc, ProfileState>(
      'status true -> [Loading, NavToLogin] and Strings.isLogin=false',
      setUp: () {
        when(() => api.changePass(any())).thenAnswer(
          (_) async => CommonRes(status: true, message: 'changed'),
        );
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(ProfilePasswordSubmitted(ChangePassReq())),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileNavToLogin>().having((s) => s.message, 'msg', 'changed'),
      ],
      verify: (_) => expect(Strings.isLogin, false),
    );

    blocTest<ProfileBloc, ProfileState>(
      'status false -> [Loading, Failure]',
      setUp: () {
        when(() => api.changePass(any())).thenAnswer(
          (_) async => CommonRes(status: false, message: 'wrong old password'),
        );
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(ProfilePasswordSubmitted(ChangePassReq())),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileFailure>()
            .having((s) => s.message, 'msg', 'wrong old password'),
      ],
    );
  });

  group('editProfile (ProfileEditSubmitted)', () {
    blocTest<ProfileBloc, ProfileState>(
      'status true, removeImage=false -> [Loading, EditSuccess(false)]',
      setUp: () {
        when(() => api.editProfile(any(), any())).thenAnswer(
          (_) async => CommonRes(status: true, message: 'updated'),
        );
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(ProfileEditSubmitted(EditProfileReq(), false)),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileEditSuccess>()
            .having((s) => s.message, 'msg', 'updated')
            .having((s) => s.removeImage, 'removeImage', false),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'status true, removeImage=true -> EditSuccess(true)',
      setUp: () {
        when(() => api.editProfile(any(), any())).thenAnswer(
          (_) async => CommonRes(status: true, message: 'updated'),
        );
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(ProfileEditSubmitted(EditProfileReq(), true)),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileEditSuccess>()
            .having((s) => s.removeImage, 'removeImage', true),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'status false -> [Loading, Failure]',
      setUp: () {
        when(() => api.editProfile(any(), any())).thenAnswer(
          (_) async => CommonRes(status: false, message: 'bad'),
        );
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(ProfileEditSubmitted(EditProfileReq(), false)),
      expect: () => [isA<ProfileLoading>(), isA<ProfileFailure>()],
    );
  });

  group('resetPin (ProfilePinSubmitted)', () {
    blocTest<ProfileBloc, ProfileState>(
      'status true -> [Loading, PinSuccess]',
      setUp: () {
        when(() => api.setPin(any(), any())).thenAnswer(
          (_) async => LoginRes(status: true, message: 'pin set'),
        );
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(ProfilePinSubmitted(SetPinReq())),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfilePinSuccess>().having((s) => s.message, 'msg', 'pin set'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'status false -> [Loading, Failure]',
      setUp: () {
        when(() => api.setPin(any(), any())).thenAnswer(
          (_) async => LoginRes(status: false, message: 'bad pin'),
        );
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(ProfilePinSubmitted(SetPinReq())),
      expect: () => [isA<ProfileLoading>(), isA<ProfileFailure>()],
    );
  });

  group('removeProPic (ProfileProPicRemoveRequested)', () {
    blocTest<ProfileBloc, ProfileState>(
      'status true -> [Loading, ProPicSuccess]',
      setUp: () {
        when(() => api.removeProPic(any()))
            .thenAnswer((_) async => CommonRes(status: true, message: 'ok'));
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(const ProfileProPicRemoveRequested()),
      expect: () =>
          [isA<ProfileLoading>(), isA<ProfileProPicSuccess>()],
    );

    blocTest<ProfileBloc, ProfileState>(
      'status false -> [Loading, Failure]',
      setUp: () {
        when(() => api.removeProPic(any()))
            .thenAnswer((_) async => CommonRes(status: false, message: 'no'));
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(const ProfileProPicRemoveRequested()),
      expect: () => [isA<ProfileLoading>(), isA<ProfileFailure>()],
    );
  });

  group('deleteUser (ProfileUserDeleteRequested) — no spinner', () {
    blocTest<ProfileBloc, ProfileState>(
      'status true -> [NavToLogin] and Strings.isLogin=false',
      setUp: () {
        when(() => api.deleteUser(any())).thenAnswer(
          (_) async => CommonRes(status: true, message: 'deleted'),
        );
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(const ProfileUserDeleteRequested()),
      expect: () => [
        isA<ProfileNavToLogin>().having((s) => s.message, 'msg', 'deleted'),
      ],
      verify: (_) => expect(Strings.isLogin, false),
    );

    blocTest<ProfileBloc, ProfileState>(
      'status false -> [Failure]',
      setUp: () {
        when(() => api.deleteUser(any())).thenAnswer(
          (_) async => CommonRes(status: false, message: 'cannot delete'),
        );
      },
      build: () => ProfileBloc(api),
      act: (bloc) => bloc.add(const ProfileUserDeleteRequested()),
      expect: () => [
        isA<ProfileFailure>()
            .having((s) => s.message, 'msg', 'cannot delete'),
      ],
    );
  });
}
