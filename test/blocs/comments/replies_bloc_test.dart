import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mta/blocs/comments/replies_bloc.dart';
import 'package:mta/models/AudioReq.dart';
import 'package:mta/models/AudioRes.dart';
import 'package:mta/models/CommonRes.dart';
import 'package:mta/models/CommentsRes.dart';
import 'package:mta/models/FetchMapedCatRes.dart';
import 'package:mta/models/FetchMapedUsersRes.dart';
import 'package:mta/models/ProjectDetails.dart' as pd;
import 'package:mta/network/ApiService.dart';

class MockApiService extends Mock implements ApiService {}

/// Behavior lock for the Replies REST + notification + doc-forwarding flows
/// after their move into [RepliesBloc]. The live socket connect/emit is verified
/// on-device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => registerFallbackValue(AudioReq()));

  late MockApiService api;

  setUp(() => api = MockApiService());

  blocTest<RepliesBloc, RepliesState>(
    'fetchUsers success -> [UserCatsLoaded]',
    setUp: () {
      when(() => api.fetchUsers(any())).thenAnswer((_) async =>
          FetchMapedUsersRes(status: true, data: [FetchMapedUsersData()]));
    },
    build: () => RepliesBloc(api),
    act: (bloc) => bloc.add(const RepliesUserCatsRequested(10)),
    expect: () => [isA<RepliesUserCatsLoaded>()],
  );

  blocTest<RepliesBloc, RepliesState>(
    'getProjectName success -> [ProjectLoaded]',
    setUp: () {
      when(() => api.getProjectName(any())).thenAnswer((_) async =>
          pd.ProjectDetailsRes(
              status: true, data: [pd.Data(projectName: 'Acme')]));
    },
    build: () => RepliesBloc(api),
    act: (bloc) => bloc.add(const RepliesProjectRequested(10)),
    expect: () =>
        [isA<RepliesProjectLoaded>().having((s) => s.name, 'name', 'Acme')],
  );

  group('fetchCats (RepliesCatsRequested)', () {
    blocTest<RepliesBloc, RepliesState>(
      'success -> [CatsLoaded]',
      setUp: () {
        when(() => api.fetchCats(any())).thenAnswer(
            (_) async => FetchMapedCatRes(status: true, data: [CatsData()]));
      },
      build: () => RepliesBloc(api),
      act: (bloc) => bloc.add(const RepliesCatsRequested(10)),
      expect: () => [isA<RepliesCatsLoaded>()],
    );

    blocTest<RepliesBloc, RepliesState>(
      'status false -> [Dismiss]',
      setUp: () {
        when(() => api.fetchCats(any()))
            .thenAnswer((_) async => FetchMapedCatRes(status: false));
      },
      build: () => RepliesBloc(api),
      act: (bloc) => bloc.add(const RepliesCatsRequested(10)),
      expect: () => [isA<RepliesDismiss>()],
    );
  });

  group('removeComment (RepliesRemoveRequested)', () {
    blocTest<RepliesBloc, RepliesState>(
      'success -> [RemoveLoading, RemoveOk]',
      setUp: () {
        when(() => api.removeComment(any()))
            .thenAnswer((_) async => CommentsRes(status: true));
      },
      build: () => RepliesBloc(api),
      act: (bloc) => bloc.add(const RepliesRemoveRequested(7)),
      expect: () => [isA<RepliesRemoveLoading>(), isA<RepliesRemoveOk>()],
    );

    blocTest<RepliesBloc, RepliesState>(
      'status false -> [RemoveLoading, RemoveFail]',
      setUp: () {
        when(() => api.removeComment(any()))
            .thenAnswer((_) async => CommentsRes(status: false));
      },
      build: () => RepliesBloc(api),
      act: (bloc) => bloc.add(const RepliesRemoveRequested(7)),
      expect: () => [isA<RepliesRemoveLoading>(), isA<RepliesRemoveFail>()],
    );

    blocTest<RepliesBloc, RepliesState>(
      'throws -> [RemoveLoading, RemoveError]',
      setUp: () {
        when(() => api.removeComment(any())).thenThrow(Exception('x'));
      },
      build: () => RepliesBloc(api),
      act: (bloc) => bloc.add(const RepliesRemoveRequested(7)),
      expect: () => [isA<RepliesRemoveLoading>(), isA<RepliesRemoveError>()],
    );
  });

  group('uploadAudio (RepliesAudioRequested)', () {
    blocTest<RepliesBloc, RepliesState>(
      'success -> [AudioOk]',
      setUp: () {
        when(() => api.uploadAudio(any()))
            .thenAnswer((_) async => AudioRes(status: true, message: 'ok'));
      },
      build: () => RepliesBloc(api),
      act: (bloc) => bloc.add(RepliesAudioRequested(AudioReq())),
      expect: () => [isA<RepliesAudioOk>()],
    );

    blocTest<RepliesBloc, RepliesState>(
      'status false -> [AudioFail]',
      setUp: () {
        when(() => api.uploadAudio(any()))
            .thenAnswer((_) async => AudioRes(status: false, message: 'bad'));
      },
      build: () => RepliesBloc(api),
      act: (bloc) => bloc.add(RepliesAudioRequested(AudioReq())),
      expect: () =>
          [isA<RepliesAudioFail>().having((s) => s.message, 'msg', 'bad')],
    );

    blocTest<RepliesBloc, RepliesState>(
      'throws -> [AudioError]',
      setUp: () {
        when(() => api.uploadAudio(any())).thenThrow(Exception('x'));
      },
      build: () => RepliesBloc(api),
      act: (bloc) => bloc.add(RepliesAudioRequested(AudioReq())),
      expect: () => [isA<RepliesAudioError>()],
    );
  });

  group('updateNotification (RepliesNotificationUpdate)', () {
    blocTest<RepliesBloc, RepliesState>(
      'status false -> [NotifFailure]',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenAnswer((_) async => CommonRes(status: false, message: 'no'));
      },
      build: () => RepliesBloc(api),
      act: (bloc) => bloc.add(const RepliesNotificationUpdate(9)),
      expect: () => [isA<RepliesNotifFailure>()],
    );

    blocTest<RepliesBloc, RepliesState>(
      'throws -> [NotifError]',
      setUp: () {
        when(() => api.updateNotificationStatus(any()))
            .thenThrow(Exception('x'));
      },
      build: () => RepliesBloc(api),
      act: (bloc) => bloc.add(const RepliesNotificationUpdate(9)),
      expect: () => [isA<RepliesNotifError>()],
    );
  });

  blocTest<RepliesBloc, RepliesState>(
    'document-comments payload -> [DocLoaded]',
    build: () => RepliesBloc(api),
    act: (bloc) => bloc.add(const RepliesDocReceived([])),
    expect: () => [isA<RepliesDocLoaded>()],
  );
}
